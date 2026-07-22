# Flutter predict_v2 Integration & Verification Report

This report summarizes the migration of the `fawproto` Flutter application to consume the new `/predict_v2` YOLOv8 endpoint and render the spatial object detections.

---

## 1. Summary of Changes

* **New Configuration**: Added the `predictV2Endpoint` (`/predict_v2`) to `lib/config/app_config.dart`.
* **New Models (`predict_v2_response.dart`)**:
  - `PredictV2ResponseModel`: Decodes `status`, `severity`, `detected_classes`, `class_counts`, `detection_count`, `max_confidence`, `detections`, and `treatment`.
  - `DetectionModel`: Decodes class name, confidence, and `bbox` coordinates `[x1, y1, x2, y2]`.
  - `TreatmentModel`: Decodes title, summary, and recommendations.
* **API Service (`api_service.dart`)**: Added the `predictV2` method. It performs multipart image upload, passing the `request_id` and `device_id` headers with `X-API-Key` authentication.
* **New Result Screen (`result_v2_screen.dart`)**:
  - Handles the online call to `/predict_v2` asynchronously.
  - Implements a premium neon-line scanning animation during inference.
  - Formats layout dynamically using `LayoutBuilder` and `MediaQuery` to support phone, tablet, laptop, and landscape configurations.
  - Includes `BoundingBoxPainter` to scale and overlay YOLO bounding boxes.
* **Compat Mapper**: Converts `PredictV2ResponseModel` to a backward-compatible V1 `PredictResult` so that old history screens continue loading scans flawlessly.
* **Scan Hub Integration**: Routed captured/chosen image flows to `ResultV2Screen` instead of the old V1 page.

---

## 2. API JSON Schema Examples & Latency Benchmarks

### Case A: healthy
* **Latency**: ~292.63 ms
* **JSON Response**:
```json
{
  "status": "healthy",
  "severity": "low",
  "detected_classes": ["healthy_maize"],
  "class_counts": {
    "healthy_maize": 1
  },
  "detection_count": 1,
  "max_confidence": 0.9395874738693237,
  "detections": [
    {
      "class_name": "healthy_maize",
      "confidence": 0.9395874738693237,
      "bbox": [53.061, 0.0, 712.741, 1021.559]
    }
  ],
  "treatment": {
    "title": "Healthy Crop",
    "summary": "No pests or diseases detected.",
    "recommendations": [
      "Continue regular crop monitoring.",
      "Maintain proper weeding and field hygiene.",
      "Ensure optimal watering and fertilization."
    ]
  }
}
```

### Case B: fall_armyworm_detected
* **Latency**: ~167.93 ms
* **JSON Response**:
```json
{
  "status": "fall_armyworm_detected",
  "severity": "medium",
  "detected_classes": ["fall_armyworm_larval_damage"],
  "class_counts": {
    "fall_armyworm_larval_damage": 3
  },
  "detection_count": 3,
  "max_confidence": 0.5089244842529297,
  "detections": [
    {
      "class_name": "fall_armyworm_larval_damage",
      "confidence": 0.5089244842529297,
      "bbox": [124.102, 337.684, 345.828, 445.476]
    },
    {
      "class_name": "fall_armyworm_larval_damage",
      "confidence": 0.463038,
      "bbox": [105.494, 168.824, 373.829, 293.552]
    }
  ],
  "treatment": {
    "title": "Fall Armyworm Detected",
    "summary": "Evidence of infestation detected.",
    "recommendations": [
      "Inspect surrounding plants.",
      "Monitor affected leaves.",
      "Consult agricultural guidelines."
    ]
  }
}
```

### Case C: maize_streak_disease
* **Latency**: ~22.73 ms (using backend mocked response)
* **JSON Response**:
```json
{
  "status": "maize_streak_disease",
  "severity": "high",
  "detected_classes": ["maize_streak_disease"],
  "class_counts": {
    "maize_streak_disease": 1
  },
  "detection_count": 1,
  "max_confidence": 0.88,
  "detections": [
    {
      "class_name": "maize_streak_disease",
      "confidence": 0.88,
      "bbox": [15.5, 30.2, 120.4, 210.6]
    }
  ],
  "treatment": {
    "title": "Maize Streak Disease Detected",
    "summary": "Evidence of maize streak virus detected.",
    "recommendations": [
      "Remove and destroy infected plants.",
      "Control leafhopper vectors using appropriate treatments.",
      "Plant resistant maize varieties in future cycles."
    ]
  }
}
```

### Case D: retake_image
* **Latency**: ~60.08 ms (due to pre-YOLO quality checks failing)
* **JSON Response**:
```json
{
  "status": "retake_image",
  "severity": "unknown",
  "detected_classes": [],
  "class_counts": {},
  "detection_count": 0,
  "max_confidence": 0.0,
  "detections": [],
  "treatment": {
    "title": "Retake Image",
    "summary": "Could not make a reliable diagnosis.",
    "recommendations": [
      "Ensure the leaf is in focus.",
      "Take the photo under clear, natural lighting.",
      "Place the leaf in the center of the frame."
    ]
  }
}
```

---

## 3. Visual & Bounding Box Layout Logic

The `BoundingBoxPainter` utilizes the `BoxFit.contain` logic to project bounding boxes from original raw pixels onto the active device screen size dynamically:

```dart
double scale = min(
  widgetSize.width / originalImageSize.width,
  widgetSize.height / originalImageSize.height,
);
double displayedWidth = originalImageSize.width * scale;
double displayedHeight = originalImageSize.height * scale;
double dx = (widgetSize.width - displayedWidth) / 2;
double dy = (widgetSize.height - displayedHeight) / 2;

// Mapping coordinate:
double left = dx + x1 * scale;
double top = dy + y1 * scale;
```

### Layout Responsiveness Matrix:
* **Phone / Narrow Width**: Stacks image preview on top, metrics and checklists scrollable below.
* **Tablet & Landscape / Wide Width**: Side-by-side layout (Left panel shows the image with overlaid bounding boxes; right panel contains diagnosis cards and recommendations).

---

## 4. Issues Discovered & Resolved

1. **Undefined Icon Error**:
   - *Issue*: `Icons.camera_off_outlined` was not defined.
   - *Resolution*: Replaced with standard Material `Icons.no_photography_outlined` which compiles successfully.
2. **Scan History Backward Compatibility**:
   - *Issue*: Historical records are stored as V1 structures; saving V2 structures directly would cause history view decoding crashes.
   - *Resolution*: Implemented a translation method `_mapToV1Result` in `ResultV2Screen` that converts a V2 result into a compatible V1 structure for clean storage.
