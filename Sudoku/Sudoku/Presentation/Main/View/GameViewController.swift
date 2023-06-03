//
//  GameViewController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 23.05.2023.
//

import UIKit
import RxSwift

class GameViewController: UIViewController {

    private var viewModel: GameViewModel!
    private var bag = DisposeBag()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var sudokuView: SudokuView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = container.resolve(GameViewModel.self)!
        
        difficultyLabel.text = appDelegate.sudoku.levelGrid?.level.toString()
        gameOver()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
            
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            do {
                viewModel.saveSudoku(sudoku: appDelegate.sudoku)
            } catch {
                let nserror = error as NSError
                fatalError("Error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @objc func appWillResignActive() {
        viewModel.saveSudoku(sudoku: appDelegate.sudoku)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func clearCell(_ sender: Any) {
        
        let row = sudokuView.selected.row
        let col = sudokuView.selected.column
        if row == -1, col == -1 {
            return
        }
        
        let grid = appDelegate.sudoku.grid
        if grid?.userPuzzle?.rows[row].values[col] != 0 {
            if let item = grid?.userPuzzle?.rows[row].values[col]{
                var tmpButton = self.view.viewWithTag(item) as? UIButton
                tmpButton?.isEnabled = true
            }
            
            appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
        }
        
        refresh()
    }

    // MARK: - Keypad
    @IBAction func Keypad(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = self.appDelegate.sudoku
        let grid = appDelegate.sudoku.grid
        let row = sudokuView.selected.row
        let col = sudokuView.selected.column
        if (row != -1 && col != -1) {
            if grid?.plistPuzzle?.rows[row].values[col] == 0 && grid?.userPuzzle?.rows[row].values[col] == 0  {
                appDelegate.sudoku.userGrid(n: sender.tag, row: row, col: col)
                refresh()
            } else if grid?.plistPuzzle?.rows[row].values[col] == 0 || grid?.userPuzzle?.rows[row].values[col] == sender.tag {
                appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
                refresh()
            }
        }
        
        puzzle.gameInProgress()
        
        if puzzle.inProgress! {
            let alert = UIAlertController(title: "Победа после обеда".localized(), message: "Игра закончена", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }

        sender.isEnabled = puzzle.toСheckDigit(digit: sender.tag)

        gameOver()
    }
    
    func refresh() {
        sudokuView.setNeedsDisplay()
    }
    
    func gameOver() {
        print ("Errors: ".localized() + "\(appDelegate.sudoku.countError)/3")
        errorLabel.text =  "Errors: ".localized() + "\(appDelegate.sudoku.countError)/3"
        if appDelegate.sudoku.countError >= 3 {
            let alert = UIAlertController(title: "Game over!".localized(), message: "You made more than 3 mistakes".localized(), preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
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
