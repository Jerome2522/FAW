class PredictResult {
  final String action;
  final String? scene;
  final Prediction? prediction;
  final Treatment? treatment;
  final Guidance? guidance;
  final String? reasonCode;
  final RouterDebug routerDebug;
  final double latencyMs;

  PredictResult({
    required this.action,
    this.scene,
    this.prediction,
    this.treatment,
    this.guidance,
    this.reasonCode,
    required this.routerDebug,
    required this.latencyMs,
  });

  factory PredictResult.fromJson(Map<String, dynamic> json) {
    return PredictResult(
      action: json['action'],
      scene: json['scene'],
      prediction: json['prediction'] != null 
          ? Prediction.fromJson(json['prediction']) 
          : null,
      treatment: json['treatment'] != null 
          ? Treatment.fromJson(json['treatment']) 
          : null,
      guidance: json['guidance'] != null 
          ? Guidance.fromJson(json['guidance']) 
          : null,
      reasonCode: json['reason_code'],
      routerDebug: RouterDebug.fromJson(json['router_debug']),
      latencyMs: (json['latency_ms'] as num).toDouble(),
    );
  }
}

class Prediction {
  final String label;
  final String displayName;
  final double confidence;
  final bool? isFaw;

  Prediction({
    required this.label,
    required this.displayName,
    required this.confidence,
    this.isFaw,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      label: json['label'],
      displayName: json['display_name'],
      confidence: (json['confidence'] as num).toDouble(),
      isFaw: json['is_faw'],
    );
  }
}

class Treatment {
  final String urgency;
  final String summary;
  final List<String> steps;
  final List<String> products;
  final String localResources;

  Treatment({
    required this.urgency,
    required this.summary,
    required this.steps,
    required this.products,
    required this.localResources,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      urgency: json['urgency'],
      summary: json['summary'],
      steps: List<String>.from(json['steps']),
      products: List<String>.from(json['products']),
      localResources: json['local_resources'],
    );
  }
}

class Guidance {
  final String title;
  final String instruction;
  final String icon;

  Guidance({
    required this.title,
    required this.instruction,
    required this.icon,
  });

  factory Guidance.fromJson(Map<String, dynamic> json) {
    return Guidance(
      title: json['title'],
      instruction: json['instruction'],
      icon: json['icon'],
    );
  }
}

class RouterDebug {
  final String scene;
  final double sceneConf;
  final double qualityProb;

  RouterDebug({
    required this.scene,
    required this.sceneConf,
    required this.qualityProb,
  });

  factory RouterDebug.fromJson(Map<String, dynamic> json) {
    return RouterDebug(
      scene: json['scene'],
      sceneConf: (json['scene_conf'] as num).toDouble(),
      qualityProb: (json['quality_prob'] as num).toDouble(),
    );
  }
}
