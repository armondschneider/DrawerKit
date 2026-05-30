import SwiftUI

public struct DrawerStyle {
    public var cornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var bottomPadding: CGFloat
    public var grabberSize: CGSize
    public var grabberColor: Color
    public var dimColor: Color
    public var backgroundColor: Color
    public var usesLiquidGlass: Bool
    public var borderColor: Color
    public var contentPadding: EdgeInsets
    public var animation: Animation

    public init(
        cornerRadius: CGFloat = 34,
        horizontalPadding: CGFloat = 8,
        bottomPadding: CGFloat = 8,
        grabberSize: CGSize = CGSize(width: 36, height: 5),
        grabberColor: Color = Color.secondary.opacity(0.45),
        dimColor: Color = Color.black.opacity(0.12),
        backgroundColor: Color = Color.drawerKitSurface.opacity(0.72),
        usesLiquidGlass: Bool = true,
        borderColor: Color = Color.white.opacity(0.34),
        contentPadding: EdgeInsets = EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12),
        animation: Animation = .interactiveSpring(response: 0.48, dampingFraction: 0.72, blendDuration: 0.12)
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.bottomPadding = bottomPadding
        self.grabberSize = grabberSize
        self.grabberColor = grabberColor
        self.dimColor = dimColor
        self.backgroundColor = backgroundColor
        self.usesLiquidGlass = usesLiquidGlass
        self.borderColor = borderColor
        self.contentPadding = contentPadding
        self.animation = animation
    }

    public static var system: DrawerStyle { DrawerStyle() }
}

public enum DrawerDetent: Equatable {
    case content
    case fraction(CGFloat)
    case height(CGFloat)

    public func maxHeight(in availableHeight: CGFloat) -> CGFloat {
        switch self {
        case .content:
            return availableHeight * 0.92
        case .fraction(let value):
            return availableHeight * min(max(value, 0.2), 0.92)
        case .height(let value):
            return min(max(value, 0), availableHeight * 0.92)
        }
    }
}

public struct DrawerView<Content: View>: View {
    @Binding private var isPresented: Bool

    private let detent: DrawerDetent
    private let style: DrawerStyle
    private let showsDimmedBackground: Bool
    private let sizesToFitContent: Bool
    private let allowsDismissOnDrag: Bool
    private let showsGrabber: Bool
    private let dismissThreshold: CGFloat
    private let content: () -> Content

    @State private var contentHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    public init(
        isPresented: Binding<Bool>,
        heightRatio: CGFloat = 0.5,
        style: DrawerStyle = .system,
        showsDimmedBackground: Bool = false,
        sizesToFitContent: Bool = false,
        allowsDismissOnDrag: Bool = true,
        showsGrabber: Bool = true,
        dismissThreshold: CGFloat = 120,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.detent = .fraction(heightRatio)
        self.style = style
        self.showsDimmedBackground = showsDimmedBackground
        self.sizesToFitContent = sizesToFitContent
        self.allowsDismissOnDrag = allowsDismissOnDrag
        self.showsGrabber = showsGrabber
        self.dismissThreshold = dismissThreshold
        self.content = content
    }

    public init(
        isPresented: Binding<Bool>,
        detent: DrawerDetent,
        style: DrawerStyle = .system,
        showsDimmedBackground: Bool = false,
        sizesToFitContent: Bool = false,
        allowsDismissOnDrag: Bool = true,
        showsGrabber: Bool = true,
        dismissThreshold: CGFloat = 120,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.detent = detent
        self.style = style
        self.showsDimmedBackground = showsDimmedBackground
        self.sizesToFitContent = sizesToFitContent
        self.allowsDismissOnDrag = allowsDismissOnDrag
        self.showsGrabber = showsGrabber
        self.dismissThreshold = dismissThreshold
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if showsDimmedBackground && isPresented {
                    style.dimColor
                        .ignoresSafeArea()
                        .onTapGesture { dismiss() }
                        .transition(.opacity)
                }

                if isPresented {
                    drawer(in: geometry)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(style.animation, value: isPresented)
        }
    }

    private func drawer(in geometry: GeometryProxy) -> some View {
        let maxHeight = detent.maxHeight(in: geometry.size.height)
        let grabberHeight: CGFloat = showsGrabber ? 44 : 0
        let maxContentHeight = max(maxHeight - grabberHeight, 0)
        let fittedContentHeight = min(contentHeight, maxContentHeight)
        let shouldFitContent = sizesToFitContent || detent == .content
        let shouldScroll = shouldFitContent && contentHeight > maxContentHeight
        let drawerHeight = shouldFitContent ? grabberHeight + fittedContentHeight : maxHeight
        let shape = RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)

        return DrawerChrome(style: style, shape: shape) {
            VStack(spacing: 0) {
                if showsGrabber {
                    DrawerGrabber(style: style)
                }

                if shouldFitContent {
                    if shouldScroll {
                        ScrollView(showsIndicators: false) {
                            measuredContent
                        }
                        .frame(height: fittedContentHeight)
                    } else {
                        measuredContent
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        measuredContent
                    }
                    .frame(height: maxContentHeight)
                }
            }
        }
        .frame(
            width: geometry.size.width - (style.horizontalPadding * 2),
            height: shouldFitContent && contentHeight > 0 ? drawerHeight : maxHeight
        )
        .padding(.horizontal, style.horizontalPadding)
        .padding(.bottom, style.bottomPadding)
        .offset(y: rubberBandedDragOffset)
        .animation(style.animation, value: drawerHeight)
        .animation(style.animation, value: dragOffset)
        .gesture(dragGesture)
    }

    private var rubberBandedDragOffset: CGFloat {
        if dragOffset >= 0 {
            return dragOffset
        }

        return -rubberBand(abs(dragOffset), limit: 72)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                guard allowsDismissOnDrag else { return }

                if value.translation.height > dismissThreshold || value.predictedEndTranslation.height > dismissThreshold * 1.5 {
                    dismiss()
                }
            }
    }

    private func rubberBand(_ distance: CGFloat, limit: CGFloat) -> CGFloat {
        guard distance > 0 else { return 0 }
        return (1 - (1 / ((distance * 0.55 / limit) + 1))) * limit
    }

    private var measuredContent: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding(style.contentPadding)
            .readHeight($contentHeight)
    }

    private func dismiss() {
        withAnimation(style.animation) {
            isPresented = false
        }
    }
}

private struct DrawerChrome<Content: View>: View {
    let style: DrawerStyle
    let shape: RoundedRectangle
    let content: Content

    init(style: DrawerStyle, shape: RoundedRectangle, @ViewBuilder content: () -> Content) {
        self.style = style
        self.shape = shape
        self.content = content()
    }

    var body: some View {
        content
            .background(background)
            .overlay(shape.stroke(style.borderColor, lineWidth: style.usesLiquidGlass ? 1 : 0))
            .clipShape(shape)
            .contentShape(shape)
            .shadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 14)
        .compositingGroup()
    }

    @ViewBuilder private var background: some View {
        if style.usesLiquidGlass {
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.fill(style.backgroundColor))
        } else {
            shape.fill(style.backgroundColor)
        }
    }
}

private struct DrawerGrabber: View {
    let style: DrawerStyle

    var body: some View {
        ZStack {
            Capsule()
                .fill(style.grabberColor)
                .frame(width: style.grabberSize.width, height: style.grabberSize.height)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
    }
}

public struct DrawerImageItem: Identifiable {
    public let id: String
    public var title: String
    public var text: String
    public var imageURL: URL?

    public init(
        id: String,
        title: String,
        text: String,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.imageURL = imageURL
    }
}

public struct DrawerImageDetailView: View {
    private let item: DrawerImageItem

    public init(item: DrawerImageItem) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.system(size: 34, weight: .regular))

            Text(item.text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundColor(.primary)
        }
    }
}

public struct MorphingImageDrawerView<Thumbnail: View, Detail: View>: View {
    @Binding private var isPresented: Bool
    @Binding private var selectedItemID: String?

    private let items: [DrawerImageItem]
    private let style: DrawerStyle
    private let thumbnail: (DrawerImageItem) -> Thumbnail
    private let detail: (DrawerImageItem) -> Detail

    public init(
        isPresented: Binding<Bool>,
        selectedItemID: Binding<String?>,
        items: [DrawerImageItem],
        style: DrawerStyle = .system,
        @ViewBuilder thumbnail: @escaping (DrawerImageItem) -> Thumbnail,
        @ViewBuilder detail: @escaping (DrawerImageItem) -> Detail
    ) {
        self._isPresented = isPresented
        self._selectedItemID = selectedItemID
        self.items = items
        self.style = style
        self.thumbnail = thumbnail
        self.detail = detail
    }

    public var body: some View {
        DrawerView(
            isPresented: $isPresented,
            detent: selectedItem == nil ? .fraction(0.62) : .fraction(0.82),
            style: style,
            showsDimmedBackground: true,
            sizesToFitContent: true
        ) {
            Group {
                if let selectedItem {
                    MorphingImageDetail(
                        item: selectedItem,
                        thumbnail: thumbnail,
                        detail: detail,
                        onBack: showGrid
                    )
                    .id("detail-\(selectedItem.id)")
                    .transition(.drawerScaleFade(anchor: .center))
                } else {
                    MorphingImageGrid(
                        items: items,
                        thumbnail: thumbnail,
                        onSelect: select
                    )
                    .id("grid")
                    .transition(.drawerScaleFade(anchor: .center))
                }
            }
            .animation(style.animation, value: selectedItemID)
        }
    }

    private var selectedItem: DrawerImageItem? {
        items.first { $0.id == selectedItemID }
    }

    private func select(_ item: DrawerImageItem) {
        withAnimation(style.animation) {
            selectedItemID = item.id
        }
    }

    private func showGrid() {
        withAnimation(style.animation) {
            selectedItemID = nil
        }
    }
}

public extension MorphingImageDrawerView where Detail == DrawerImageDetailView {
    init(
        isPresented: Binding<Bool>,
        selectedItemID: Binding<String?>,
        items: [DrawerImageItem],
        style: DrawerStyle = .system,
        @ViewBuilder thumbnail: @escaping (DrawerImageItem) -> Thumbnail
    ) {
        self.init(
            isPresented: isPresented,
            selectedItemID: selectedItemID,
            items: items,
            style: style,
            thumbnail: thumbnail
        ) { item in
            DrawerImageDetailView(item: item)
        }
    }
}

public extension View {
    func drawer<DrawerContent: View>(
        isPresented: Binding<Bool>,
        detent: DrawerDetent = .content,
        style: DrawerStyle = .system,
        showsDimmedBackground: Bool = true,
        sizesToFitContent: Bool = true,
        allowsDismissOnDrag: Bool = true,
        showsGrabber: Bool = true,
        dismissThreshold: CGFloat = 120,
        @ViewBuilder content: @escaping () -> DrawerContent
    ) -> some View {
        overlay {
            DrawerView(
                isPresented: isPresented,
                detent: detent,
                style: style,
                showsDimmedBackground: showsDimmedBackground,
                sizesToFitContent: sizesToFitContent,
                allowsDismissOnDrag: allowsDismissOnDrag,
                showsGrabber: showsGrabber,
                dismissThreshold: dismissThreshold,
                content: content
            )
        }
    }
}

private struct MorphingImageGrid<Thumbnail: View>: View {
    let items: [DrawerImageItem]
    let thumbnail: (DrawerImageItem) -> Thumbnail
    let onSelect: (DrawerImageItem) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    MorphingImageSurface(
                        item: item,
                        aspectRatio: 1,
                        thumbnail: thumbnail
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct MorphingImageDetail<Thumbnail: View, Detail: View>: View {
    let item: DrawerImageItem
    let thumbnail: (DrawerImageItem) -> Thumbnail
    let detail: (DrawerImageItem) -> Detail
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Back")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Capsule().fill(Color.primary.opacity(0.06)))
            }
            .buttonStyle(.plain)

            MorphingImageSurface(
                item: item,
                aspectRatio: 1.35,
                thumbnail: thumbnail
            )
            .onTapGesture(perform: onBack)

            detail(item)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MorphingImageSurface<Thumbnail: View>: View {
    let item: DrawerImageItem
    let aspectRatio: CGFloat
    let thumbnail: (DrawerImageItem) -> Thumbnail

    var body: some View {
        ZStack {
            thumbnail(item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .compositingGroup()
    }
}

public extension Color {
    static var drawerKitSurface: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
}

private struct DrawerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    func readHeight(_ height: Binding<CGFloat>) -> some View {
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

private extension AnyTransition {
    static func drawerScaleFade(anchor: UnitPoint) -> AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.96, anchor: anchor).combined(with: .opacity),
            removal: .scale(scale: 0.985, anchor: anchor).combined(with: .opacity)
        )
    }
}

// MARK: - Preview
struct DrawerView_Previews: PreviewProvider {
    static var previews: some View {
        DrawerPreview()
    }

    struct DrawerPreview: View {
        @State private var showDrawer = true
        @State private var selectedItemID: String?

        private let drawerStyle = DrawerStyle(
            horizontalPadding: 8,
            bottomPadding: 8,
            contentPadding: EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )

        private let items = [
            DrawerImageItem(
                id: "one",
                title: "Title",
                text: "Lorem ipsum dolor sit amet consectetur. Lacus pellentesque pellentesque cum vitae libero mus ultrices semper. Mauris etiam interdum enim ac diam. Nullam enim eros a ac non dignissim.",
                imageURL: URL(string: "https://plus.unsplash.com/premium_photo-1726761631659-093dac06086a?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
            ),
            DrawerImageItem(
                id: "two",
                title: "Title",
                text: "Feugiat rhoncus at nunc vel viverra tortor ultricies in. Amet vitae at laoreet risus ac nunc elementum sit in. Amet lectus dis integer adipiscing nec id fermentum mi.",
                imageURL: URL(string: "https://images.unsplash.com/photo-1620282063281-87ae675d2dbf?q=80&w=1421&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
            ),
            DrawerImageItem(
                id: "three",
                title: "Title",
                text: "Eu tincidunt malesuada praesent varius turpis proin eu. Vitae eget nunc amet facilisis sed. Integer sed lorem id massa volutpat gravida.",
                imageURL: URL(string: "https://images.unsplash.com/photo-1779766342185-677b42fd175d?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
            ),
            DrawerImageItem(
                id: "four",
                title: "Title",
                text: "Lacus pellentesque pellentesque cum vitae libero mus ultrices semper. Mauris etiam interdum enim ac diam. Nullam enim eros a ac non dignissim.",
                imageURL: URL(string: "https://images.unsplash.com/photo-1778332349930-6f4d4027f5f8?q=80&w=686&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
            )
        ]

        var body: some View {
            ZStack {
                Color.gray.opacity(0.28)
                    .ignoresSafeArea()

                Button("Toggle Drawer") {
                    withAnimation {
                        showDrawer.toggle()
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(Color.black.opacity(0.65)))
                .cornerRadius(12)

                MorphingImageDrawerView(
                    isPresented: $showDrawer,
                    selectedItemID: $selectedItemID,
                    items: items,
                    style: drawerStyle
                ) { item in
                    RemoteDrawerImage(url: item.imageURL)
                } detail: { item in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(item.title)
                            .font(.system(size: 34, weight: .regular))

                        Text(item.text)
                            .font(.system(size: 15))
                            .lineSpacing(4)

                        HStack(spacing: 10) {
                            Button("Primary") {}
                                .buttonStyle(.borderedProminent)

                            Button("Secondary") {}
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
    }

    struct RemoteDrawerImage: View {
        let url: URL?

        var body: some View {
            GeometryReader { proxy in
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    case .failure:
                        Color.gray.opacity(0.34)
                    case .empty:
                        Color.gray.opacity(0.24)
                    @unknown default:
                        Color.gray.opacity(0.24)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        }
    }
}
