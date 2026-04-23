class PredictionResult {
  final String label;
  final double confidence;
  final String imageUrl;
  final DateTime timestamp;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.imageUrl,
    required this.timestamp,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  PredictionResult copyWith({
    String? label,
    double? confidence,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    return PredictionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'PredictionResult(label: $label, confidence: $confidence, imageUrl: $imageUrl, timestamp: $timestamp)';
  }
}
