# DrawerKit

Simple SwiftUI bottom drawers with dynamic height, drag-to-dismiss, dimmed backdrop, and sheet-like ergonomics.

<p align="center">
  <img src="preview.gif" width="320" alt="DrawerKit preview">
</p>

## Install

Add this repo in Xcode with **File > Add Package Dependencies...**, then add `DrawerKit` to your app target.

## Usage

```swift
import DrawerKit
import SwiftUI

struct ContentView: View {
    @State private var showDrawer = false

    var body: some View {
        ZStack {
            Button("Open Drawer") {
                showDrawer = true
            }
        }
        .drawer(isPresented: $showDrawer) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Drawer")
                    .font(.title2.bold())

                Text("Content drives the drawer height.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

## Options

```swift
.drawer(
    isPresented: $showDrawer,
    detent: .content,
    style: DrawerStyle(),
    control: .dragIndicator
) {
    DrawerContent()
}
```

**Detents**

```swift
.content
.fraction(0.6)
.height(420)
```

**Controls**

```swift
.dragIndicator
.closeButton
.none
```

Use `.none` when your drawer content includes custom close, back, or apply buttons.

## Styling

```swift
let style = DrawerStyle(
    cornerRadius: 40,
    horizontalPadding: 16,
    bottomPadding: 16,
    contentPadding: EdgeInsets(top: 0, leading: 16, bottom: 18, trailing: 16),
    animation: .spring(response: 0.44, dampingFraction: 0.72)
)
```

## Demo

See `Sources/Examples/DemoView.swift` for a schedule-style drawer with native date/time pickers and animated height changes.

## Requirements

- iOS 26+
- macOS 26+
- SwiftUI
