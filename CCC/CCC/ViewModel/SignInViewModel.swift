//
//  SignInViewModel.swift
//  CCC
//
//  Created by Mohsin Ali Ayub on 21.04.22.
//

import Foundation
import Combine
import SwiftUI

class SignInViewModel: ObservableObject {
    
    @Published var email: String
    @Published var password: String
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var signInError: SignInError?
    @Published var signInSuccessful = false
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let mediaManager: MediaManager
    private var cancellable = Set<AnyCancellable>()
    private var isInputValid: Bool {
        isEmailValid && isPasswordValid
    }
    
    var dashboardViewModel: MainViewModel {
        MainViewModel(authManager: authManager, userManager: userManager, mediaManager: mediaManager)
    }
    
    var signUpViewModel: SignUpViewModel {
        SignUpViewModel(authManager: authManager, mediaManager: mediaManager, userManager: userManager)
    }
    
    init(authManager: AuthManager, userManager: UserManager, mediaManager: MediaManager) {
        email = ""; password = ""
        self.authManager = authManager
        self.userManager = userManager
        self.mediaManager = mediaManager
        
        setupSubscriptionChainForValidation()
    }
    
    func signIn() {
        signInError = nil
        guard isInputValid else { return }
        
        authManager.signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                self.signInError = error
                return
            }
            
            self.signInSuccessful = true
        }
    }
    
    func setupSubscriptionChainForValidation() {
        $email
            .receive(on: RunLoop.main)
            .map { email in
                EmailValidator.validate(with: email)
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellable)
        
        $password
            .receive(on: RunLoop.main)
            .map { password in
                PasswordValidator.validate(password)
            }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellable)
    }
    
    func submit(form: inout Form?) {
        switch form {
        case .email:
            form = .password
        case .password:
            form = .signIn
            fallthrough
        case .signIn:
            signIn()
        default:
            break
        }
    }
    
    enum Form {
        case email
        case password
        case signIn
    }
    
}
