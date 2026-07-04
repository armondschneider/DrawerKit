import SwiftUI

public struct DrawerStyle: Equatable {
    public var cornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var bottomPadding: CGFloat
    public var grabberSize: CGSize
    public var grabberColor: Color
    public var dimColor: Color
    public var backgroundColor: Color
    public var borderColor: Color
    public var contentPadding: EdgeInsets
    public var animation: Animation

    public init(
        cornerRadius: CGFloat = 40,
        horizontalPadding: CGFloat = 8,
        bottomPadding: CGFloat = 8,
        grabberSize: CGSize = CGSize(width: 38, height: 5),
        grabberColor: Color = .secondary.opacity(0.36),
        dimColor: Color = .black.opacity(0.18),
        backgroundColor: Color = .drawerKitSurface.opacity(0.16),
        borderColor: Color = .white.opacity(0.24),
        contentPadding: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 18, trailing: 16),
        animation: Animation = .spring(response: 0.44, dampingFraction: 0.74, blendDuration: 0.08)
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.bottomPadding = bottomPadding
        self.grabberSize = grabberSize
        self.grabberColor = grabberColor
        self.dimColor = dimColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.contentPadding = contentPadding
        self.animation = animation
    }

    public static var system: DrawerStyle { DrawerStyle() }

    public static func == (lhs: DrawerStyle, rhs: DrawerStyle) -> Bool {
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.horizontalPadding == rhs.horizontalPadding &&
        lhs.bottomPadding == rhs.bottomPadding &&
        lhs.grabberSize == rhs.grabberSize &&
        lhs.contentPadding == rhs.contentPadding
    }
}

public enum DrawerControl: Equatable {
    case dragIndicator
    case closeButton
    case none
}

public enum DrawerDetent: Equatable {
    case content
    case fraction(CGFloat)
    case height(CGFloat)

    public func maxHeight(in availableHeight: CGFloat) -> CGFloat {
        let safeMaximum = availableHeight * 0.92

        switch self {
        case .content:
            return safeMaximum
        case .fraction(let value):
            return availableHeight * min(max(value, 0.2), 0.92)
        case .height(let value):
            return min(max(value, 0), safeMaximum)
        }
    }
}

public struct Drawer<Content: View>: View {
    @Binding private var isPresented: Bool

    private let detent: DrawerDetent
    private let style: DrawerStyle
    private let showsDimmedBackground: Bool
    private let allowsDismissOnDrag: Bool
    private let dismissThreshold: CGFloat
    private let control: DrawerControl
    private let content: () -> Content

    @State private var measuredContentHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0

    public init(
        isPresented: Binding<Bool>,
        detent: DrawerDetent = .content,
        style: DrawerStyle = .system,
        showsDimmedBackground: Bool = true,
        allowsDismissOnDrag: Bool = true,
        dismissThreshold: CGFloat = 120,
        control: DrawerControl = .dragIndicator,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.detent = detent
        self.style = style
        self.showsDimmedBackground = showsDimmedBackground
        self.allowsDismissOnDrag = allowsDismissOnDrag
        self.dismissThreshold = dismissThreshold
        self.control = control
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                if showsDimmedBackground && isPresented {
                    style.dimColor
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { dismiss() }
                }

                if isPresented {
                    drawer(in: proxy)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(style.animation, value: isPresented)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func drawer(in proxy: GeometryProxy) -> some View {
        let maxHeight = detent.maxHeight(in: proxy.size.height)
        let maxContentHeight = max(maxHeight - grabberHeight, 0)
        let targetContentHeight = min(max(measuredContentHeight, 1), maxContentHeight)
        let targetDrawerHeight = targetContentHeight + grabberHeight
        let shouldScroll = measuredContentHeight > maxContentHeight
        let shape = RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)

        return VStack(spacing: 0) {
            if control == .dragIndicator {
                dragIndicator
            }

            Group {
                if shouldScroll {
                    ScrollView(showsIndicators: false) {
                        measuredContent
                    }
                } else {
                    measuredContent
                }
            }
            .frame(maxHeight: shouldScroll ? targetContentHeight : nil)
        }
        .frame(width: max(proxy.size.width - style.horizontalPadding * 2, 0))
        .frame(height: measuredContentHeight > 0 ? targetDrawerHeight : nil, alignment: .top)
        .background(.ultraThinMaterial, in: shape)
        .background(style.backgroundColor, in: shape)
        .overlay(shape.stroke(style.borderColor, lineWidth: 1))
        .overlay(alignment: .topTrailing) {
            if control == .closeButton {
                closeButton
                    .padding(.top, 12)
                    .padding(.trailing, 16)
            }
        }
        .clipShape(shape)
        .glassEffect(in: shape)
        .shadow(color: .black.opacity(0.16), radius: 28, x: 0, y: 16)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.bottom, style.bottomPadding)
        .offset(y: dragOffset)
        .opacity(1 - min(dragOffset / (dismissThreshold * 2.5), 0.42))
        .animation(style.animation, value: measuredContentHeight)
        .animation(style.animation, value: dragOffset)
        .gesture(dragGesture)
    }

    private var grabberHeight: CGFloat { control == .dragIndicator ? 34 : 0 }

    private var dragIndicator: some View {
        Capsule(style: .continuous)
            .fill(style.grabberColor)
            .frame(width: style.grabberSize.width, height: style.grabberSize.height)
            .frame(maxWidth: .infinity)
            .frame(height: grabberHeight)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
    }

    private var closeButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(Color.drawerKitSystemGray6, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }

    private var measuredContent: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding(style.contentPadding)
            .fixedSize(horizontal: false, vertical: true)
            .readDrawerHeight($measuredContentHeight)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                guard allowsDismissOnDrag else { return }

                if dragOffset > dismissThreshold || value.predictedEndTranslation.height > dismissThreshold * 1.5 {
                    withAnimation(style.animation) {
                        isPresented = false
                        dragOffset = 0
                    }
                } else {
                    withAnimation(style.animation) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismiss() {
        withAnimation(style.animation) {
            isPresented = false
            dragOffset = 0
        }
    }
}

public extension View {
    func drawer<DrawerContent: View>(
        isPresented: Binding<Bool>,
        detent: DrawerDetent = .content,
        style: DrawerStyle = .system,
        showsDimmedBackground: Bool = true,
        allowsDismissOnDrag: Bool = true,
        dismissThreshold: CGFloat = 120,
        control: DrawerControl = .dragIndicator,
        @ViewBuilder content: @escaping () -> DrawerContent
    ) -> some View {
        modifier(
            DrawerPresentationModifier(
                isPresented: isPresented,
                detent: detent,
                style: style,
                showsDimmedBackground: showsDimmedBackground,
                allowsDismissOnDrag: allowsDismissOnDrag,
                dismissThreshold: dismissThreshold,
                control: control,
                drawerContent: content
            )
        )
    }
}

public typealias DrawerView = Drawer

public struct DrawerImageItem: Identifiable, Equatable {
    public let id: String
    public var title: String
    public var text: String
    public var imageURL: URL?

    public init(id: String, title: String, text: String, imageURL: URL? = nil) {
        self.id = id
        self.title = title
        self.text = text
        self.imageURL = imageURL
    }
}

private struct DrawerPresentationModifier<DrawerContent: View>: ViewModifier {
    @Binding var isPresented: Bool

    let detent: DrawerDetent
    let style: DrawerStyle
    let showsDimmedBackground: Bool
    let allowsDismissOnDrag: Bool
    let dismissThreshold: CGFloat
    let control: DrawerControl
    let drawerContent: () -> DrawerContent

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            Drawer(
                isPresented: $isPresented,
                detent: detent,
                style: style,
                showsDimmedBackground: showsDimmedBackground,
                allowsDismissOnDrag: allowsDismissOnDrag,
                dismissThreshold: dismissThreshold,
                control: control,
                content: drawerContent
            )
            .allowsHitTesting(isPresented)
            .accessibilityHidden(!isPresented)
            .zIndex(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DrawerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    func readDrawerHeight(_ height: Binding<CGFloat>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: DrawerHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(DrawerHeightPreferenceKey.self) { value in
            height.wrappedValue = value
        }
    }
}

public extension Color {
    static var drawerKitSurface: Color {
        #if canImport(UIKit)
        Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        Color(NSColor.windowBackgroundColor)
        #else
        Color.white
        #endif
    }

    static var drawerKitSystemGray6: Color {
        #if canImport(UIKit)
        Color(UIColor.systemGray6)
        #elseif canImport(AppKit)
        Color(NSColor.controlBackgroundColor)
        #else
        Color.gray.opacity(0.12)
        #endif
    }
}
