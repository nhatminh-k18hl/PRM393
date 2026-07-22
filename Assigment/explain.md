# Project Technical Documentation (`explain.md`)
**Origami 3D Master (`threed_orimaster`)**

---

## 1. Project Overview & Target Platform Specifications

- **Application Name**: Origami 3D Master (`threed_orimaster`)
- **Target Platform**: Flutter Mobile (Android & iOS)
- **Display Orientation**: Strict Landscape-Locked Mode (`DeviceOrientation.landscapeLeft` & `DeviceOrientation.landscapeRight` with responsive 180-degree sensor orientation support)
- **Architecture Pattern**: Clean Architecture + Provider State Management (`provider: ^6.1.2`). Decouples business logic, networking pipelines, local HTTP asset streaming, and presentation tree.

---

## 2. Package Dependencies & Core Infrastructure

The project dependencies defined in `Code/pubspec.yaml` and standard libraries are structured as follows:

| Package / Module | Version / Source | Architectural Purpose |
| :--- | :--- | :--- |
| `flutter` | SDK | Core UI layout engine, Material Design system, and canvas renderer |
| `provider` | `^6.1.2` | Reactive state management decoupling business models from widget trees |
| `shared_preferences` | `^2.2.3` | Local key-value hardware storage for user theme palette & font preferences |
| `path_provider` | `^2.1.2` | Cross-platform system path resolver for local application document storage |
| `dio` | `^5.4.0` | Asynchronous HTTP client for downloading remote ZIP model packages with progress callbacks |
| `archive` | `^3.4.10` | In-memory ZIP archive decompression and local file system extraction |
| `flutter_3d_controller` | `^1.2.1` | Native WebView wrapper rendering Google `<model-viewer>` 3D Web Component |
| `connectivity_plus` | `^6.0.3` | Hardware network state listener (Offline, Mobile Data, Wi-Fi / Ethernet) |
| `dart:io` | Standard Library | Embedded loopback HTTP server (`HttpServer.bind`) and native filesystem I/O |

---

## 3. Core Application Features

### A. Dashboard (`Code/lib/screens/dashboard_screen.dart`)
- **Hybrid Data Catalog**: Loads model registry entries from local assets (`assets/data/origami_database.json`).
- **ANY-Logic Multi-Tag Join Filter**: Filters model collection matching any selected category tag (`_selectedCategories.any(...)`).
- **Dynamic ChoiceChips Banner**: Automatically extracts unique category tags from loaded models and renders a horizontal scrollable filter lane.
- **Priority Cache Bubble Sorting**: Downloaded models automatically bubble to the top of the grid display.
- **Search & Clear Filters**: Text query matching title/description with a single-tap clear filters action.
- **Blurred Settings Overlay**: Modal drawer with theme palette selection (`AppTheme.LIGHT_CLASSIC` default), font choices, and UI scaling controls.

### B. Product Detail Screen (`Code/lib/screens/product_detail_screen.dart`)
- **Material Specifications Card**: Displays dimensions, paper type, required tools, and detailed description.
- **Inline Network Status Warning Banner**:
  - **Offline State (`ConnectivityResult.none`)**: Displays a red warning row (`"You are currently offline."`) and blocks download.
  - **Mobile Data State (`ConnectivityResult.mobile`)**: Displays an amber warning row (`"Warning: You are using mobile data."`) while allowing download.
  - **Wi-Fi / Ethernet State (`ConnectivityResult.wifi / ethernet`)**: Hides banner completely.
- **Interactive Controls**: Dismiss button `[X]` and animated download/extraction progress indicators.

### C. Practice Viewer Screen (`Code/lib/screens/practice_viewer_screen.dart`)
- **Step-by-Step 2D Instructions**: Renders 2D step images with rotation/orbit preview indicators.
- **Horizontal Swipe Physics**:
  - Swipe Right-to-Left (Swipe Left) -> Advance step (`_goToNextStep`).
  - Swipe Left-to-Right (Swipe Right) -> Regress step (`_goToPrevStep`).
- **Overflow-Proof Instruction Bar**: Compact fixed height (`42px`), single-line text wrapped in horizontal `SingleChildScrollView(scrollDirection: Axis.horizontal, physics: BouncingScrollPhysics())` preventing vertical layout overflow errors in landscape mode.
- **Integrated 3D Showcase**: Displays the interactive 3D model on the final step (`currentStepIndex == total2DSteps`).

---

## 4. Key Architectural Hotfixes & Solutions

### A. Embedded Local HTTP Server (`LocalServerService`)
- **Problem**: Modern Android and iOS WebViews enforce strict Content Security Policies (CSP) and CORS rules that block Google `<model-viewer>` from fetching 3D `.glb` models from `file://` or `data:` URIs.
- **Solution**: `LocalServerService` spins up a singleton `HttpServer` bound on `127.0.0.1:$port`. It serves unzipped model files with CORS headers (`Access-Control-Allow-Origin: *`, `Access-Control-Allow-Methods: GET, POST, OPTIONS`) and `Content-Type: model/gltf-binary`, allowing `<model-viewer>` to stream `.glb` models smoothly via `http://127.0.0.1:$port/models/$origamiId/finish.glb`.

### B. Touch Hit-Test Isolation & Pointer Event Pass-Through
- **Problem**: Native WebView platform views (`AndroidView` / `UiKitView`) intercept pointer events, freezing Flutter header/footer buttons.
- **Solution**: The Header/AppBar toolbar is positioned as the **LAST CHILD** inside `Stack(children: [...])` wrapped in `Material(color: Colors.transparent)`. Action buttons utilize `GestureDetector(behavior: HitTestBehavior.opaque)` and "Trở về Trang chủ" executes `Navigator.of(context).popUntil((route) => route.isFirst)`.

### C. Android Manifest Network Permissions
Declared system permissions in `Code/android/app/src/main/AndroidManifest.xml`:
- `<uses-permission android:name="android.permission.INTERNET"/>`
- `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`
- `android:usesCleartextTraffic="true"` inside `<application>` to permit HTTP loopback calls.

---

## 5. Codebase Directory Tree Structure (`Code/lib/`)

```
Code/lib/
├── main.dart                          # Application entry point, server startup & theme wrapper
├── models/
│   └── origami_model.dart             # OrigamiModel data class & JSON parsing logic
├── providers/
│   ├── app_settings_provider.dart     # Theme palette, font, and UI scale settings state
│   └── origami_provider.dart          # Database registry, unzipped path resolution & filter state
├── screens/
│   ├── dashboard_screen.dart          # Home grid, search, choice chips & settings overlay
│   ├── practice_viewer_screen.dart    # 2D/3D step viewer, swipe gesture arena & overflow hotfix
│   ├── product_detail_screen.dart     # Spec sheet modal & inline network warning banner
│   └── splash_screen.dart             # Animated landing screen
└── services/
    └── local_server_service.dart      # Singleton HTTP server for local GLB & asset streaming
```
