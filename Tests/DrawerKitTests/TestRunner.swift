import DrawerKit
import Foundation
import SwiftUI
import XCTest

final class DrawerKitTests: XCTestCase {
    func testDrawerKit() {
        testFractionDetentClampsToSupportedRange()
        testFixedHeightDetentClampsToSafeMaximum()
        testContentDetentUsesSafeMaximum()
        testDrawerStyleStoresCustomValues()
        testDrawerImageItemStoresValues()
    }

    private func testFractionDetentClampsToSupportedRange() {
        XCTAssertEqual(DrawerDetent.fraction(0.1).maxHeight(in: 1_000), 200)
        XCTAssertEqual(DrawerDetent.fraction(0.5).maxHeight(in: 1_000), 500)
        XCTAssertEqual(DrawerDetent.fraction(1.0).maxHeight(in: 1_000), 920)
    }

    private func testFixedHeightDetentClampsToSafeMaximum() {
        XCTAssertEqual(DrawerDetent.height(-20).maxHeight(in: 1_000), 0)
        XCTAssertEqual(DrawerDetent.height(420).maxHeight(in: 1_000), 420)
        XCTAssertEqual(DrawerDetent.height(2_000).maxHeight(in: 1_000), 920)
    }

    private func testContentDetentUsesSafeMaximum() {
        XCTAssertEqual(DrawerDetent.content.maxHeight(in: 1_000), 920)
    }

    private func testDrawerStyleStoresCustomValues() {
        let padding = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let style = DrawerStyle(
            cornerRadius: 22,
            horizontalPadding: 10,
            bottomPadding: 12,
            grabberSize: CGSize(width: 30, height: 6),
            contentPadding: padding
        )

        XCTAssertEqual(style.cornerRadius, 22)
        XCTAssertEqual(style.horizontalPadding, 10)
        XCTAssertEqual(style.bottomPadding, 12)
        XCTAssertEqual(style.grabberSize.width, 30)
        XCTAssertEqual(style.grabberSize.height, 6)
        XCTAssertEqual(style.contentPadding.top, 1)
        XCTAssertEqual(style.contentPadding.leading, 2)
        XCTAssertEqual(style.contentPadding.bottom, 3)
        XCTAssertEqual(style.contentPadding.trailing, 4)
    }

    private func testDrawerImageItemStoresValues() {
        let url = URL(string: "https://example.com/image.jpg")!
        let item = DrawerImageItem(
            id: "one",
            title: "Title",
            text: "Body",
            imageURL: url
        )

        XCTAssertEqual(item.id, "one")
        XCTAssertEqual(item.title, "Title")
        XCTAssertEqual(item.text, "Body")
        XCTAssertEqual(item.imageURL, url)
    }
}
