# Diagnostic Audit Report (`state.md`)
**System & Platform Architecture Audit: Origami 3D Master**

---

## 1. Project Overview & Environment State

- **Application Name**: threed_orimaster (Origami 3D Master)
- **SDK Constraint**: `sdk: '>=3.0.0 <4.0.0'`
- **Target Platform**: Flutter Mobile (Android / iOS) - Landscape-locked orientation
- **State Management**: `provider` (v6.1.2)
- **Key Dependencies (`Code/pubspec.yaml`)**:
  - `flutter`: SDK
  - `provider`: `^6.1.2`
  - `shared_preferences`: `^2.2.3`
  - `path_provider`: `^2.1.2`
  - `dio`: `^5.4.0`
  - `archive`: `^3.4.10`
  - `flutter_3d_controller`: `^1.2.1` (wraps `webview_flutter` and Google `<model-viewer>` web component)

---

## 2. Current Database & Path Mappings

The primary database configuration is stored in `Code/assets/data/origami_database.json` and synced at `Assigment/Data/Upload_data/origami_database.json`:

```json
[
  {
    "id": "folding_paper_3x3",
    "title": "3x3 Grid Matrix",
    "description": "Learn how to divide a standard square paper into perfect thirds using the geometric 'S' method to build a baseline 3 by 3 grid consisting of 9 equal sections.",
    "difficulty": "Beginner Origami",
    "categories": ["Beginner Origami"],
    "preview_img": "folding_paper_3x3_thumb",
    "materials": {
      "paper_size": "15x15 cm (Square Paper)",
      "paper_type": "Standard Origami Sheet",
      "tools": ["Ruler", "Pencil"]
    },
    "download_url": "https://raw.githubusercontent.com/nhatminh-k18hl/PRM393/main/Assigment/Data/Upload_data/folding_paper_3x3.zip"
  },
  {
    "id": "rabbit_ear_fold",
    "title": "Rabbit Ear Fold",
    "description": "A fundamental origami base technique used to decrease flap width and form limbs or sharp points. Vital for intermediate modeling.",
    "difficulty": "Beginner Origami",
    "categories": ["Beginner Origami"],
    "preview_img": "rabbit_ear_fold_thumb",
    "materials": {
      "paper_size": "15x15 cm (Square Paper)",
      "paper_type": "Standard Origami Sheet",
      "tools": ["None"]
    },
    "download_url": "https://raw.githubusercontent.com/nhatminh-k18hl/PRM393/main/Assigment/Data/Upload_data/Rabbit%20Ear%20Fold.zip"
  },
  {
    "id": "origami_shield_with_cross",
    "title": "Knight Shield with Cross",
    "description": "An exquisite medieval knight shield featuring an elegant cross embossed directly at the geometric center of the model.",
    "difficulty": "Intermediate Origami",
    "categories": ["Intermediate Origami", "Origami Decorations", "Modular Origami"],
    "preview_img": "origami_shield_with_cross_thumb",
    "materials": {
      "paper_size": "20x20 cm (Large Square Paper)",
      "paper_type": "Thick Craft Paper / Foil Paper",
      "tools": ["Bone Folder (Dụng cụ miết nếp)"]
    },
    "download_url": "https://raw.githubusercontent.com/nhatminh-k18hl/PRM393/main/Assigment/Data/Upload_data/Origami%20Shield%20With%20Cross.zip"
  }
]
```

---

## 3. File System & Extracted Zip Directory Tree

Packages are unzipped onto the local device storage under `$appDocDir/models/$origamiId`.

### Package Layout Analysis:
1. **`folding_paper_3x3`**: Flat unzipped structure
   - `$appDocDir/models/folding_paper_3x3/steps.json`
   - `$appDocDir/models/folding_paper_3x3/finish.glb` (Size: 11,176 bytes)
   - `$appDocDir/models/folding_paper_3x3/step_1_origami_3x3-removebg-preview.png` ... `step_14_...png`

2. **`rabbit_ear_fold`**: Nested directory structure inside zip
   - `$appDocDir/models/rabbit_ear_fold/Rabbit Ear Fold/steps.json`
   - `$appDocDir/models/rabbit_ear_fold/Rabbit Ear Fold/finish.glb` (Size: 11,176 bytes)
   - `$appDocDir/models/rabbit_ear_fold/Rabbit Ear Fold/step_1_rabbit_ear_fold.png` ... `step_9_...png`

3. **`origami_shield_with_cross`**: Nested directory structure inside zip
   - `$appDocDir/models/origami_shield_with_cross/Origami Shield With Cross/steps.json`
   - `$appDocDir/models/origami_shield_with_cross/Origami Shield With Cross/finish.glb` (Size: 11,176 bytes)
   - `$appDocDir/models/origami_shield_with_cross/Origami Shield With Cross/step_1_...png` ... `step_12_...png`

**Note on File Sizes**:
`finish.glb` size across all packages is ~11.1 KB. Base64 encoding generates a string of ~15 KB.

---

## 4. Code Snapshot of 3D Viewer Implementation

Below is the snapshot from `Code/lib/screens/practice_viewer_screen.dart` responsible for loading the 3D model and rendering the UI stack:

```dart
// Base64 loader function:
Future<String?> _loadTargetGlbAsBase64(String resolvedBaseDirPath) async {
  try {
    final cleanPath = Uri.decodeFull(resolvedBaseDirPath);
    File glbFile = File("$cleanPath/finish.glb");

    if (!glbFile.existsSync()) {
      final dir = Directory(cleanPath);
      if (dir.existsSync()) {
        final entities = dir.listSync(recursive: true);
        for (var entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('finish.glb')) {
            glbFile = entity;
            break;
          }
        }
      }
    }

    if (glbFile.existsSync()) {
      final List<int> bytes = await glbFile.readAsBytes();
      final String base64Data = base64Encode(bytes);
      return 'data:application/octet-stream;base64,$base64Data';
    }
  } catch (e) {
    debugPrint("Error streaming binary glb object: $e");
  }
  return null;
}

// Widget build method snippet:
@override
Widget build(BuildContext context) {
  // ...
  final isFinal3DStage = _currentStepIndex == total2DSteps;

  Widget mainContent;
  if (isFinal3DStage) {
    mainContent = _base64GlbDataUri != null
        ? Flutter3DViewer(src: _base64GlbDataUri!)
        : Center(child: Text("3D model file not found locally."));
  } else {
    // 2D step renderer
  }

  return Scaffold(
    body: GestureDetector(
      onHorizontalDragEnd: (details) { ... },
      child: Stack(
        children: [
          // Child 1: Background Canvas
          Positioned.fill(...),

          // Child 2: Step Content Display (contains Flutter3DViewer on final step)
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: mainContent,
              ),
            ),
          ),

          // Child 3: Bounding Gesture Division Layers (15% left, 70% center, 15% right)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(flex: 15, child: GestureDetector(onTap: _goToPrevStep, ...)),
                Expanded(flex: 70, child: GestureDetector(onTap: _toggleControls, child: SizedBox.expand())),
                Expanded(flex: 15, child: GestureDetector(onTap: _goToNextStep, ...)),
              ],
            ),
          ),

          // Child 4: HEADER INFO BAR overlay
          AnimatedPositioned(top: _isControlsVisible ? 0 : -80, child: ...),

          // Child 5: BOTTOM OPTIONS & EXPANDABLE GUIDE PANEL overlay
          AnimatedPositioned(bottom: _isControlsVisible ? 0 : -140, child: ...),
        ],
      ),
    ),
  );
}
```

---

## 5. Diagnosed Root Causes

### Root Cause 1: 3D Model Rendering Failure (Blank Screen)
1. **CORS and Content-Security-Policy Restrictions on Data URIs**:
   `Flutter3DViewer` wraps Google's `<model-viewer>` component inside a native WebView. Under the hood, `<model-viewer>` executes JavaScript `fetch()` or `XMLHttpRequest` requests to obtain the model binary. Modern Android (Chromium) and iOS (WebKit) WebViews block `fetch()` calls to `data:` URIs or `file://` URIs due to `origin: null` security policy constraints.
2. **Incorrect MIME Type Header**:
   The code passes `data:application/octet-stream;base64,...`. Google `<model-viewer>` requires glTF/GLB MIME type format (`data:model/gltf-binary;base64,...`) or a standard HTTP URL ending in `.glb`.
3. **Missing Unique Widget Key (`ValueKey`)**:
   `Flutter3DViewer` is instantiated without a `key: ValueKey(_base64GlbDataUri)` or `ValueKey(_currentStepIndex)`. When switching steps or initializing, Flutter reuses the existing WebView state object without forcing `<model-viewer>` to reload its source attribute.

### Root Cause 2: Frozen UI & Swallowed Gesture Inputs
1. **Native Platform View Pointer Event Swallowing**:
   `Flutter3DViewer` renders a native Android/iOS WebView platform view (`AndroidView` / `UiKitView`). Platform Views create a native view layer inside the OS widget hierarchy that intercepts and consumes all touch pointer events before Flutter's gesture arena can process them.
2. **Stack Layering & Transparent SizedBox Interception**:
   In `Stack`, `Flutter3DViewer` resides in Child 2 (`Positioned.fill`). Child 3 overlays a `Row` with `SizedBox.expand()` (HitTestBehavior.translucent). Because `SizedBox.expand()` is transparent and does not consume pointer events, touch inputs pass straight down into Child 2 (the native WebView), which swallows them completely.
3. **Touch Interception on Overlay Controls**:
   Header and footer toolbars (Children 4 & 5) overlap the top and bottom regions of `Flutter3DViewer`. Touches near or over the platform view boundary get intercepted by native platform view gesture handlers, rendering header back buttons, home buttons, and step navigation controls unresponsive ("frozen UI").

---

## 6. Proposed Fix Strategies

### Strategy 1: Embedded Local HTTP Server (`shelf` / `localhost`) — **RECOMMENDED**
- **Description**: Spin up a lightweight local HTTP server (using `shelf` or `HttpServer.bind(InternetAddress.loopbackIPv4, 0)`) serving unzipped model directory files on `http://127.0.0.1:<port>/finish.glb`.
- **Advantages**:
  - Serves files via standard HTTP with explicit CORS headers (`Access-Control-Allow-Origin: *`) and MIME type `model/gltf-binary`.
  - Bypasses WebView `file://` and `data:` URI CORS/CSP restrictions cleanly on both Android and iOS.
  - Native `<model-viewer>` streams `.glb` files efficiently without memory spikes or base64 overhead.

### Strategy 2: Gesture Isolation & Pointer Pass-Through (`IgnorePointer` & Key Rebuilds)
- **Description**:
  - Wrap `Flutter3DViewer` inside an `IgnorePointer` or transparent touch blocker when overlay controls are active so that native WebViews cannot intercept touches intended for header/footer buttons.
  - Assign a unique `key: ValueKey(_base64GlbDataUri)` to `Flutter3DViewer` to ensure proper widget lifecycle recreation upon step navigation.
  - Update Base64 MIME type header to `data:model/gltf-binary;base64,$base64Data`.

### Strategy 3: Custom Asset/File Scheme Handler or Web Resource Response Interception
- **Description**: Intercept WebView resource loading requests or use local asset serving methods to map custom URI schemes (e.g., `app://local/finish.glb`) directly to local file streams.
