//
//  VerificationCodeView.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/9/25.
//

import SwiftUI
import USGSShared

struct VerificationCodeView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @Binding var state: LandingAnimationState
    @State var verificationCode: String = ""
    @State var disabled = false
    @State var invalid = false
    
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Enter the code that\nwas sent to you!")
                .multilineTextAlignment(.center)
                .font(.system(size: 24))
                .fontDesign(.serif)
            Group {
                if !disabled {
                    TextField("6-digit Code", text: $verificationCode)
                        .disabled(disabled)
                        .onSubmit {
                            guard case .awaiting(let cont, _) = vm.awaitingVerificationCodeContinuation, !disabled else { return }
                            self.disabled = true
                            cont.resume(returning: verificationCode)
                        }
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .textContentType(.oneTimeCode)
                } else {
                    ProgressView()
                }
            }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThickMaterial)
                        .strokeBorder(.red, lineWidth: invalid ? 2 : 0)
                        .shadow(radius: 8)
                    
                }
                .frame(width: 200, height: 60)
        }
        .onChange(of: vm.awaitingVerificationCodeContinuation) {
            guard case .awaiting(_, let att) = vm.awaitingVerificationCodeContinuation else { return }
            if att > 1 {
                disabled = false
                verificationCode = ""
                withAnimation {
                    invalid = true
                }
            }
        }
    }
}
