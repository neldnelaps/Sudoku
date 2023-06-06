//
//  MainViewModel.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation
import RxSwift

class MainViewModel {
    
    private let realmUsecase: RealmUsecase
    
//    var sudoku = BehaviorSubject<SudokuClass>(value: SudokuClass())
//    self.sudoku.onNext(sudoku)
//    var f = try viewModel.sudoku.value()
//    print(f.grid.userPuzzle)
//
    
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
