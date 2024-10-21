//
//  DrawerView.swift
//  DrawerKit
//
//  Created by Armond Schneider on 10/21/24.
//

import SwiftUI

public struct DrawerView<Content: View>: View {
    @Binding private var isPresented: Bool
    private let heightRatio: CGFloat
    private let content: () -> Content

    public init(
        isPresented: Binding<Bool>,
        heightRatio: CGFloat = 0.5, // Default to half the screen height
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.heightRatio = heightRatio
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Push drawer to the bottom

                VStack {
                    Capsule()
                        .frame(width: 30, height: 8)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.top, 8)
                    
                    content() // User-defined content inside the drawer
                        .frame(maxWidth: .infinity) // Center content horizontally
                        .padding()
                }
                .frame(
                    width: geometry.size.width - 32, // Side margins
                    height: geometry.size.height * heightRatio
                )
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color(.systemBackground))
                )
                .padding(.bottom, geometry.safeAreaInsets.bottom + -12) // Safe area padding
                .offset(y: isPresented ? 0 : geometry.size.height) // Slide animation
                .animation(.spring(), value: isPresented)
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.height > 100 {
                                withAnimation { isPresented = false }
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity) // Center drawer horizontally
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - Preview
struct DrawerView_Previews: PreviewProvider {
    static var previews: some View {
        DrawerPreview()
    }

    struct DrawerPreview: View {
        @State private var showDrawer = true

        var body: some View {
            ZStack {
                Color.gray.opacity(0.3) // Background for the preview
                    .ignoresSafeArea()

                Button("Toggle Drawer") {
                    withAnimation {
                        showDrawer.toggle()
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)

                DrawerView(isPresented: $showDrawer, heightRatio: 0.4) {
                    VStack {
                        Text("Drawer Content")
                            .font(.title)
                            .padding(.bottom, 10)
                        
                        Button("Close Drawer") {
                            withAnimation {
                                showDrawer = false
                            }
                        }
                    }
                }
            }
        }
    }
}
