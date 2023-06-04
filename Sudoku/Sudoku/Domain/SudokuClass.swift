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
        userPuzzle?.fillWithZeros(num: SizeSudoku.count)
        plistPuzzle?.fillWithZeros(num: SizeSudoku.count)
    }
}

class SudokuClass : Object {
    
    static let uniqueKey: String = "SudokuClass"
    @Persisted var uniqueKey: String = SudokuClass.uniqueKey
    @Persisted var inProgress: Bool? = false
    @Persisted var grid: SudokuData! = SudokuData()
    @Persisted var levelGrid: LevelGenerator? = LevelGenerator()
    @Persisted var countError: Int = 0
    @Persisted var numberOfEachDigit = List<Int>()

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
        if let item = grid.userPuzzle?.rows[row].values[column],
           let defaultValue = levelGrid?.gridDefault?.rows[row].values[column] {
            return item != defaultValue
        }
        return false
    }
    
    // load game from plist
    func plistToPuzzle(plist: String, toughness: GameDifficulty) -> [[Int]] {
        // init initial puzzle
        var puzzle = [[Int]] (repeating: [Int] (repeating: 0, count: SizeSudoku.count), count: SizeSudoku.count)
        // replace . with 0
        let plistZeroed = plist.replacingOccurrences(of: ".", with: "0")
        
        // create puzzle
        var col: Int = 0
        var row: Int = 0
        for c in plistZeroed {
            puzzle[row][col] = Int(String(c))!
            row = row + 1
            if row == SizeSudoku.count {
                row = 0
                col = col + 1
                if col == SizeSudoku.count {
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
        try! Realm().write {
            for row in 0..<SizeSudoku.count {
                for col in 0..<SizeSudoku.count {
                    if let puzzleValue = grid.plistPuzzle?.rows[row].values[col], puzzleValue == 0,
                       let userValue = grid.userPuzzle?.rows[row].values[col] {
                        if userValue == 0 || userValue != levelGrid?.gridDefault?.rows[row].values[col] {
                            inProgress = false
                            return
                        }
                    }
                }
            }
            inProgress = true
        }
    }
    
    /// Cчитает количество цифр в сетке
    func сountsNumberOfDigitsInGrid() {
        for i in 1 ..< SizeSudoku.count + 1 {
            let count = levelGrid?.gridToSolve?.rows.reduce(0) { (result, row) -> Int in
                return result + row.values.filter({$0 == i}).count
            }
            numberOfEachDigit.append(count!)
        }
        print(numberOfEachDigit)
    }
    
    ///Используется для проверки, сколько раз определенная цифра появляется в объекте userPuzzle с учетом numberOfEachDigit
    /// - Parameters:
    ///   - digit: Цифра для проверки
    /// - Returns: true, если число в сетки встречается 9 раз, false в противном случае.
    func toСheckDigit(digit: Int) -> Bool {
        let count = grid?.userPuzzle?.rows.reduce(0) { (result, row) -> Int in
            return result + row.values.filter({$0 == digit}).count
        }
        return numberOfEachDigit[digit - 1] + count! != SizeSudoku.count
    }

}
