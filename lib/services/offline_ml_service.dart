import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../models/predict_response.dart';

class _RouterPreprocessResult {
  final Float32List tensor;
  final int origWidth;
  final int origHeight;

  const _RouterPreprocessResult({
    required this.tensor,
    required this.origWidth,
    required this.origHeight,
  });
}

class _YoloPreprocessResult {
  final Float32List tensor;
  final int origWidth;
  final int origHeight;
  final double scale;
  final int padX;
  final int padY;

  const _YoloPreprocessResult({
    required this.tensor,
    required this.origWidth,
    required this.origHeight,
    required this.scale,
    required this.padX,
    required this.padY,
  });
}

class _RawDetection {
  final int classId;
  final String className;
  final double confidence;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const _RawDetection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

/// Decodes bytes, enforces upright EXIF orientation, and prepares [1, 3, 224, 224]
/// ImageNet-normalized NCHW input for `router.onnx`.
_RouterPreprocessResult _preprocessRouter(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Failed to decode image bytes');
  }
  final upright = img.bakeOrientation(decoded);
  final origW = upright.width;
  final origH = upright.height;

  final int newW;
  final int newH;
  if (origW < origH) {
    newW = 256;
    newH = (origH * 256 / origW).floor();
  } else {
    newH = 256;
    newW = (origW * 256 / origH).floor();
  }

  final resized = img.copyResize(
    upright,
    width: newW,
    height: newH,
    interpolation: img.Interpolation.linear,
  );

  final cropX = ((newW - 224) ~/ 2).clamp(0, math.max(0, newW - 224)).toInt();
  final cropY = ((newH - 224) ~/ 2).clamp(0, math.max(0, newH - 224)).toInt();
  final cropped = img.copyCrop(
    resized,
    x: cropX,
    y: cropY,
    width: 224,
    height: 224,
  );

  const int planeSize = 224 * 224;
  final tensor = Float32List(3 * planeSize);
  const double meanR = 0.485, meanG = 0.456, meanB = 0.406;
  const double stdR = 0.229, stdG = 0.224, stdB = 0.225;

  for (int y = 0; y < 224; y++) {
    final rowOffset = y * 224;
    for (int x = 0; x < 224; x++) {
      final p = cropped.getPixel(x, y);
      final idx = rowOffset + x;
      tensor[idx] = (p.rNormalized.toDouble() - meanR) / stdR;
      tensor[planeSize + idx] = (p.gNormalized.toDouble() - meanG) / stdG;
      tensor[2 * planeSize + idx] = (p.bNormalized.toDouble() - meanB) / stdB;
    }
  }

  return _RouterPreprocessResult(
    tensor: tensor,
    origWidth: origW,
    origHeight: origH,
  );
}

/// Decodes bytes, enforces upright EXIF orientation, and prepares [1, 3, 640, 640]
/// letterboxed RGB NCHW input normalized to [0, 1] for `yolov8n_wff_ema_3cls.onnx`.
_YoloPreprocessResult _preprocessYolo(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Failed to decode image bytes');
  }
  final upright = img.bakeOrientation(decoded);
  final origW = upright.width;
  final origH = upright.height;

  const int targetSize = 640;
  final double r = math.min(targetSize / origW, targetSize / origH);
  final int newW = (origW * r).round();
  final int newH = (origH * r).round();
  final int padX = (targetSize - newW) ~/ 2;
  final int padY = (targetSize - newH) ~/ 2;

  final resized = img.copyResize(
    upright,
    width: newW,
    height: newH,
    interpolation: img.Interpolation.linear,
  );

  const int planeSize = targetSize * targetSize;
  const double padValue = 114.0 / 255.0;
  final tensor = Float32List(3 * planeSize)..fillRange(0, 3 * planeSize, padValue);

  for (int y = 0; y < newH; y++) {
    final dstRow = (y + padY) * targetSize + padX;
    for (int x = 0; x < newW; x++) {
      final p = resized.getPixel(x, y);
      final idx = dstRow + x;
      tensor[idx] = p.rNormalized.toDouble();
      tensor[planeSize + idx] = p.gNormalized.toDouble();
      tensor[2 * planeSize + idx] = p.bNormalized.toDouble();
    }
  }

  return _YoloPreprocessResult(
    tensor: tensor,
    origWidth: origW,
    origHeight: origH,
    scale: r,
    padX: padX,
    padY: padY,
  );
}

/// Runs on-device ONNX inference (Router quality gate + YOLOv8n-WFF-EMA 3-class detector)
/// so crop diagnosis works 100% offline.
class OfflineMlService {
  OfflineMlService._();

  static final OfflineMlService instance = OfflineMlService._();

  static const String _routerAsset = 'assets/models/router.onnx';
  static const String _yoloAsset = 'assets/models/yolov8n_wff_ema_3cls.onnx';

  static const int _yoloInputSize = 640;
  static const int _yoloAnchors = 8400;
  static const int _yoloClasses = 3;
  static const double _defaultConfThreshold = 0.25;
  static const double _lowQualityConfThreshold = 0.35;
  static const double _nmsIouThreshold = 0.45;
  static const double _routerSceneThreshold = 0.50;
  static const double _routerQualityThreshold = 0.55;

  static const List<String> _sceneLabels = ['leaf', 'insect', 'invalid'];

  // Canonicalized class names aligned with the Flutter UI and history schema.
  // Dataset class 2 is spelled 'steak_disease' in dataset_3cls/data.yaml.
  static const Map<int, String> _classNames = {
    0: 'fall_armyworm_larva',
    1: 'fall_armyworm_larval_damage',
    2: 'maize_streak_disease',
  };

  static const Map<String, Map<String, dynamic>> _treatments = {
    'healthy': {
      'title': 'Healthy Crop',
      'summary': 'No pests or diseases detected.',
      'recommendations': [
        'Continue regular crop monitoring.',
        'Maintain proper weeding and field hygiene.',
        'Ensure optimal watering and fertilization.',
      ],
    },
    'fall_armyworm_detected': {
      'title': 'Fall Armyworm Detected',
      'summary': 'Evidence of infestation detected.',
      'recommendations': [
        'Inspect surrounding plants.',
        'Monitor affected leaves.',
        'Consult agricultural guidelines.',
      ],
    },
    'maize_streak_disease': {
      'title': 'Maize Streak Disease Detected',
      'summary': 'Evidence of maize streak virus detected.',
      'recommendations': [
        'Remove and destroy infected plants.',
        'Control leafhopper vectors using appropriate treatments.',
        'Plant resistant maize varieties in future cycles.',
      ],
    },
    'retake_image': {
      'title': 'Retake Image',
      'summary': 'Could not make a reliable diagnosis.',
      'recommendations': [
        'Ensure the leaf is in focus.',
        'Take the photo under clear, natural lighting.',
        'Place the leaf in the center of the frame.',
      ],
    },
  };

  final OnnxRuntime _ort = OnnxRuntime();
  OrtSession? _routerSession;
  OrtSession? _yoloSession;
  Future<void>? _initFuture;

  bool get isInitialized => _routerSession != null && _yoloSession != null;

  /// Loads both ONNX models from app assets once. Safe to call concurrently.
  Future<void> initialize() {
    return _initFuture ??= _loadSessions().catchError((Object e) {
      _initFuture = null;
      throw e;
    });
  }

  Future<void> _loadSessions() async {
    final options = OrtSessionOptions(
      intraOpNumThreads: 2,
      interOpNumThreads: 1,
    );

    _routerSession ??= await _ort.createSessionFromAsset(
      _routerAsset,
      options: options,
    );
    _yoloSession ??= await _ort.createSessionFromAsset(
      _yoloAsset,
      options: options,
    );
  }

  /// Runs offline diagnosis on [imageFile] and returns a [PredictResponseModel]
  /// matching the schema expected by `ResultScreen` and `ScanHistoryService`.
  Future<PredictResponseModel> predict(File imageFile) async {
    await initialize();

    final String requestId = const Uuid().v4();
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // 1. Router Quality & Scene Check
    final routerPrep = await compute(_preprocessRouter, imageBytes);
    final routerOutcome = await _runRouter(routerPrep.tensor);

    final bool invalidScene = routerOutcome.sceneClass == 'invalid' &&
        routerOutcome.sceneConf >= _routerSceneThreshold;

    if (invalidScene) {
      return _buildRetakeResponse(requestId);
    }

    // 2. YOLOv8n-WFF-EMA 3-class Object Detection
    final yoloPrep = await compute(_preprocessYolo, imageBytes);
    final double confThresh = routerOutcome.qualityProb < _routerQualityThreshold
        ? _lowQualityConfThreshold
        : _defaultConfThreshold;

    final detections = await _runYolo(yoloPrep, confThresh);

    // 3. Diagnosis & Severity Mapping
    if (detections.isNotEmpty) {
      return _buildDetectionResponse(requestId, detections);
    }

    if (routerOutcome.qualityProb >= _routerQualityThreshold) {
      return _buildHealthyResponse(requestId, routerOutcome.sceneConf);
    }

    return _buildRetakeResponse(requestId);
  }

  Future<({String sceneClass, double sceneConf, double qualityProb})> _runRouter(
    Float32List tensor,
  ) async {
    final session = _routerSession!;
    OrtValue? inputTensor;
    Map<String, OrtValue>? outputs;

    try {
      inputTensor = await OrtValue.fromList(tensor, [1, 3, 224, 224]);
      final inputName = session.inputNames.first;
      outputs = await session.run({inputName: inputTensor});

      final sceneName = session.outputNames[0];
      final qualityName = session.outputNames[1];

      final sceneRaw = await outputs[sceneName]!.asFlattenedList();
      final qualityRaw = await outputs[qualityName]!.asFlattenedList();

      final sceneLogits = sceneRaw.map((e) => (e as num).toDouble()).toList();
      final maxLogit = sceneLogits.reduce(math.max);
      final exps = sceneLogits.map((v) => math.exp(v - maxLogit)).toList();
      final expSum = exps.reduce((a, b) => a + b);
      final probs = exps.map((v) => v / expSum).toList();

      int bestIdx = 0;
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > probs[bestIdx]) bestIdx = i;
      }

      final qualityLogit = (qualityRaw.first as num).toDouble();
      final qualityProb = 1.0 / (1.0 + math.exp(-qualityLogit));

      return (
        sceneClass: _sceneLabels[bestIdx],
        sceneConf: probs[bestIdx],
        qualityProb: qualityProb,
      );
    } finally {
      await inputTensor?.dispose();
      if (outputs != null) {
        for (final val in outputs.values) {
          await val.dispose();
        }
      }
    }
  }

  Future<List<_RawDetection>> _runYolo(
    _YoloPreprocessResult prep,
    double confThreshold,
  ) async {
    final session = _yoloSession!;
    OrtValue? inputTensor;
    Map<String, OrtValue>? outputs;

    try {
      inputTensor = await OrtValue.fromList(
        prep.tensor,
        [1, 3, _yoloInputSize, _yoloInputSize],
      );
      final inputName = session.inputNames.first;
      outputs = await session.run({inputName: inputTensor});

      final outName = session.outputNames.first;
      final flat = await outputs[outName]!.asFlattenedList();

      return _decodeYoloOutput(
        flat: flat,
        origWidth: prep.origWidth,
        origHeight: prep.origHeight,
        scale: prep.scale,
        padX: prep.padX,
        padY: prep.padY,
        confThreshold: confThreshold,
      );
    } finally {
      await inputTensor?.dispose();
      if (outputs != null) {
        for (final val in outputs.values) {
          await val.dispose();
        }
      }
    }
  }

  /// Decodes raw `[1, 7, 8400]` YOLO output tensor into NMS-filtered detections
  /// in original image pixel coordinates.
  @visibleForTesting
  List<DetectionModel> decodeAndMapForTest({
    required List<dynamic> flat,
    required int origWidth,
    required int origHeight,
    required double scale,
    required int padX,
    required int padY,
    double confThreshold = _defaultConfThreshold,
  }) {
    final raw = _decodeYoloOutput(
      flat: flat,
      origWidth: origWidth,
      origHeight: origHeight,
      scale: scale,
      padX: padX,
      padY: padY,
      confThreshold: confThreshold,
    );
    return raw
        .map((d) => DetectionModel(
              className: d.className,
              confidence: d.confidence,
              bbox: [d.x1, d.y1, d.x2, d.y2],
            ))
        .toList();
  }

  List<_RawDetection> _decodeYoloOutput({
    required List<dynamic> flat,
    required int origWidth,
    required int origHeight,
    required double scale,
    required int padX,
    required int padY,
    double confThreshold = _defaultConfThreshold,
  }) {
    final List<_RawDetection> candidates = [];
    for (int a = 0; a < _yoloAnchors; a++) {
      int bestCls = 0;
      double bestScore = (flat[4 * _yoloAnchors + a] as num).toDouble();
      for (int c = 1; c < _yoloClasses; c++) {
        final score = (flat[(4 + c) * _yoloAnchors + a] as num).toDouble();
        if (score > bestScore) {
          bestScore = score;
          bestCls = c;
        }
      }

      if (bestScore < confThreshold) continue;

      final double cx = (flat[a] as num).toDouble();
      final double cy = (flat[_yoloAnchors + a] as num).toDouble();
      final double w = (flat[2 * _yoloAnchors + a] as num).toDouble();
      final double h = (flat[3 * _yoloAnchors + a] as num).toDouble();

      final double x1 = ((cx - w / 2.0 - padX) / scale)
          .clamp(0.0, origWidth.toDouble());
      final double y1 = ((cy - h / 2.0 - padY) / scale)
          .clamp(0.0, origHeight.toDouble());
      final double x2 = ((cx + w / 2.0 - padX) / scale)
          .clamp(0.0, origWidth.toDouble());
      final double y2 = ((cy + h / 2.0 - padY) / scale)
          .clamp(0.0, origHeight.toDouble());

      if (x2 <= x1 || y2 <= y1) continue;

      candidates.add(_RawDetection(
        classId: bestCls,
        className: _classNames[bestCls] ?? 'unknown',
        confidence: bestScore,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
      ));
    }

    return _nms(candidates, _nmsIouThreshold);
  }

  @visibleForTesting
  PredictResponseModel buildDiagnosisForTest({
    required String requestId,
    required List<dynamic> flat,
    required int origWidth,
    required int origHeight,
    required double scale,
    required int padX,
    required int padY,
    required double qualityProb,
    required double sceneConf,
    required String sceneClass,
  }) {
    if (sceneClass == 'invalid' && sceneConf >= _routerSceneThreshold) {
      return _buildRetakeResponse(requestId);
    }
    final confThresh = qualityProb < _routerQualityThreshold
        ? _lowQualityConfThreshold
        : _defaultConfThreshold;
    final dets = _decodeYoloOutput(
      flat: flat,
      origWidth: origWidth,
      origHeight: origHeight,
      scale: scale,
      padX: padX,
      padY: padY,
      confThreshold: confThresh,
    );
    if (dets.isNotEmpty) {
      return _buildDetectionResponse(requestId, dets);
    }
    if (qualityProb >= _routerQualityThreshold) {
      return _buildHealthyResponse(requestId, sceneConf);
    }
    return _buildRetakeResponse(requestId);
  }

  @visibleForTesting
  ({Float32List tensor, int origWidth, int origHeight}) preprocessRouterForTest(
    Uint8List bytes,
  ) {
    final res = _preprocessRouter(bytes);
    return (
      tensor: res.tensor,
      origWidth: res.origWidth,
      origHeight: res.origHeight,
    );
  }

  @visibleForTesting
  ({
    Float32List tensor,
    int origWidth,
    int origHeight,
    double scale,
    int padX,
    int padY,
  }) preprocessYoloForTest(Uint8List bytes) {
    final res = _preprocessYolo(bytes);
    return (
      tensor: res.tensor,
      origWidth: res.origWidth,
      origHeight: res.origHeight,
      scale: res.scale,
      padX: res.padX,
      padY: res.padY,
    );
  }

  List<_RawDetection> _nms(List<_RawDetection> dets, double iouThreshold) {
    if (dets.isEmpty) return const [];

    final sorted = List<_RawDetection>.from(dets)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final List<_RawDetection> kept = [];
    final List<bool> suppressed = List<bool>.filled(sorted.length, false);

    for (int i = 0; i < sorted.length; i++) {
      if (suppressed[i]) continue;
      final a = sorted[i];
      kept.add(a);

      for (int j = i + 1; j < sorted.length; j++) {
        if (suppressed[j]) continue;
        final b = sorted[j];
        if (a.classId != b.classId) continue;

        if (_iou(a, b) > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }

    return kept;
  }

  double _iou(_RawDetection a, _RawDetection b) {
    final interX1 = math.max(a.x1, b.x1);
    final interY1 = math.max(a.y1, b.y1);
    final interX2 = math.min(a.x2, b.x2);
    final interY2 = math.min(a.y2, b.y2);

    final interW = math.max(0.0, interX2 - interX1);
    final interH = math.max(0.0, interY2 - interY1);
    final interArea = interW * interH;
    if (interArea <= 0) return 0.0;

    final areaA = (a.x2 - a.x1) * (a.y2 - a.y1);
    final areaB = (b.x2 - b.x1) * (b.y2 - b.y1);
    final unionArea = areaA + areaB - interArea;
    return unionArea > 0 ? interArea / unionArea : 0.0;
  }

  PredictResponseModel _buildDetectionResponse(
    String requestId,
    List<_RawDetection> detections,
  ) {
    final Map<String, int> classCounts = {};
    final Set<String> classSet = {};
    double maxConfidence = 0.0;

    final List<DetectionModel> models = detections.map((d) {
      classSet.add(d.className);
      classCounts[d.className] = (classCounts[d.className] ?? 0) + 1;
      if (d.confidence > maxConfidence) {
        maxConfidence = d.confidence;
      }
      return DetectionModel(
        className: d.className,
        confidence: d.confidence,
        bbox: [d.x1, d.y1, d.x2, d.y2],
      );
    }).toList();

    final bool hasFaw = classSet.contains('fall_armyworm_larva') ||
        classSet.contains('fall_armyworm_larval_damage');
    final bool hasStreak = classSet.contains('maize_streak_disease');
    final bool hasLarva = classSet.contains('fall_armyworm_larva');

    final String status =
        hasFaw ? 'fall_armyworm_detected' : 'maize_streak_disease';
    final String severity = (hasLarva || hasStreak) ? 'high' : 'medium';

    final detectedClasses = classSet.toList()..sort();

    return PredictResponseModel(
      status: status,
      severity: severity,
      detectedClasses: detectedClasses,
      classCounts: classCounts,
      detectionCount: models.length,
      maxConfidence: maxConfidence,
      detections: models,
      treatment: _treatmentFor(status),
      requestId: requestId,
      confidenceLevel: _confidenceLevel(maxConfidence),
    );
  }

  PredictResponseModel _buildHealthyResponse(
    String requestId,
    double confidence,
  ) {
    return PredictResponseModel(
      status: 'healthy',
      severity: 'low',
      detectedClasses: const ['healthy_maize'],
      classCounts: const {'healthy_maize': 1},
      detectionCount: 0,
      maxConfidence: confidence,
      detections: const [],
      treatment: _treatmentFor('healthy'),
      requestId: requestId,
      confidenceLevel: _confidenceLevel(confidence),
    );
  }

  PredictResponseModel _buildRetakeResponse(String requestId) {
    return PredictResponseModel(
      status: 'retake_image',
      severity: 'unknown',
      detectedClasses: const [],
      classCounts: const {},
      detectionCount: 0,
      maxConfidence: 0.0,
      detections: const [],
      treatment: _treatmentFor('retake_image'),
      requestId: requestId,
      confidenceLevel: 'low',
    );
  }

  TreatmentModel _treatmentFor(String status) {
    final map = _treatments[status] ?? _treatments['retake_image']!;
    return TreatmentModel.fromJson(map);
  }

  String _confidenceLevel(double confidence) {
    final pct = confidence * 100.0;
    if (pct >= 90) return 'very_high';
    if (pct >= 75) return 'high';
    if (pct >= 50) return 'medium';
    return 'low';
  }

  Future<void> dispose() async {
    await _routerSession?.close();
    await _yoloSession?.close();
    _routerSession = null;
    _yoloSession = null;
    _initFuture = null;
  }
}

