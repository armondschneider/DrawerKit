import DrawerKit
import Foundation
import SwiftUI

@main
struct DrawerKitTestRunner {
    static func main() {
        testFractionDetentClampsToSupportedRange()
        testFixedHeightDetentClampsToSafeMaximum()
        testContentDetentUsesSafeMaximum()
        testDrawerStyleStoresCustomValues()
        testDrawerImageItemStoresValues()

        print("DrawerKit tests passed")
    }

    private static func testFractionDetentClampsToSupportedRange() {
        expectEqual(DrawerDetent.fraction(0.1).maxHeight(in: 1_000), 200)
        expectEqual(DrawerDetent.fraction(0.5).maxHeight(in: 1_000), 500)
        expectEqual(DrawerDetent.fraction(1.0).maxHeight(in: 1_000), 920)
    }

    private static func testFixedHeightDetentClampsToSafeMaximum() {
        expectEqual(DrawerDetent.height(-20).maxHeight(in: 1_000), 0)
        expectEqual(DrawerDetent.height(420).maxHeight(in: 1_000), 420)
        expectEqual(DrawerDetent.height(2_000).maxHeight(in: 1_000), 920)
    }

    private static func testContentDetentUsesSafeMaximum() {
        expectEqual(DrawerDetent.content.maxHeight(in: 1_000), 920)
    }

    private static func testDrawerStyleStoresCustomValues() {
        let padding = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let style = DrawerStyle(
            cornerRadius: 22,
            horizontalPadding: 10,
            bottomPadding: 12,
            grabberSize: CGSize(width: 30, height: 6),
            contentPadding: padding
        )

        expectEqual(style.cornerRadius, 22)
        expectEqual(style.horizontalPadding, 10)
        expectEqual(style.bottomPadding, 12)
        expectEqual(style.grabberSize.width, 30)
        expectEqual(style.grabberSize.height, 6)
        expectEqual(style.contentPadding.top, 1)
        expectEqual(style.contentPadding.leading, 2)
        expectEqual(style.contentPadding.bottom, 3)
        expectEqual(style.contentPadding.trailing, 4)
    }

    private static func testDrawerImageItemStoresValues() {
        let url = URL(string: "https://example.com/image.jpg")!
        let item = DrawerImageItem(
            id: "one",
            title: "Title",
            text: "Body",
            imageURL: url
        )

        expectEqual(item.id, "one")
        expectEqual(item.title, "Title")
        expectEqual(item.text, "Body")
        expectEqual(item.imageURL, url)
    }

    private static func expectEqual<T: Equatable>(_ actual: T, _ expected: T, file: StaticString = #file, line: UInt = #line) {
        guard actual == expected else {
            fatalError("Expected \(expected), got \(actual)", file: file, line: line)
        }
    }
}
