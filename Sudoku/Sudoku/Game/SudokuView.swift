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
        let d = gridSize/9
        let col = Int((tapPoint.x - gridOrigin.x)/d)
        let row = Int((tapPoint.y - gridOrigin.y)/d)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        if  0 <= col && col < 9 && 0 <= row && row < 9 {              // if inside puzzle bounds
            if (!puzzle.numberIsFixedAt(row: row, column: col)) {       // and not a "fixed number"
                if (row != selected.row || col != selected.column) {  // and not already selected
                    selected.row = row                                // then select cell
                    selected.column = col
                    setNeedsDisplay()                                 // request redraw ***** PuzzleView
                }
            }
            else {
                //TODO grid.plistPuzzle[row][column]
            }
        }
    }
    
    //
    // Draw sudoku board. The current puzzle state is stored in the "sudoku" property
    // stored in the app delegate.
    //
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        //
        // Find largest square w/in bounds of view and use this to establish
        // grid parameters.
        //
        let gridSize = (self.bounds.width < self.bounds.height) ? self.bounds.width : self.bounds.height
        let gridOrigin = CGPoint(x: (self.bounds.width - gridSize)/2, y: (self.bounds.height - gridSize)/2)
        let delta = gridSize/3
        let d = delta/3

        
        //
        // Fill selected cell (is one is selected).
        //
        if selected.row >= 0 && selected.column >= 0 {
            UIColor.systemBlue.withAlphaComponent(0.2).setFill()
            let x = gridOrigin.x + CGFloat(selected.column)*d
            let y = gridOrigin.y + CGFloat(selected.row)*d
            context?.fill(CGRect(x: x, y: y, width: d, height: d))
        }
        
        //
        // Stroke outer puzzle rectangle
        //
        context?.setLineWidth(3)
        UIColor.gray.setStroke()
        context?.stroke(CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridSize, height: gridSize))
        
        //
        // Stroke major grid lines.
        //
        for i in 0 ..< 3 {
            let x = gridOrigin.x + CGFloat(i)*delta
            context?.move(to: CGPoint(x: x, y: gridOrigin.y))
            context?.addLine(to: CGPoint(x: x, y: gridOrigin.y + gridSize))
            context?.strokePath()
        }
        for i in 0 ..< 3 {
            let y = gridOrigin.y + CGFloat(i)*delta
            context?.move(to: CGPoint(x: gridOrigin.x, y: y))
            context?.addLine(to: CGPoint(x: gridOrigin.x + gridSize, y: y))
            context?.strokePath()
        }
        
        //
        // Stroke minor grid lines.
        //
        context?.setLineWidth(1)
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
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
        let pencilFont = UIFont(name: pencilFontName, size: fontSize/3)
        
        let fixedAttributes = [NSAttributedString.Key.font : font!/*boldFont!*/, NSAttributedString.Key.foregroundColor : UIColor.black]
        let userAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.blue]
        let conflictAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.red]
        let pencilAttributes = [NSAttributedString.Key.font : pencilFont!, NSAttributedString.Key.foregroundColor : UIColor.black]
        
        //
        // Fill in puzzle numbers.
        //
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                var number : Int
                if puzzle.userEntry(row: row, column: col) != 0 {
                    number = puzzle.userEntry(row: row, column: col)
                } else {
                    number = puzzle.numberAt(row: row, column: col)
                }
                if (number > 0) {
                    var attributes : [NSAttributedString.Key : NSObject]? = nil
                    if puzzle.numberIsFixedAt(row: row, column: col) {
                        attributes = fixedAttributes
                    } else if puzzle.isConflictingEntryAt(row: row, column: col) {
                        attributes = conflictAttributes
                    } else if puzzle.userEntry(row: row, column: col) != 0 {
                        attributes = userAttributes
                    }
                    let text = "\(number)" as NSString
                    let textSize = text.size(withAttributes: attributes)
                    let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                    let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                    text.draw(in: textRect, withAttributes: attributes)
                } else if puzzle.anyPencilSetAt(row: row, column: col) {
                    let s = d/3
                    for n in 1 ... 9 {
                        if puzzle.isSetPencil(n: n, row: row, column: col) {
                            let r = (n - 1) / 3
                            let c = (n - 1) % 3
                            let text : NSString = "\(n)" as NSString
                            let textSize = text.size(withAttributes: pencilAttributes)
                            let x = gridOrigin.x + CGFloat(col)*d + CGFloat(c)*s + 0.5*(s - textSize.width)
                            let y = gridOrigin.y + CGFloat(row)*d + CGFloat(r)*s + 0.5*(s - textSize.height)
                            let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                            text.draw(in: textRect, withAttributes: pencilAttributes)
                        }
                    }
                }
            }
        }
        
    }

}
