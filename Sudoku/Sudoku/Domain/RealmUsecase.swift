//
//  RealmUsecase.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation

class RealmUsecase {
    
    private var realmRepository: RealmRepositoryProtocol
    
    init(realmRepository: RealmRepositoryProtocol){
        self.realmRepository = realmRepository
    }
    
    func loadStorage() -> SudokuClass? {
        return realmRepository.loadStorage()
    }
    
    func saveStorage(sudoku: SudokuClass) {
        realmRepository.saveStorage(sudoku: sudoku)
    }
    
    func removeStorage(){
        realmRepository.removeStorage()
    }

}
