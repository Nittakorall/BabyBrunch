// Does error handling when it comes to login in, registering, and guest account access

import FirebaseAuth
import Foundation

//❗❗❗TODO: please add more as we add features❗❗❗
// each case has it's own error message, these are the names we use in our project
enum AuthErrorHandler: LocalizedError, Identifiable, Equatable {
    case emailInvalid
    case emailAlreadyInUse
    case emailEmpty
    case passwordTooShort
    case passwordIncorrect
    case passwordMismatch
    case userNotFound
    case credentialsInvalid
    case guestNotAllowed
    case networkError
    case unknown(_ debugMessage: String)
    
    var id: String { localizedDescription }
    
    // contains the strings for the cases above
    var errorDescription: String? {
        switch self {
        case .emailInvalid: return "Please enter a functional email address"
        case .emailAlreadyInUse: return "An account using that email already exists"
        case .emailEmpty: return "Cannot leave fields empty"
        case .passwordTooShort: return "The password must consist of at least six characters"
        case .passwordIncorrect: return "Wrong password"
        case .passwordMismatch: return "Passwords do not match"
        case .userNotFound: return "There is no account connected to that email address"
        case .credentialsInvalid: return "Password or email is incorrect"
        case .guestNotAllowed: return "Login or register a user to use this feature"
        case .networkError: return "Network error, check your connection before retrying"
        case .unknown(let msg): return "Something went wrong: \(msg)"
        }
    }
}

// connects Firebase's AuthErrorCode to our ErrorHandler enum case names
extension AuthErrorHandler {
   
    static func from(_ error: Error) -> AuthErrorHandler {
        guard let code = AuthErrorCode.Code(rawValue: (error as NSError).code) else {
            return .unknown(error.localizedDescription)
        }
        // .onTheLeft is how Firebase names it, the one on the right is from us (the cases above)
        switch code {
        case .invalidEmail: return .emailInvalid
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .missingEmail: return .emailEmpty
        case .weakPassword: return .passwordTooShort
        case .wrongPassword: return .passwordIncorrect
        case .userNotFound: return .userNotFound
        case .invalidCredential: return .credentialsInvalid
        case .networkError: return .networkError
        default: return .unknown(error.localizedDescription)
        }
    }
}
