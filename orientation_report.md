# FAW v2.0 Orientation & Responsive Design Validation Report

This report documents the UI testing outcomes, box overlay alignment, and scrolling properties across multiple device form factors and screen widths for `ResultV2Screen`.

---

## 1. Grid Responsiveness Matrix

We use `LayoutBuilder` and `MediaQuery` to detect screen widths and device orientations dynamically:

| Screen Format | Width Constraint | Layout Applied | Image Fitting | Scroll Physics | Overflow Risk |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Portrait / Phone** | Width $\le$ 800px | Single-column vertical scroll | `BoxFit.contain` | `BouncingScrollPhysics` | **NONE** (All elements wrapped in SingleChildScrollView) |
| **Landscape / Phone** | Width > 800px / Landscape | Side-by-side two-column row | `BoxFit.contain` | `BouncingScrollPhysics` | **NONE** (Flex elements are proportional) |
| **Tablet (Portrait)** | Width $\le$ 800px | Single-column wide vertical | `BoxFit.contain` | `BouncingScrollPhysics` | **NONE** (Text scales, columns are fluid) |
| **Tablet / Laptop (Wide)** | Width > 800px | Two-column split (Left: 45% Image, Right: 50% info) | `BoxFit.contain` | `BouncingScrollPhysics` | **NONE** (Proportional width division prevents overlapping columns) |

---

## 2. Bounding Box & CustomPaint Alignment

A common issue in object detection apps is bounding box drift (where overlays do not match the underlying image due to scaling). Our implementation resolves this via aspect-ratio matching:

* **Painter Alignment**: The CustomPainter takes `originalImageSize` (from listener resolution) and `widgetSize` (from constraints). It computes scale identical to Flutter's native `BoxFit.contain`:
  $$scale = \min\left(\frac{widgetWidth}{originalWidth}, \frac{widgetHeight}{originalHeight}\right)$$
* **Offset Math**: Centers boxes by subtracting actual displayed image area from constraints and dividing by 2:
  $$dx = \frac{widgetWidth - originalWidth \times scale}{2}$$
  $$dy = \frac{widgetHeight - originalHeight \times scale}{2}$$
* **Clipping**: The container is wrapped in a `ClipRRect(borderRadius: BorderRadius.circular(24))` to clip coordinates that paint outside the image preview borders.

---

## 3. UI Scrolling and Overflows Audit

* **Scrolling Issues**: Checked. Single-column lists utilize `BouncingScrollPhysics` for native iOS and smooth Android feel. Text sections wrapping rules are enforced (e.g. `maxLines` and `overflow: TextOverflow.ellipsis` on card titles to prevent text clipping).
* **Landscape Constraints**: Left column containing the image is capped to `max(constraints.maxHeight * 0.8, 360)` to prevent the image from pushing contents off the screen vertically on short screens.
