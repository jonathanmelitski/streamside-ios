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
            VStack {
                Image("Streamside")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .shadow(radius: 8)
                Text("Streamside")
                    .font(.largeTitle)
                    .bold()
                    .fontDesign(.serif)
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
                        .shadow(radius: 8)
                }
            }
            .buttonStyle(.borderless)
            .disabled(buttonDisabled)
        }
    }
}
