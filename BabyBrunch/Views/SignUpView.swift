//
//  SignUpView.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @EnvironmentObject private var authVM : AuthViewModel
    
    @State private var balloons: [FloatingBalloon] = []
    
    
    var body: some View {
        //background
        ZStack{
            
            ForEach(balloons) { balloon in
                BalloonEmoji()
                    .offset(x: balloon.xOffset)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                balloons.removeAll { $0.id == balloon.id }
                            }
                        }
                    }
            }
            
            Color("lavenderBlush")
                .ignoresSafeArea()
            //logo
            VStack{
                Text("BABYBrunch")
                    .padding(.top, 50)
                    .padding(.bottom, 50)
                    .fontDesign(.rounded)
                    .font(.title)
                    .foregroundColor(Color("oldRose"))
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Email")
                    
                    //email input field
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    
                    Text("Password")
                    //password input field
                    SecureField("Password", text: $password)
                    
                        .textContentType(.password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Text("Confirm password")
                    //password confirmation field
                    SecureField("Confirm password", text: $confirmPassword)
                    
                        .textContentType(.password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    //Sign up button
                    Button("register") {
                        register()
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 10)
                    .padding()
                    .background(Color("oldRose"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.top, 70)
                }
                
                //white space in the middle of the screen
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(width: 300, height: 500)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
            }
            //MARK: alerts are handled here:
            .alert(item: $authVM.authError) {
                err in
                Alert(title: Text("Error"), message: Text(err.localizedDescription), dismissButton: .default(Text("OK")){ authVM.authError = nil })
            }
            
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
    
    // guard sections can be removed if we do not want frontend to handle these error alerts. When removed, the '.alert' above will display errors from the firebase server instead
    func register() {
        guard !email.isEmpty else {
            authVM.authError = .emailEmpty
            return
        }
        guard password.count >= 6 else {
            authVM.authError = .passwordTooShort
            return
        }
        guard password == confirmPassword else {
            authVM.authError = .passwordMismatch
            return
        }
        
        let newBalloon = FloatingBalloon(xOffset: CGFloat.random(in: -100...100))
           withAnimation {
               balloons.append(newBalloon)
           }
        
        authVM.signUpWithEmail(email: email, password: password){ success in
            if success{
                authVM.signIn(email: email, password: password)
            } else {
                if authVM.authError == nil {
                    assertionFailure("signUpWithEmail returned false with no authError") //will not display to the user, only shows up in the log. ⚠️⚠️⚠️ This will crash the app when debugging (running the simulation), that is intended
                }
            }
        }
        
    }
    
}

struct FloatingBalloon: Identifiable {
    let id = UUID()
    var xOffset: CGFloat
}

struct BalloonEmoji: View {
    @State private var yOffset: CGFloat = 300
    @State private var opacity: Double = 1

    var body: some View {
        Text("🎈")
            .font(.system(size: 40))
            .offset(y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2.5)) {
                    yOffset = -200
                    opacity = 0
                }
            }
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(isSignedUp: .init(get: { true }, set: { _ in }))
//    }
//}
