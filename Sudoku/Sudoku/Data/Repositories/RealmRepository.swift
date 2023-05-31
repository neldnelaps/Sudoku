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
        let sudokuLoad = realm.object(ofType: SudokuClass.self, forPrimaryKey: sudoku.description)

         if sudokuLoad != nil {
            return
         } else {
             try! realm.write {
                 realm.create(SudokuClass.self, value: sudoku, update: .modified)
             }
         }
    }
    
    func loadStorage() -> SudokuClass? {
        do {
            let res = realm.object(ofType: SudokuClass.self, forPrimaryKey: SudokuClass.uniqueKey)
            return res
        } catch let error as NSError {
            print("Error load: \(error)")
        }
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
