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
    @Persisted var countError: Int = 0

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
               //TODO countError += 1
                return true
            }
        }
        
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
    
    func clearPlistPuzzle() {
        guard let count = grid.plistPuzzle?.rows.count else {return}
        grid.plistPuzzle?.fillWithZeros(num: count)
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
    
    /// Устанавливает inProgress = true, если игра завершена успешно, иначе false
    func gameInProgress() {
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if grid.plistPuzzle?.rows[row].values[col] == 0 {
                    if grid.userPuzzle?.rows[row].values[col] == 0 {
                        inProgress = false
                        return
                    }
                    if grid.userPuzzle?.rows[row].values[col] != levelGrid?.gridDefault?.rows[row].values[col] {
                        inProgress = false
                        return
                    }
                }
            }
        }
        
        inProgress = true
    }

}
