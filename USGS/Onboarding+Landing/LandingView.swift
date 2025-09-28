//
//  Landing.swift
//
//  Created by Jonathan Melitski on 6/7/25.
//

import SwiftUI

public struct LandingView: View {
    @State var animationState: LandingAnimationState = .intro
    
    public init() {}
    
    public var body: some View {
        switch animationState {
        case .intro:
            IntroView(state: $animationState)
        case .enterPhoneNumber:
            Text("PN")
        case .enterCode:
            Text("code")
        case .welcome:
            Text("Welcome")
        case .error:
            Text("Error")
        }
    }
}

enum LandingAnimationState: Int, Equatable, CaseIterable {
    case intro = 0
    case enterPhoneNumber = 1
    case enterCode = 2
    case welcome = 3
    case error = 4
}

#Preview {
    LandingView()
}
