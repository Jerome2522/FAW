class PredictResponseModel {
  final String status;
  final String severity;
  final List<String> detectedClasses;
  final Map<String, int> classCounts;
  final int detectionCount;
  final double maxConfidence;
  final List<DetectionModel> detections;
  final TreatmentModel treatment;
  final String requestId;
  final String confidenceLevel;

  PredictResponseModel({
    required this.status,
    required this.severity,
    required this.detectedClasses,
    required this.classCounts,
    required this.detectionCount,
    required this.maxConfidence,
    required this.detections,
    required this.treatment,
    required this.requestId,
    required this.confidenceLevel,
  });

  factory PredictResponseModel.fromJson(Map<String, dynamic> json) {
    var detectionsList = json['detections'] as List? ?? [];
    List<DetectionModel> parsedDetections = detectionsList
        .map((d) => DetectionModel.fromJson(d as Map<String, dynamic>))
        .toList();

    Map<String, int> parsedClassCounts = {};
    if (json['class_counts'] != null) {
      json['class_counts'].forEach((key, value) {
        parsedClassCounts[key] = (value as num).toInt();
      });
    }

    return PredictResponseModel(
      status: json['status'] ?? 'retake_image',
      severity: json['severity'] ?? 'unknown',
      detectedClasses: List<String>.from(json['detected_classes'] ?? []),
      classCounts: parsedClassCounts,
      detectionCount: (json['detection_count'] as num? ?? 0).toInt(),
      maxConfidence: (json['max_confidence'] as num? ?? 0.0).toDouble(),
      detections: parsedDetections,
      treatment: TreatmentModel.fromJson(json['treatment'] as Map<String, dynamic>? ?? {}),
      requestId: json['request_id'] ?? '',
      confidenceLevel: json['confidence_level'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'severity': severity,
      'detected_classes': detectedClasses,
      'class_counts': classCounts,
      'detection_count': detectionCount,
      'max_confidence': maxConfidence,
      'detections': detections.map((d) => d.toJson()).toList(),
      'treatment': treatment.toJson(),
      'request_id': requestId,
      'confidence_level': confidenceLevel,
    };
  }
}

class DetectionModel {
  final String className;
  final double confidence;
  final List<double> bbox;

  DetectionModel({
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    var bboxList = json['bbox'] as List? ?? [];
    List<double> parsedBbox = bboxList.map((coords) => (coords as num).toDouble()).toList();
    
    return DetectionModel(
      className: json['class_name'] ?? 'unknown',
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      bbox: parsedBbox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'confidence': confidence,
      'bbox': bbox,
    };
  }
}

class TreatmentModel {
  final String title;
  final String summary;
  final List<String> recommendations;

  TreatmentModel({
    required this.title,
    required this.summary,
    required this.recommendations,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      title: json['title'] ?? 'Unknown Diagnosis',
      summary: json['summary'] ?? 'No summary available.',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'recommendations': recommendations,
    };
  }
}
