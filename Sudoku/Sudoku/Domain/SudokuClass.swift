//
//  SudokuClass.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 21.05.2023.
//

import Foundation
import UIKit
import RealmSwift


class SudokuData: Object {
    @objc dynamic var gameDiff: GameDifficulty = .average
    @Persisted var plistPuzzle: Grid? = Grid()
    //TODO var pencilPuzzle: [[[Bool]]] = [[[Bool]]] (repeating: [[Bool]] (repeating: [Bool] (repeating: false, count: 10), count: 9), count: 9) // penciled values - 3x array of booleans
    @Persisted var userPuzzle: Grid? = Grid()
    
    override init() {
        super.init()
        let num = 9
        userPuzzle?.fillWithZeros(num: num)
        plistPuzzle?.fillWithZeros(num: num)
    }

}

class SudokuClass : Object {
    
    static let uniqueKey: String = "SudokuClass"
    @Persisted var uniqueKey: String = SudokuClass.uniqueKey
    @Persisted var inProgress: Bool? = false
    @Persisted var grid: SudokuData! = SudokuData()
    @Persisted var levelGrid: LevelGenerator? = LevelGenerator()

     override class func primaryKey() -> String? {
          return "uniqueKey"
     }

    /// Возвращает значение true, если число в данной ячейке фиксировано (не может быть изменено пользователем).
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке фиксировано, false в противном случае.
    func numberAt(row: Int, column: Int) -> Int {
        return grid.plistPuzzle?.rows[row].values[column] ?? grid.userPuzzle?.rows[row].values[column] ?? 0
    }
    
    /// Возвращает значение true, если число в данной ячейке фиксировано (не может быть изменено пользователем).
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке фиксировано, false в противном случае.
    func numberIsFixedAt(row: Int, column: Int) -> Bool {
        return grid.plistPuzzle?.rows[row].values[column] != 0
    }
    
    /// число конфликтует с любым другим числом в той же строке, столбце или квадрате 3 × 3?
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число конфликтует, false в противном случае.
    func isConflictingEntryAt(row : Int, column: Int) -> Bool  {
        if let item = grid.userPuzzle?.rows[row].values[column] {
            if levelGrid?.gridDefault?.rows[row].values[column] != item {
                return true
            }
        }
        
        return false
    }
    
    /// Записаны ли какие-либо значения в данной ячейке?
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке есть значение, false в противном случае.
    func anyPencilSetAt(row : Int, column : Int) -> Bool {
//        for n in 0...8 {
//            if grid.pencilPuzzle[row][column][n] == true {
//                return true
//            }
//        } TOCO
        return false
    }
        
    /// Начертано ли карандашом значение n?
    /// - Parameters:
    ///   - n: Цифра.
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке начерчено, false в противном случае.
    func isSetPencil(n : Int, row : Int, column : Int) -> Bool {
        //TODO return grid.pencilPuzzle[row][column][n]
        return false
    }
    
    // load game from plist
    func plistToPuzzle(plist: String, toughness: GameDifficulty) -> [[Int]] {
        // init initial puzzle
        var puzzle = [[Int]] (repeating: [Int] (repeating: 0, count: 9), count: 9)
        // replace . with 0
        let plistZeroed = plist.replacingOccurrences(of: ".", with: "0")
        
        // create puzzle
        var col: Int = 0
        var row: Int = 0
        for c in plistZeroed {
            puzzle[row][col] = Int(String(c))!
            row = row + 1
            if row == 9 {
                row = 0
                col = col + 1
                if col == 9 {
                    return puzzle
                }
            }
        }
        
        return puzzle
    }
    
    // setter
    func userGrid(n: Int, row: Int, col: Int) {
        try! Realm().write {
            grid.userPuzzle?.rows[row].values[col] = n
        }
       
    }
    
    // Is the piece a user piece
    func userEntry(row: Int, col: Int) -> Int {
        guard let item = grid.userPuzzle?.rows[row].values[col] else {return 0}
        return item
       
    }
    
    // setter - reverse
    func pencilGrid(n: Int, row: Int, col: Int) {
        //TODO grid.pencilPuzzle[row][col][n] = !grid.pencilPuzzle[row][col][n]
    }

    // setter - blank
    func pencilGridBlank(n: Int, row: Int, col: Int) {
        //TODO grid.pencilPuzzle[row][col][n] = false
    }
    
    func clearPlistPuzzle() {
        guard let count = grid.plistPuzzle?.rows.count else {return}
        grid.plistPuzzle?.fillWithZeros(num: count)
    }
    
    func clearPencilPuzzle() {
        //TODO grid.pencilPuzzle = [[[Bool]]] (repeating: [[Bool]] (repeating: [Bool] (repeating: false, count: 10), count: 9), count: 9)
    }
    
    func clearUserPuzzle() {
        guard let count = grid.userPuzzle?.rows.count else {return}
        grid.userPuzzle?.fillWithZeros(num: count)
    }
    
    func clearConflicts() {
        grid.userPuzzle?.rows.indices.forEach { r in
            grid.userPuzzle?.rows.indices.forEach { c in
                if isConflictingEntryAt(row: r, column: c) {
                    grid.userPuzzle?.rows[r].values[c] = 0
                }
            }
        }
    }
    
    func gameInProgress(set: Bool) {
        try! Realm().write {
            inProgress = set
        }
    }

}
