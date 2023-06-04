//
//  LevelGenerator.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 29.05.2023.
//

import RealmSwift

class LevelGenerator : Object {

    @Persisted var gridDefault: Grid? = Grid()
    @objc dynamic var level: GameDifficulty = .light
    @Persisted var gridToSolve: Grid? = Grid()
    
    func gameGeneratorByDifficulty(difficulty: GameDifficulty) {
        gridToSolve?.fillWithZeros(num: SizeSudoku.count)
        
        generateDefaultGrid()
        gridDefault = transposing()

        swapRowsSmall()
        swapColumsSmall()
        swapRowsArea()
        swapColumsSmall()
        
        level = difficulty
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
        
        let pairs = generateRandomPairs(from: 0, to: SizeSudoku.count - 1, count: count)

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
        for i in 0..<SizeSudoku.count {
            let row = Row()
            for j in 0..<SizeSudoku.count {
                let value = (i*SizeSudoku.num + i/SizeSudoku.num + j) % (SizeSudoku.count) + 1
                row.values.append(value)
            }
            gridDefault?.rows.append(row)
        }
    }
    
    /// Транспонирование всей таблицы — столбцы становятся строками и наоборот
    /// - Returns: Транспонированную  таблицу
    func transposing() -> Grid {
        let transposedTable : Grid = Grid()
        transposedTable.fillWithZeros(num: SizeSudoku.count)
        
        for i in 0..<SizeSudoku.count {
            for j in 0..<SizeSudoku.count {
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
        let area = Int.random(in: 0..<SizeSudoku.num), line1 = Int.random(in: 0..<SizeSudoku.num)
        let n1 = area * SizeSudoku.num + line1
        var line2 = Int.random(in: 0..<SizeSudoku.num)
        
        while line1 == line2 {
            line2 = Int.random(in: 0..<SizeSudoku.num)
        }
        
        let n2 = area * SizeSudoku.num + line2
        self.gridDefault?.rows.swapAt(n1, n2)
    }
    
    func swapColumsSmall() {
        gridDefault = transposing()
        swapRowsSmall()
        gridDefault = transposing()
    }
    
    func swapRowsArea() {
        let area1 = Int.random(in: 0..<SizeSudoku.num)
        var area2 = Int.random(in: 0..<SizeSudoku.num)
        
        while area1 == area2 {
            area2 = Int.random(in: 0..<SizeSudoku.num)
        }
        
        for i in 0..<SizeSudoku.num {
            self.gridDefault?.rows.swapAt(area1 * SizeSudoku.num + i, area2 * SizeSudoku.num + i)
        }
    }
    
}
