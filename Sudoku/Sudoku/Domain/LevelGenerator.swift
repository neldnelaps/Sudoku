//
//  LevelGenerator.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 29.05.2023.
//

import Foundation
import RealmSwift

// Define the row object:
class Row: Object {
    var values = List<Int>()
}

// Define the matrix object:
class Grid: Object {
    var rows = List<Row>()
}

extension Grid {
    func fillWithZeros(num: Int) {
        for _ in 0..<num {
            let row = Row()
            for _ in 0..<num {
                row.values.append(0)
            }
            rows.append(row)
        }
    }
}

class LevelGenerator : Object {

    let num = 3
    let count = 9
    @Persisted var gridDefault: Grid? = Grid()
    @objc dynamic var level: GameDifficulty = .light
    @Persisted var gridToSolve: Grid? = Grid()
    
    func gameGeneratorByDifficulty(difficulty: GameDifficulty) {

        gridToSolve?.fillWithZeros(num: count)
        
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
            guard let item = gridDefault?.rows[pairs[i].0].values[pairs[i].1] else {
                gridToSolve?.rows[pairs[i].0].values[pairs[i].1] = 0
                continue
            }
            gridToSolve?.rows[pairs[i].0].values[pairs[i].1] = item
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
        for i in 0..<num*num {
            let row = Row()
            for j in 0..<num*num {
                let value = (i*num + i/num + j) % (num*num) + 1
                row.values.append(value)
            }
            gridDefault?.rows.append(row)
        }
    }
    
    /// Транспонирование всей таблицы — столбцы становятся строками и наоборот
    /// - Returns: Транспонированную  таблицу
    func transposing() -> Grid {
        let transposedTable : Grid = Grid()
        transposedTable.fillWithZeros(num: count)
        
        for i in 0..<count {
            for j in 0..<count {
                guard let item = gridDefault?.rows[i].values[j] else {
                    continue
                }
                transposedTable.rows[j].values[i] = item
            }
        }
        return transposedTable
    }
    
    /// Меняет местами две строки
    func swapRowsSmall() {
        let area = Int.random(in: 0..<num), line1 = Int.random(in: 0..<num)
        let n1 = area * num + line1
        var line2 = Int.random(in: 0..<num)
        
        while line1 == line2 {
            line2 = Int.random(in: 0..<num)
        }
        
        let n2 = area * num + line2
        self.gridDefault?.rows.swapAt(n1, n2)
    }
    
    func swapColumsSmall() {
        gridDefault = transposing()
        swapRowsSmall()
        gridDefault = transposing()
    }
    
    func swapRowsArea() {
        let area1 = Int.random(in: 0..<num)
        var area2 = Int.random(in: 0..<num)
        
        while area1 == area2 {
            area2 = Int.random(in: 0..<num)
        }
        
        for i in 0..<num {
            self.gridDefault?.rows.swapAt(area1 * num + i, area2 * num + i)
        }
    }
    
}
