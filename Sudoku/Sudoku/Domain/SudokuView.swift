//
//  SudokuView.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 21.05.2023.
//

import UIKit

func fontSizeFor(_ string : NSString, fontName : String, targetSize : CGSize) -> CGFloat {
    let testFontSize : CGFloat = 32
    let font = UIFont(name: fontName, size: testFontSize)
    let attr = [NSAttributedString.Key.font : font!]
    let strSize = string.size(withAttributes: attr)
    return testFontSize*min(targetSize.width/strSize.width, targetSize.height/strSize.height)
}

class SudokuView: UIView {
    
    var selected = (row : -1, column : -1)  // current selected cell in 9x9 puzzle (-1 => none)

    //
    // Allow user to "select" a non-fixed cell in the puzzle's 9x9 grid.
    //
    @IBAction func handleTap(_ sender : UIGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let gridSize = (self.bounds.width < self.bounds.height) ? self.bounds.width : self.bounds.height
        let gridOrigin = CGPoint(x: (self.bounds.width - gridSize)/2, y: (self.bounds.height - gridSize)/2)
        let d = gridSize/CGFloat(SizeSudoku.count)
        let col = Int((tapPoint.x - gridOrigin.x)/d)
        let row = Int((tapPoint.y - gridOrigin.y)/d)
        
        if  0 <= col && col < SizeSudoku.count && 0 <= row && row < SizeSudoku.count {          // if inside puzzle bounds
            if (row != selected.row || col != selected.column) {  // and not already selected
                selected.row = row                                // then select cell
                selected.column = col
                setNeedsDisplay()
            }
        }
    }
    
    /// Заполнить цветом выбранную ячейку
    /// - Parameters:
    ///   - context: Среда рисования Quartz 2D.
    ///   - gridOrigin: Сетка
    ///   - row: Номер строки ячейки.
    ///   - column: Номер столбца ячейки.
    ///   - d: Переменная представляет собой размер одной ячейки в сетке (ширина и высота)
    func fillSelectedCell(context: CGContext?, gridOrigin: CGPoint, row: Int, column: Int, d: CGFloat) {
        let x = gridOrigin.x + CGFloat(row)*d
        let y = gridOrigin.y + CGFloat(column)*d
        context?.fill(CGRect(x: x, y: y, width: d, height: d))
    }
    
    /// Рисуем доску для судоку. Текущее состояние головоломки хранится в свойстве sudoku в делегате приложения
    /// - Parameters:
    ///   - rect - это прямоугольник, в который должна быть нарисована сетка. Он представляет собой область экрана, в которой будет отображаться содержимое представления.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        //
        // Find largest square w/in bounds of view and use this to establish
        // grid parameters.
        //
        let gridSize = (self.bounds.width < self.bounds.height) ? self.bounds.width : self.bounds.height
        let gridOrigin = CGPoint(x: (self.bounds.width - gridSize)/2, y: (self.bounds.height - gridSize)/2)
        let delta = gridSize/CGFloat(SizeSudoku.num)
        let d = delta/CGFloat(SizeSudoku.num)

        //
        // Fill selected cell (is one is selected).
        //
        if selected.row >= 0 && selected.column >= 0 {
            UIColor.systemBlue.withAlphaComponent(0.2).setFill()
            
            for i in 0 ..< SizeSudoku.count {
                fillSelectedCell(context: context, gridOrigin: gridOrigin, row: i, column: selected.row, d: d)
                fillSelectedCell(context: context, gridOrigin: gridOrigin, row: selected.column, column: i, d: d)
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            guard let grid = appDelegate.sudoku.grid else {return}
           
            let plistValue = grid.plistPuzzle?.rows[selected.row].values[selected.column] ?? 0
            let userValue = grid.userPuzzle?.rows[selected.row].values[selected.column] ?? 0

            let item = plistValue == 0 ? userValue : plistValue
            
            if item != 0 {
                for i in 0 ..< SizeSudoku.count {
                    guard let plistRow = grid.plistPuzzle?.rows[i],
                          let userRow = grid.userPuzzle?.rows[i] else {
                        continue
                    }
                    
                    if let index1 = plistRow.values.index(of: item) {
                        fillSelectedCell(context: context, gridOrigin: gridOrigin, row: index1, column: i, d: d)
                    }
                    
                    if let index2 = userRow.values.index(of: item) {
                        fillSelectedCell(context: context, gridOrigin: gridOrigin, row: index2, column: i, d: d)
                    }
                }
            }
        }
        
        //
        // Stroke outer puzzle rectangle
        //
        context?.setLineWidth(CGFloat(SizeSudoku.num))
        UIColor.gray.setStroke()
        context?.stroke(CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridSize, height: gridSize))
        
        //
        // Stroke major grid lines.
        //
        for i in 0 ..< SizeSudoku.num {
            let x = gridOrigin.x + CGFloat(i)*delta
            context?.move(to: CGPoint(x: x, y: gridOrigin.y))
            context?.addLine(to: CGPoint(x: x, y: gridOrigin.y + gridSize))
            context?.strokePath()
        }
        for i in 0 ..< SizeSudoku.num {
            let y = gridOrigin.y + CGFloat(i)*delta
            context?.move(to: CGPoint(x: gridOrigin.x, y: y))
            context?.addLine(to: CGPoint(x: gridOrigin.x + gridSize, y: y))
            context?.strokePath()
        }
        
        //
        // Stroke minor grid lines.
        //
        context?.setLineWidth(1)
        for i in 0 ..< SizeSudoku.num {
            for j in 0 ..< SizeSudoku.num {
                let x = gridOrigin.x + CGFloat(i)*delta + CGFloat(j)*d
                context?.move(to: CGPoint(x: x, y: gridOrigin.y))
                context?.addLine(to: CGPoint(x: x, y: gridOrigin.y + gridSize))
                let y = gridOrigin.y + CGFloat(i)*delta + CGFloat(j)*d
                context?.move(to: CGPoint(x: gridOrigin.x, y: y))
                context?.addLine(to: CGPoint(x: gridOrigin.x + gridSize, y: y))
                context?.strokePath()
            }
        }

        //
        // Fetch Sudoku puzzle model object from app delegate.
        //
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku

        //
        // Fetch/compute font attribute information.
        //
        let fontName = "Helvetica-Light"
        let boldFontName = "Helvetica-Bold"
        let pencilFontName = "Helvetica-Light"
        
        let fontSize = fontSizeFor("0", fontName: boldFontName, targetSize: CGSize(width: d, height: d))
        
        let boldFont = UIFont(name: boldFontName, size: fontSize)
        let font = UIFont(name: fontName, size: fontSize)
        let pencilFont = UIFont(name: pencilFontName, size: fontSize/CGFloat(SizeSudoku.num))
        
        let fixedAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.black]
        let userAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.blue]
        let conflictAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.red]
        let pencilAttributes = [NSAttributedString.Key.font : pencilFont!, NSAttributedString.Key.foregroundColor : UIColor.black]
        
        //
        // Fill in puzzle numbers.
        //
        for row in 0 ..< SizeSudoku.count {
            for col in 0 ..< SizeSudoku.count {
                var number : Int
                if puzzle.userEntry(row: row, col: col) != 0 {
                    number = puzzle.userEntry(row: row, col: col)
                } else {
                    number = puzzle.numberAt(row: row, column: col)
                }
                if (number > 0) {
                    var attributes : [NSAttributedString.Key : NSObject]? = nil
                    if puzzle.numberIsFixedAt(row: row, column: col) {
                        attributes = fixedAttributes
                    } else if puzzle.isConflictingEntryAt(row: row, column: col) {
                        attributes = conflictAttributes
                    } else if puzzle.userEntry(row: row, col: col) != 0 {
                        attributes = userAttributes
                    }
                    let text = "\(number)" as NSString
                    let textSize = text.size(withAttributes: attributes)
                    let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                    let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                    text.draw(in: textRect, withAttributes: attributes)
                }
            }
        }
    }

}
