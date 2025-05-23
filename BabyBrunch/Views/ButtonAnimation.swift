//
//  ButtonAnimation.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-23.
//

import SwiftUI

struct ButtonAnimation: View {
        @Binding var trigger: Bool
        @State private var offsetX: CGFloat = -300

        var body: some View {
            GeometryReader { geo in
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0),
                        .white.opacity(0.6),
                        .white.opacity(0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .rotationEffect(.degrees(30))
                .offset(x: offsetX)
                .onChange(of: trigger) { newValue in
                    if newValue {
                        offsetX = -geo.size.width * 2
                        withAnimation(.linear(duration: 0.5)) {
                            offsetX = geo.size.width
                        }
                    }
                }
            }
        }
    }

//#Preview {
//    ButtonAnimation()
//}
