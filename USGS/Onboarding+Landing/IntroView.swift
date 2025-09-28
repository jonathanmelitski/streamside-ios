//
//  IntroView.swift
//
//  Created by Jonathan Melitski on 6/7/25.
//

import SwiftUI
import USGSShared

struct IntroView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @Binding var state: LandingAnimationState
    @State var shouldAnimate: Bool = false
    @State var buttonDisabled: Bool = false
    
    var body: some View {
        VStack {
            Text("Streamside")
                .multilineTextAlignment(.center)
                .font(.system(size: 48))
                .keyframeAnimator(
                    initialValue: AnimationValues(), trigger: shouldAnimate) { content, value in
                        content
                            .scaleEffect(value.scale)
                            .offset(y: value.vertOffset)
                            .opacity(value.opacity)
                    } keyframes: { _ in
                        KeyframeTrack(\.scale) {
                            LinearKeyframe(1.3, duration: 1.0, timingCurve: .easeInOut)
                            LinearKeyframe(1.3, duration: 1.0)
                            LinearKeyframe(1.0, duration: 0.2, timingCurve: .easeOut)
                        }
                        
                        KeyframeTrack(\.vertOffset) {
                            LinearKeyframe(0, duration: 2.1)
                            LinearKeyframe(-75, duration: 0.3, timingCurve: .easeOut)
                        }
                        
                        KeyframeTrack(\.opacity) {
                            LinearKeyframe(1.0, duration: 0.75)
                        }
                    }
            Button {
                withAnimation {
                    state = .enterPhoneNumber
                }
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    Rectangle()
                        .mask {
                            Image(systemName: "phone")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        .frame(width: 15, height: 15)
                    Text("Sign in")
                        .fontDesign(.default)
                        .bold()
                }
                .foregroundStyle(Color(UIColor.systemBackground))
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.borderless)
            .disabled(buttonDisabled)
            .keyframeAnimator(initialValue: AnimationValues(vertOffset: -75), trigger: shouldAnimate) { content, value in
                content
                    .scaleEffect(value.scale)
                    .offset(y: value.vertOffset)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0, duration: 2.1)
                    LinearKeyframe(1, duration: 0.3, timingCurve: .easeInOut)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: 2.1)
                    LinearKeyframe(1, duration: 0.2, timingCurve: .easeInOut)
                }
            }
        }
        .onAppear {
            shouldAnimate = true
            buttonDisabled = false
        }
    }
    
    struct AnimationValues {
        var scale: Double = 0.0
        var vertOffset: Double = 0.0
        var opacity: Double = 0.0
    }
}
