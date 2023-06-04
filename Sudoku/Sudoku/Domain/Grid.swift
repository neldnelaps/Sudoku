//
//  Grid.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 04.06.2023.
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
