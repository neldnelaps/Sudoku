//
//  GameViewController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 23.05.2023.
//

import UIKit
import RxSwift
import RealmSwift

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
        
        for i in 1 ..< SizeSudoku.count + 1 {
            guard let tmpButton = self.view.viewWithTag(i) as? UIButton else {continue}
            tmpButton.isEnabled = appDelegate.sudoku.toСheckDigit(digit: i)
        }
    }
            
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            do {
                if appDelegate.sudoku.countError == 3{
                    self.viewModel.removeSudoku()
                    return
                }
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
                let tmpButton = self.view.viewWithTag(item) as? UIButton
                tmpButton?.isEnabled = true
            }
            
            appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
        }
        
        refresh()
    }

    // MARK: - Keypad
    @IBAction func Keypad(_ sender: UIButton) {
        let grid = appDelegate.sudoku.grid
        let row = sudokuView.selected.row
        let col = sudokuView.selected.column
        if (row != -1 && col != -1) {
            if grid?.plistPuzzle?.rows[row].values[col] == 0 && grid?.userPuzzle?.rows[row].values[col] == 0  {
                appDelegate.sudoku.userGrid(n: sender.tag, row: row, col: col)
                refresh()
            } else if grid?.plistPuzzle?.rows[row].values[col] == 0 || grid?.userPuzzle?.rows[row].values[col] == sender.tag {
                appDelegate.sudoku.userGrid(n: sender.tag, row: row, col: col)
                refresh()
            }
        }
        
        appDelegate.sudoku.gameInProgress()
        
        if appDelegate.sudoku.inProgress! {
            let winView = WinViewController()
            winView.diff = self.appDelegate.sudoku.levelGrid?.level.toString()
            winView.modalPresentationStyle = .fullScreen
            present(winView, animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        sender.isEnabled = appDelegate.sudoku.toСheckDigit(digit: sender.tag)
        
        if appDelegate.sudoku.isConflictingEntryAt(row: row, column: col) {
            try! Realm().write {
                appDelegate.sudoku.countError += 1
            }
            gameOver()
        }
    }
    
    func refresh() {
        sudokuView.setNeedsDisplay()
    }
    
    func gameOver() {
        print ("Errors: ".localized() + "\(appDelegate.sudoku.countError)/3")
        errorLabel.text =  "Errors: ".localized() + "\(appDelegate.sudoku.countError)/3"
        if appDelegate.sudoku.countError >= 3 {
            createAlert()
        }
    }
    
    //  MARK: Alert
    func createAlert(){
        let alert = UIAlertController(title: "Game over!".localized(), message: "You made more than 3 mistakes".localized(), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Light".localized(), style: .default , handler:{ (UIAlertAction)in
            self.setupGridShow(gameDiff: .light)
        }))
        alert.addAction(UIAlertAction(title: "Average".localized(), style: .default , handler:{ (UIAlertAction)in
            self.setupGridShow(gameDiff: .average)
        }))
        alert.addAction(UIAlertAction(title: "Hard".localized(), style: .default , handler:{ (UIAlertAction)in
            self.setupGridShow(gameDiff: .hard)
        }))
        alert.addAction(UIAlertAction(title: "Expert".localized(), style: .default , handler:{ (UIAlertAction)in
            self.setupGridShow(gameDiff: .expert)
        }))
        alert.addAction(UIAlertAction(title: "Crazy".localized(), style: .default , handler:{ (UIAlertAction)in
            self.setupGridShow(gameDiff: .crazy)
        }))
        alert.addAction(UIAlertAction(title: "Start again".localized(), style: .destructive , handler:{ (UIAlertAction)in
            print("User click Start again")
            self.startAgain()
        }))
        alert.addAction(UIAlertAction(title: "Home".localized(), style: .cancel , handler:{ (UIAlertAction)in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    private func setupGridShow(gameDiff: GameDifficulty) {
        viewModel.removeSudoku()

        let puzzle = SudokuClass()
        puzzle.grid.gameDiff = gameDiff
        puzzle.levelGrid = LevelGenerator()
        puzzle.levelGrid?.gameGeneratorByDifficulty(difficulty: gameDiff)
        puzzle.grid.plistPuzzle = puzzle.levelGrid!.gridToSolve
        puzzle.сountsNumberOfDigitsInGrid()
        self.appDelegate.sudoku = puzzle
        
        updateView()
    }
    
    private func startAgain() {
        try! Realm().write{
            let puzzle = self.appDelegate.sudoku
            puzzle.countError = 0
            puzzle.grid.userPuzzle = Grid()
            puzzle.grid.userPuzzle?.fillWithZeros(num: SizeSudoku.count)
            self.appDelegate.sudoku = puzzle
            self.updateView()
        }
    }
    
    func updateView() {
        self.viewDidLoad()
        self.view.setNeedsDisplay()
        refresh()
    }

}
