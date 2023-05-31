//
//  MainViewModel.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation

class MainViewModel {
    
    private let realmUsecase: RealmUsecase

    init(realmUsecase: RealmUsecase) {
        self.realmUsecase = realmUsecase
    }

    func loadSudoku() -> SudokuClass? {
        guard let sudoku = realmUsecase.loadStorage() else {return nil}
        return sudoku
    }
    
    func removeSudoku() {
        realmUsecase.removeStorage()
    }
    
}
