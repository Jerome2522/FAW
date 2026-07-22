# FAW v2.0 Android APK Build Report

This report documents the compilation details and bundle size of the Android Release APK build.

---

## 1. Build Metadata

* **Command**: `flutter build apk --release`
* **Status**: **SUCCESS**
* **Build Time**: 141.5 seconds
* **Output Path**: `build/app/outputs/flutter-apk/app-release.apk`
* **APK File Size**: **51.1 MB**

---

## 2. Compilation Logs & Diagnostic Warnings

During the Gradle task execution (`assembleRelease`), the compiler emitted some warnings but resolved all packages:

### Tree Shaking:
```text
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 13540 bytes (99.2% reduction).
```

### Compiler Notes & Warnings:
1. **Unchecked operations warning** (from cloud_firestore dependency):
   ```text
   Note: PipelineStageHandlers.java uses unchecked or unsafe operations.
   Note: Recompile with -Xlint:unchecked for details.
   ```
2. **Obsolete Java Source/Target version warning** (3 warnings):
   ```text
   warning: [options] source value 8 is obsolete and will be removed in a future release
   warning: [options] target value 8 is obsolete and will be removed in a future release
   warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
   ```

### Verification Outcome:
The build completed successfully despite obsolete source level warnings in dependency Gradle scripts. The tree-shaking reduced package size, resulting in a production-ready **51.1 MB** APK binary.
