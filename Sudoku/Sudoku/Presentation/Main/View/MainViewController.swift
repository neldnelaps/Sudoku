//
//  MainViewController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 22.05.2023.
//

import SnapKit
import Foundation
import UIKit
import RxSwift

class MainViewController: UIViewController {
    
    private var viewModel: MainViewModel!
    private var bag = DisposeBag()
    
    var newGameButton = UIButton(type: .system)
    var continueGameButton = UIButton(type: .system)
    var alert = UIAlertController(title: "Select difficulty".localized(), message: "", preferredStyle: .actionSheet)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = container.resolve(MainViewModel.self)!
        
        createNewGame()
        createContinueGameButton()
        createAlert()
    }
    
    // MARK: create style
    func styleButton(button: UIButton) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.1
    }
    
    // MARK: New Game
    func createNewGame(){
        newGameButton.setTitle("New game".localized(), for: .normal)
        newGameButton.addTarget(self, action: #selector(newGameTapped(_:)), for: .touchUpInside)
        
        view.addSubview(newGameButton)
        newGameButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(44)
            $0.leadingMargin.equalTo(64)
            $0.trailingMargin.equalTo(64)
        }
        
        styleButton(button: newGameButton)
    }
    
    @IBAction func newGameTapped(_ sender: UIButton) {
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    // MARK: Continue game
    func createContinueGameButton(){
        view.addSubview(continueGameButton)
        
        continueGameButton.setTitle("Continue game".localized(), for: .normal)
        continueGameButton.addTarget(self, action: #selector(continueGameTapped(_:)), for: .touchUpInside)
        
        continueGameButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(newGameButton.snp.bottom).offset(32)
            $0.height.equalTo(44)
            $0.leadingMargin.equalTo(64)
            $0.rightMargin.equalTo(64)
        }
        
        styleButton(button: continueGameButton)
    }
    
    @IBAction func continueGameTapped(_ sender: UIButton) {
        // Try to load saved game data from local storage
        do {
            guard let load = viewModel.loadSudoku() else {return}
            appDelegate.sudoku = load
            self.show(GameViewController(), sender: self)
        } catch {
            // If no saved game exists, check if there is a game in progress
            if appDelegate.sudoku.inProgress ?? false {
                self.show(GameViewController(), sender: self)
            } else {
                // If no saved game and no game in progress, show an alert
                let alert = UIAlertController(title: "Alert", message: "No Game in Progress & No Saved Games", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default, handler: { _ in }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func random(_ n:Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    // MARK: Alert
    func createAlert(){
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
            let puzzle = self.appDelegate.sudoku
            puzzle.grid.userPuzzle = Grid()
            puzzle.grid.userPuzzle?.fillWithZeros(num: SizeSudoku.count)
            self.appDelegate.sudoku = puzzle

            self.show(GameViewController(), sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:{ (UIAlertAction)in
            print("User click Cancel")
        }))
    }
    
    private func setupGridShow(gameDiff: GameDifficulty)
    {
        viewModel.removeSudoku()
    
        let puzzle = SudokuClass()
        puzzle.grid.gameDiff = gameDiff
        puzzle.levelGrid = LevelGenerator()
        puzzle.levelGrid?.gameGeneratorByDifficulty(difficulty: gameDiff)
        puzzle.grid.plistPuzzle = puzzle.levelGrid!.gridToSolve
        puzzle.сountsNumberOfDigitsInGrid()
        self.appDelegate.sudoku = puzzle
        
        self.show(GameViewController(), sender: self)
    }
    
}
