//
//  SudokuClass.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 21.05.2023.
//

import Foundation
import UIKit

struct SudokuData: Codable {
    var gameDiff: GameDifficulty = .average
    var plistPuzzle: [[Int]] = [[Int]] (repeating: [Int] (repeating: 0, count: 9), count: 9) // the loaded puzzle
    var pencilPuzzle: [[[Bool]]] = [[[Bool]]] (repeating: [[Bool]] (repeating: [Bool] (repeating: false, count: 10), count: 9), count: 9)       // penciled values - 3x array of booleans
    var userPuzzle: [[Int]] = [[Int]] (repeating: [Int] (repeating: 0, count: 9), count: 9)           // user entries to puzzle
}

class SudokuClass {
    var inProgress = false
    var grid: SudokuData! = SudokuData()
    
    /// Возвращает значение true, если число в данной ячейке фиксировано (не может быть изменено пользователем).
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке фиксировано, false в противном случае.
    func numberAt(row: Int, column: Int) -> Int {
        return grid.plistPuzzle[row][column] != 0 ? grid.plistPuzzle[row][column] : grid.userPuzzle[row][column]
    }
    
    /// Возвращает значение true, если число в данной ячейке фиксировано (не может быть изменено пользователем).
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке фиксировано, false в противном случае.
    func numberIsFixedAt(row: Int, column: Int) -> Bool {
        return grid.plistPuzzle[row][column] != 0
    }
    
    /// число конфликтует с любым другим числом в той же строке, столбце или квадрате 3 × 3?
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число конфликтует, false в противном случае.
    func isConflictingEntryAt(row : Int, column: Int) -> Bool  {
        // get n
        var n: Int
        if grid.plistPuzzle[row][column] == 0 {
            n = grid.userPuzzle[row][column]
        } else {
            n = grid.plistPuzzle[row][column]
        }
        
        // if no value exists in entry -- no conflict
        if n == 0 { return false }
        
        // check all columns - if same number as current number (except current location) -- conflict
        for r in 0...8 {
            if r != row && (grid.plistPuzzle[row][column] == n || grid.userPuzzle[row][column] == n) {
                return true;
            }
        }
        
        // check all rows - if same number as current number (except current location) -- conflict
        for c in 0...8 {
            if c != column && (grid.plistPuzzle[row][column] == n || grid.userPuzzle[row][column] == n) {
                return true;
            }
        }
        
        // check all 3x3s
        // row, col = (0,0)-(8,8)
        let threeByThreeRow : Int = row / 3 // forced division
        let threeByThreeCol : Int = column / 3 // forced division
        // 0-2 = 0, 3-5 = 1, 6-8 = 2  ----> 0 + (0*3), 1 + (0*3), 2 + (0*3)
        // check rows and columns in these areas
        let startRow = threeByThreeRow * 3
        let startCol = threeByThreeCol * 3
        let endRow = 2 + (threeByThreeRow * 3)
        let endCol = 2 + (threeByThreeCol * 3)
        for r in startRow...endRow {
            for c in startCol...endCol {
                // if not the original square and contains the value n -- conflict
                if c != column && r != row && (grid.plistPuzzle[row][column] == n || grid.userPuzzle[row][column] == n) {
                    return true
                } // end if
            } // end c
        } // end r
        
        // no conflicts
        return false
    } // end isConflictingEntryAt
    
    /// Записаны ли какие-либо значения в данной ячейке?
    /// - Parameters:
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке есть значение, false в противном случае.
    func anyPencilSetAt(row : Int, column : Int) -> Bool {
        for n in 0...8 {
            if grid.pencilPuzzle[row][column][n] == true {
                return true
            }
        }
        return false
    }
        
    /// Начертано ли карандашом значение n?
    /// - Parameters:
    ///   - n: Цифра.
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    /// - Returns: true, если число в ячейке начерчено, false в противном случае.
    func isSetPencil(n : Int, row : Int, column : Int) -> Bool {
        return grid.pencilPuzzle[row][column][n]
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
        grid.userPuzzle[row][col] = n
    }
    
    // Is the piece a user piece
    func userEntry(row: Int, column: Int) -> Int {
        return grid.userPuzzle[row][column]
    }
    
    // setter - reverse
    func pencilGrid(n: Int, row: Int, col: Int) {
        grid.pencilPuzzle[row][col][n] = !grid.pencilPuzzle[row][col][n]
    }

    // setter - blank
    func pencilGridBlank(n: Int, row: Int, col: Int) {
        grid.pencilPuzzle[row][col][n] = false
    }
    
    func clearPlistPuzzle() {
        grid.plistPuzzle = [[Int]] (repeating: [Int] (repeating: 0, count: 9), count: 9) // the loaded puzzle
    }
    
    func clearPencilPuzzle() {
        grid.pencilPuzzle = [[[Bool]]] (repeating: [[Bool]] (repeating: [Bool] (repeating: false, count: 10), count: 9), count: 9)
    }
    
    func clearUserPuzzle() {
        grid.userPuzzle = [[Int]] (repeating: [Int] (repeating: 0, count: 9), count: 9)
    }
    
    func clearConflicts() {
        grid.userPuzzle.indices.forEach { r in
            grid.userPuzzle.indices.forEach { c in
                if isConflictingEntryAt(row: r, column: c) {
                    grid.userPuzzle[r][c] = 0
                }
            }
        }
    }
    
    func gameInProgress(set: Bool) {
        inProgress = set
    }

}