# ``DrawerKit``

Build iOS 26-style SwiftUI drawers with interactive drag physics, detents, content fitting, liquid-glass styling, and customizable presentation.

## Overview

DrawerKit provides a lightweight bottom drawer that can hug its content, cap to a maximum height, scroll overflowing content, and dismiss with a live drag gesture. The package includes a core ``DrawerView``, a sheet-like ``SwiftUICore/View/drawer(isPresented:detent:style:showsDimmedBackground:sizesToFitContent:allowsDismissOnDrag:showsGrabber:dismissThreshold:content:)`` modifier, and an example ``MorphingImageDrawerView`` built on top of the core drawer.

Use ``DrawerDetent`` to control the drawer's maximum height:

- ``DrawerDetent/content`` fits the drawer to its content and caps it at a safe maximum height.
- ``DrawerDetent/fraction(_:)`` caps the drawer to a percentage of the available height.
- ``DrawerDetent/height(_:)`` caps the drawer to a fixed height.

Customize spacing, colors, liquid-glass material behavior, corner radius, content padding, and spring timing with ``DrawerStyle``.

```swift
import SwiftUI
import DrawerKit

struct ExampleView: View {
    @State private var showDrawer = false

    var body: some View {
        Button("Open Drawer") {
            showDrawer = true
        }
        .drawer(isPresented: $showDrawer, detent: .content) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Drawer Content")
                    .font(.title)

                Text("This drawer hugs content, rubber-bands while dragging, and scrolls if content exceeds the max height.")
            }
        }
    }
}
```

## Topics

### Core Drawer

- ``DrawerView``
- ``DrawerDetent``
- ``DrawerStyle``

### Image Example

- ``DrawerImageItem``
- ``DrawerImageDetailView``
- ``MorphingImageDrawerView``
