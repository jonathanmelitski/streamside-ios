//
//  AuthTestView.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/28/25.
//

import SwiftUI
import USGSShared

struct AuthTestView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @State var code = ""
    
    var body: some View {
        VStack {
            Text("Phone!")
            if vm.currentUser == nil {
                Button("sendy") {
                    Task {
                        do {
                            try await vm.requestNewSignIn(with: "+18458024170")
                        } catch {
                            print(error)
                        }
                    }
                }
                
                if let cont = vm.awaitingVerificationCodeContinuation {
                    TextField("Code", text: $code, prompt: Text("Enter 6-digit Code"))
                    Button("Verify") {
                        cont.resume(returning: code)
                    }
                }
            } else {
                Text("Worky!")
            }
        }
    }
}
