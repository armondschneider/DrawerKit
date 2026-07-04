import SwiftUI

public struct DemoView: View {
    @State private var isDrawerPresented = false
    @State private var screen: ScheduleDemoScreen = .schedule
    @State private var selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var selectedTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    private let drawerStyle = DrawerStyle(
        cornerRadius: 40,
        horizontalPadding: 16,
        bottomPadding: 16,
        backgroundColor: .drawerKitSurface.opacity(0.16),
        borderColor: .white.opacity(0.24),
        contentPadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        animation: .spring(response: 0.44, dampingFraction: 0.72, blendDuration: 0.08)
    )

    public init() {}

    public var body: some View {
        ZStack {
            Color.drawerKitSystemGray6
                .ignoresSafeArea()

            Button {
                withAnimation(drawerStyle.animation) {
                    screen = .schedule
                    isDrawerPresented = true
                }
            } label: {
                Text("Show Drawer")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.blue, in: Capsule(style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .drawer(
            isPresented: $isDrawerPresented,
            detent: .content,
            style: drawerStyle,
            control: .none
        ) {
            drawerContent
        }
    }

    private var drawerContent: some View {
        VStack(spacing: 0) {
            header

            ZStack {
                switch screen {
                case .schedule:
                    scheduleSummary
                        .id(ScheduleDemoScreen.schedule)
                        .transition(.drawerBlurFadeMove)
                case .date:
                    datePickerView
                        .id(ScheduleDemoScreen.date)
                        .transition(.drawerBlurFadeMove)
                case .time:
                    timePickerView
                        .id(ScheduleDemoScreen.time)
                        .transition(.drawerBlurFadeMove)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .animation(drawerStyle.animation, value: screen)
    }

    private var header: some View {
        ZStack {
            Text(screen.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .transition(.drawerBlurFade)

            HStack {
                if screen == .schedule {
                    DrawerHeaderIconButton(systemName: "xmark", accessibilityLabel: "Close") {
                        withAnimation(drawerStyle.animation) {
                            isDrawerPresented = false
                        }
                    }
                } else {
                    DrawerBackButton {
                        withAnimation(drawerStyle.animation) {
                            screen = .schedule
                        }
                    }
                }

                Spacer(minLength: 0)

                if screen == .schedule {
                    DrawerApplyButton {
                        withAnimation(drawerStyle.animation) {
                            isDrawerPresented = false
                        }
                    }
                }
            }
        }
        .frame(height: 54)
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    private var scheduleSummary: some View {
        VStack(spacing: 28) {
            VStack(spacing: 0) {
                ScheduleRow(
                    icon: "calendar",
                    iconColor: .red,
                    title: "Date",
                    value: dateSummary
                ) {
                    withAnimation(drawerStyle.animation) {
                        screen = .date
                    }
                }

                ScheduleRow(
                    icon: "clock.fill",
                    iconColor: .blue,
                    title: "Time",
                    value: timeSummary
                ) {
                    withAnimation(drawerStyle.animation) {
                        screen = .time
                    }
                }
            }
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            ScheduleRow(
                icon: "repeat",
                iconColor: .gray,
                title: "Repeat",
                value: "Never"
            ) {}
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var datePickerView: some View {
        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(.blue)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity)
    }

    private var timePickerView: some View {
        #if os(iOS)
        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(.blue)
            .frame(height: 190)
            .clipped()
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        #else
        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(.blue)
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        #endif
    }

    private var dateSummary: String {
        let calendar = Calendar.current

        if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        }

        return selectedDate.formatted(.dateTime.month(.wide).day().year())
    }

    private var timeSummary: String {
        selectedTime.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())
    }
}

private enum ScheduleDemoScreen: Hashable {
    case schedule
    case date
    case time

    var title: String {
        switch self {
        case .schedule: return "Schedule"
        case .date: return "Date"
        case .time: return "Time"
        }
    }
}

private struct ScheduleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(iconColor.gradient, in: Circle())

                Text(title)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer(minLength: 12)

                Text(value)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundStyle(value == "Never" ? Color.secondary : Color.blue)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .frame(height: 62)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DrawerBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 36, height: 36)
                .background(Color.drawerKitSystemGray6, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

private struct DrawerHeaderIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(.black)
                .frame(width: 36, height: 36)
                .background(Color.drawerKitSystemGray6, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct DrawerApplyButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.black, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Apply")
    }
}

private struct DrawerSmoothTransitionModifier: ViewModifier {
    let opacity: Double
    let scale: CGFloat
    let yOffset: CGFloat
    let blurRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(y: yOffset)
            .blur(radius: blurRadius)
    }
}

private extension AnyTransition {
    static var drawerBlurFade: AnyTransition {
        .modifier(
            active: DrawerSmoothTransitionModifier(opacity: 0, scale: 0.98, yOffset: 0, blurRadius: 8),
            identity: DrawerSmoothTransitionModifier(opacity: 1, scale: 1, yOffset: 0, blurRadius: 0)
        )
    }

    static var drawerBlurFadeMove: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: DrawerSmoothTransitionModifier(opacity: 0, scale: 1.02, yOffset: 18, blurRadius: 10),
                identity: DrawerSmoothTransitionModifier(opacity: 1, scale: 1, yOffset: 0, blurRadius: 0)
            ),
            removal: .modifier(
                active: DrawerSmoothTransitionModifier(opacity: 0, scale: 0.98, yOffset: -18, blurRadius: 10),
                identity: DrawerSmoothTransitionModifier(opacity: 1, scale: 1, yOffset: 0, blurRadius: 0)
            )
        )
    }
}

#Preview {
    DemoView()
}
