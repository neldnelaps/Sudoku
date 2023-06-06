//
//  GameViewModel.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation

class GameViewModel {
    
    private let realmUsecase: RealmUsecase

    init(realmUsecase: RealmUsecase) {
        self.realmUsecase = realmUsecase
    }

    func saveSudoku(sudoku: SudokuClass) {
        realmUsecase.saveStorage(sudoku: sudoku)
    }
    
    func removeSudoku() {
        realmUsecase.removeStorage()
    }
    
}
