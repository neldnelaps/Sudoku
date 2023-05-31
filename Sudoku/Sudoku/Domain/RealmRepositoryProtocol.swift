//
//  RealmRepositoryProtocol.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation

protocol RealmRepositoryProtocol {
    
    func saveStorage(sudoku: SudokuClass)
    func loadStorage() -> SudokuClass?
    func removeStorage()
    
}
