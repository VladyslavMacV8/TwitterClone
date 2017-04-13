//
//  ViewModel.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/13/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import RealmSwift

class RealmViewModel {
    func setCurrentUser(user: User) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user, update: true)
            }
        } catch { print("not user") }
    }
    
    func getCurrentUser() -> User {
        let userDefaults = UserDefaults.standard
        let id = userDefaults.integer(forKey: "id")
        userDefaults.synchronize()
        var user: User!
        do {
            let realm = try Realm()
            user = realm.object(ofType: User.self, forPrimaryKey: id)
        } catch { print("error current user") }
        
        return user
    }
    
    func deleteCurrentUser() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch { print("not user") }
    }
}
