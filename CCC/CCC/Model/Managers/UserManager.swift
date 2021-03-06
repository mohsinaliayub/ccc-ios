//
//  UserManager.swift
//  CCC
//
//  Created by Mohsin Ali Ayub on 19.04.22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum FirestoreError: String, Error {
    case recordNotFound = "Record not found in the data store."
}

protocol UserManager {
    func saveUser(user: User, completion: @escaping (Error?) -> Void)
    
    func fetchUser(byId: String, completion: @escaping (User?, FirestoreError?) -> Void)
}

class FirestoreUserManager: UserManager {
    
    private let usersCollection = Firestore.firestore().collection("Users")
    
    func saveUser(user: User, completion: @escaping (Error?) -> Void) {
        usersCollection.document(user.id).setData(user.dictionary) { error in
            completion(error)
        }
    }
    
    func fetchUser(byId userId: String, completion: @escaping (User?, FirestoreError?) -> Void) {
        usersCollection.document(userId).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, error == nil else {
                completion(nil, .recordNotFound)
                return
            }
            
            guard let userData = snapshot.data() else { return }
            
            let user = User(from: userData)
            completion(user, nil)
        }
    }
    
}
