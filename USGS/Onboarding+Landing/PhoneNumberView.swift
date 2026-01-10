//
//  PhoneNumberView.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/9/25.
//

import SwiftUI
import USGSShared
import PhoneNumberKit

struct PhoneNumberView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @State var phoneNumber: String = ""
    @State var valid = true
    
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Enter your phone\nnumber to get started!")
                .multilineTextAlignment(.center)
                .font(.system(size: 24))
                .fontDesign(.serif)
            
            TextField("Phone Number", text: $phoneNumber)
                .onSubmit {
                    guard let number = try? PhoneNumberUtility().parse(phoneNumber, withRegion: "US") else { return }
                    Task {
                        try? await vm.requestNewSignIn(with: PhoneNumberUtility().format(number, toType: .e164))
                    }
                }
                .font(.system(size: 28, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .textContentType(.telephoneNumber)
                .submitLabel(.send)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThickMaterial)
                        .stroke(.red, lineWidth: valid ? 0 : 2)
                        .shadow(radius: 8)
                }
                .onChange(of: phoneNumber) {
                    let number = try? PhoneNumberUtility().parse(phoneNumber, withRegion: "US")
                    withAnimation {
                        self.valid = number != nil
                    }
                    return
                }
        }
    }
}
