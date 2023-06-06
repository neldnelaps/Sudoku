//
//  WinViewController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 05.06.2023.
//

import UIKit
import Lottie

class WinViewController: UIViewController {

    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var winLabel: UILabel!
    
    @IBOutlet weak var diffLabel: UILabel!
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    private var lottieAnimation: LottieAnimationView?
    
    var diff : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnimation()
        
        winLabel.text = "Victory!".localized()
        gameLabel.text = "Game: ".localized()
        diffLabel.text = diff
        
        newGameButton.setTitle("Home".localized(), for: .normal)
    }
    
    func createAnimation() {
        self.lottieAnimation = .init(name: "win")
        self.lottieAnimation!.frame = self.animationView.bounds
        self.lottieAnimation!.contentMode = .scaleAspectFit
        self.lottieAnimation!.loopMode = .loop
        self.lottieAnimation!.animationSpeed = 0.5
        self.animationView.addSubview(lottieAnimation!)
        self.lottieAnimation!.play()
    }
    
    @IBAction func mainAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func newGameAction(_ sender: Any) {
        
    }

}
