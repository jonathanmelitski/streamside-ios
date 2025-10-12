//
//  Landing.swift
//
//  Created by Jonathan Melitski on 6/7/25.
//

import SwiftUI
import USGSShared

public struct LandingView: View {
    @State var animationState: LandingAnimationState = .intro
    @ObservedObject var vm = SharedViewModel.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Image("Beaverkill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 4)
            Group {
                switch animationState {
                case .intro:
                    IntroView(state: $animationState)
                case .enterPhoneNumber:
                    PhoneNumberView()
                case .enterCode:
                    VerificationCodeView(state: $animationState)
                case .error:
                    Text("Error")
                }
                
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 64)
                    .fill(.thinMaterial)
                    .shadow(radius: 32)
            }
            .frame(width: 350)
        }
        .onChange(of: vm.awaitingVerificationCodeContinuation) {
            if case .awaiting(_, _) = vm.awaitingVerificationCodeContinuation {
                self.animationState = .enterCode
            }
        }
    }
}

enum LandingAnimationState: Int, Equatable, CaseIterable {
    case intro = 0
    case enterPhoneNumber = 1
    case enterCode = 2
    case error = 4
}

#Preview {
    LandingView()
}
