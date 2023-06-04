//
//  RealmRepository.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation
import RealmSwift

class BaseRealmRepository {
    
    fileprivate var realm: Realm {
        return try! Realm()
    }

}

class RealmRepository : BaseRealmRepository, RealmRepositoryProtocol {
    
    func saveStorage(sudoku: SudokuClass) {
        if realm.object(ofType: SudokuClass.self, forPrimaryKey: sudoku.description) != nil {
            return
        }

        try! realm.write {
            realm.create(SudokuClass.self, value: sudoku, update: .modified)
        }
    }
    
    func loadStorage() -> SudokuClass? {
        let res = realm.object(ofType: SudokuClass.self, forPrimaryKey: SudokuClass.uniqueKey)
        return res
    }
    
    func removeStorage() {
        do {
            try realm.write {
                realm.deleteAll()
                realm.refresh()
            }
        }
        catch let error as NSError {
            print("Error delete: \(error)")
        }
    }
    
}
