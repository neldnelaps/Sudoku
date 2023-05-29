//
//  GameViewController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 23.05.2023.
//

import UIKit

class GameViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var PencilOn = false
    
    @IBOutlet weak var sudokuView: SudokuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PencilOn = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            do {
                try appDelegate.saveLocalStorage(save: appDelegate.sudoku.grid)//TODO
            } catch {
                let nserror = error as NSError
                fatalError("Error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @IBAction func clearCell(_ sender: Any) {
        let row = sudokuView.selected.row
        let col = sudokuView.selected.column
        if row == -1, col == -1 {
            return
        }
        
        let grid = appDelegate.sudoku.grid
        if grid?.userPuzzle[row][col] != 0 {
            appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
        }
        
        for i in 0...9 {
            appDelegate.sudoku.pencilGridBlank(n: i, row: row, col: col)
        }
        refresh()
    }
    
    @IBAction func pencilOn(_ sender: UIButton) {
        PencilOn = !PencilOn
        sender.isSelected = PencilOn
    }

    // MARK: - Keypad
    @IBAction func Keypad(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = self.appDelegate.sudoku
        puzzle.gameInProgress(set: true)
        let grid = appDelegate.sudoku.grid
        let row = sudokuView.selected.row
        let col = sudokuView.selected.column
        if (row != -1 && col != -1) {
            if PencilOn == false {
                if grid?.plistPuzzle[row][col] == 0 && grid?.userPuzzle[row][col] == 0  {
                    appDelegate.sudoku.userGrid(n: sender.tag, row: row, col: col)
                    refresh()
                } else if grid?.plistPuzzle[row][col] == 0 || grid?.userPuzzle[row][col] == sender.tag {
                    appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
                    refresh()
                }
            } else {
                appDelegate.sudoku.pencilGrid(n: sender.tag, row: row, col: col)
                refresh()
            }
        }
    }
    
    func refresh() {
        sudokuView.setNeedsDisplay()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
