import 'dart:typed_data';

import 'package:fawproto/services/offline_ml_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _makeSolidJpeg(int width, int height, int r, int g, int b) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodeJpg(image));
}

List<double> _emptyYoloFlat() => List<double>.filled(7 * 8400, 0.0);

void _setAnchor(
  List<double> flat, {
  required int anchor,
  required double cx,
  required double cy,
  required double w,
  required double h,
  required List<double> scores,
}) {
  const int n = 8400;
  flat[anchor] = cx;
  flat[n + anchor] = cy;
  flat[2 * n + anchor] = w;
  flat[3 * n + anchor] = h;
  for (int c = 0; c < scores.length; c++) {
    flat[(4 + c) * n + anchor] = scores[c];
  }
}

void main() {
  final service = OfflineMlService.instance;

  group('OfflineMlService preprocessing', () {
    test('router preprocessing outputs normalized [1, 3, 224, 224]', () {
      final bytes = _makeSolidJpeg(640, 480, 255, 0, 0);
      final prep = service.preprocessRouterForTest(bytes);

      expect(prep.origWidth, 640);
      expect(prep.origHeight, 480);
      expect(prep.tensor.length, 3 * 224 * 224);
      // Red channel ~ (1.0 - 0.485) / 0.229 = 2.2489
      expect(prep.tensor[0], closeTo(2.2489, 0.05));
      // Green channel ~ (0.0 - 0.456) / 0.224 = -2.0357
      expect(prep.tensor[224 * 224], closeTo(-2.0357, 0.05));
    });

    test('YOLO letterbox preprocessing preserves aspect ratio and 114/255 pad', () {
      final bytes = _makeSolidJpeg(1280, 640, 255, 255, 255);
      final prep = service.preprocessYoloForTest(bytes);

      expect(prep.origWidth, 1280);
      expect(prep.origHeight, 640);
      expect(prep.scale, closeTo(0.5, 1e-6));
      expect(prep.padX, 0);
      expect(prep.padY, 160);
      expect(prep.tensor.length, 3 * 640 * 640);
      // Top padding pixel (0, 0) should be 114/255
      expect(prep.tensor[0], closeTo(114.0 / 255.0, 1e-4));
      // Center pixel (320, 320) should be white (~1.0)
      expect(prep.tensor[320 * 640 + 320], closeTo(1.0, 0.02));
    });
  });

  group('OfflineMlService decoding, NMS, and diagnosis', () {
    test('applies NMS and maps letterbox coords back to original pixels', () {
      final flat = _emptyYoloFlat();
      // Duplicate overlapping larvae detections (class 0)
      _setAnchor(flat, anchor: 10, cx: 320, cy: 320, w: 100, h: 80, scores: [0.85, 0.05, 0.02]);
      _setAnchor(flat, anchor: 11, cx: 322, cy: 321, w: 98, h: 80, scores: [0.65, 0.05, 0.02]);
      // Non-overlapping damage detection (class 1)
      _setAnchor(flat, anchor: 50, cx: 100, cy: 200, w: 40, h: 40, scores: [0.05, 0.55, 0.02]);

      final dets = service.decodeAndMapForTest(
        flat: flat,
        origWidth: 1280,
        origHeight: 640,
        scale: 0.5,
        padX: 0,
        padY: 160,
      );

      expect(dets.length, 2);
      expect(dets[0].className, 'fall_armyworm_larva');
      expect(dets[0].confidence, closeTo(0.85, 1e-6));
      // x1 = (270 - 0) / 0.5 = 540, y1 = (280 - 160) / 0.5 = 240
      expect(dets[0].bbox[0], closeTo(540.0, 1e-4));
      expect(dets[0].bbox[1], closeTo(240.0, 1e-4));
      expect(dets[0].bbox[2], closeTo(740.0, 1e-4));
      expect(dets[0].bbox[3], closeTo(400.0, 1e-4));
      expect(dets[1].className, 'fall_armyworm_larval_damage');
    });

    test('diagnoses maize_streak_disease from class 2 (steak_disease)', () {
      final flat = _emptyYoloFlat();
      _setAnchor(flat, anchor: 5, cx: 320, cy: 320, w: 200, h: 200, scores: [0.01, 0.02, 0.91]);

      final res = service.buildDiagnosisForTest(
        requestId: 'req-streak',
        flat: flat,
        origWidth: 640,
        origHeight: 640,
        scale: 1.0,
        padX: 0,
        padY: 0,
        qualityProb: 0.20, // Even if router flags close-up, high-conf YOLO wins
        sceneConf: 0.99,
        sceneClass: 'leaf',
      );

      expect(res.status, 'maize_streak_disease');
      expect(res.severity, 'high');
      expect(res.confidenceLevel, 'very_high');
      expect(res.detectedClasses, ['maize_streak_disease']);
      expect(res.treatment.title, 'Maize Streak Disease Detected');
    });

    test('diagnoses larvae_damage only as medium severity FAW', () {
      final flat = _emptyYoloFlat();
      _setAnchor(flat, anchor: 5, cx: 320, cy: 320, w: 120, h: 120, scores: [0.05, 0.42, 0.01]);

      final res = service.buildDiagnosisForTest(
        requestId: 'req-dmg',
        flat: flat,
        origWidth: 640,
        origHeight: 640,
        scale: 1.0,
        padX: 0,
        padY: 0,
        qualityProb: 0.85,
        sceneConf: 0.95,
        sceneClass: 'leaf',
      );

      expect(res.status, 'fall_armyworm_detected');
      expect(res.severity, 'medium');
      expect(res.classCounts['fall_armyworm_larval_damage'], 1);
    });

    test('diagnoses healthy when valid leaf has 0 detections', () {
      final flat = _emptyYoloFlat();

      final res = service.buildDiagnosisForTest(
        requestId: 'req-healthy',
        flat: flat,
        origWidth: 640,
        origHeight: 640,
        scale: 1.0,
        padX: 0,
        padY: 0,
        qualityProb: 0.92,
        sceneConf: 0.97,
        sceneClass: 'leaf',
      );

      expect(res.status, 'healthy');
      expect(res.severity, 'low');
      expect(res.detectedClasses, ['healthy_maize']);
      expect(res.maxConfidence, closeTo(0.97, 1e-6));
    });

    test('rejects invalid scene or low quality with 0 detections as retake_image', () {
      final flat = _emptyYoloFlat();

      final invalidRes = service.buildDiagnosisForTest(
        requestId: 'req-invalid',
        flat: flat,
        origWidth: 640,
        origHeight: 640,
        scale: 1.0,
        padX: 0,
        padY: 0,
        qualityProb: 0.90,
        sceneConf: 0.88,
        sceneClass: 'invalid',
      );
      expect(invalidRes.status, 'retake_image');
      expect(invalidRes.severity, 'unknown');

      final blurryRes = service.buildDiagnosisForTest(
        requestId: 'req-blur',
        flat: flat,
        origWidth: 640,
        origHeight: 640,
        scale: 1.0,
        padX: 0,
        padY: 0,
        qualityProb: 0.25,
        sceneConf: 0.80,
        sceneClass: 'leaf',
      );
      expect(blurryRes.status, 'retake_image');
    });
  });
}

