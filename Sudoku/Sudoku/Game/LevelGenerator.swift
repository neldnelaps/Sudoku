//
//  LevelGenerator.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 29.05.2023.
//

import Foundation

class LevelGenerator {
    
    let n = 3
    var gridDefault : [[Int]] = []
    var level: GameDifficulty = .light
    var grid: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    
    func gameGeneratorByDifficulty(difficulty: GameDifficulty) {
        generateDefaultGrid()
        gridDefault = transposing()

        swapRowsSmall()
        swapColumsSmall()
        swapRowsArea()
        swapColumsSmall()
        
        var count: Int
        switch difficulty {
        case .light:
            count = 40
        case .average:
            count = 35
        case .hard:
            count = 30
        case .expert:
            count = 25
        case .crazy:
            count = 20
        }
        
        let pairs = generateRandomPairs(from: 0, to: 8, count: count)
        
        for i in 0..<count {
            grid[pairs[i].0][pairs[i].1] = gridDefault[pairs[i].0][pairs[i].1]
        }
    }
    
    /// Возвращает пары индексов
    /// - Returns: Массив пар индексов
    func generateRandomPairs(from: Int, to: Int, count: Int) -> [(Int, Int)] {
        var pairs = [(Int, Int)]()
        
        while pairs.count < count {
            pairs.append((Int.random(in: from...to), Int.random(in: from...to)))
        }
        
        return pairs
    }

    
    /// Возвращает сгенерированную по  умолчанию таблицу
    /// - Returns: Сгенерированную по  умолчанию таблицу
    func generateDefaultGrid(){
        for i in 0..<n*n {
            var row = [Int]()
            for j in 0..<n*n {
                let value = (i*n + i/n + j) % (n*n) + 1
                row.append(value)
            }
            gridDefault.append(row)
        }
    }
    
    /// Транспонирование всей таблицы — столбцы становятся строками и наоборот
    /// - Returns: Транспонированную  таблицу
    func transposing() -> [[Int]] {
        let rowCount = gridDefault.count
        let columnCount = gridDefault[0].count
        
        var transposedTable = [[Int]](repeating: [Int](repeating: 0, count: rowCount), count: columnCount)
        
        for i in 0..<rowCount {
            for j in 0..<columnCount {
                transposedTable[j][i] = gridDefault[i][j]
            }
        }
        
        return transposedTable
    }
    
    /// Меняет местами две строки
    func swapRowsSmall() {
        let area = Int.random(in: 0..<n), line1 = Int.random(in: 0..<n)
        let n1 = area * n + line1
        var line2 = Int.random(in: 0..<n)
        
        while line1 == line2 {
            line2 = Int.random(in: 0..<n)
        }
        
        let n2 = area * n + line2
        self.gridDefault.swapAt(n1, n2)
    }
    
    func swapColumsSmall() {
        gridDefault = transposing()
        swapRowsSmall()
        gridDefault = transposing()
    }
    
    func swapRowsArea() {
        let area1 = Int.random(in: 0..<n)
        var area2 = Int.random(in: 0..<n)
        
        while area1 == area2 {
            area2 = Int.random(in: 0..<n)
        }
        
        for i in 0..<n {
            let n1 = area1 * n + i
            let n2 = area2 * n + i
            self.gridDefault.swapAt(n1, n2)
        }
    }
    
}
