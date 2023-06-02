//
//  GameDifficulty.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 27.05.2023.
//

import Foundation
import RealmSwift
                           
@objc enum GameDifficulty: Int, RealmEnum {
    case light
    case average
    case hard
    case expert
    case crazy
}

extension GameDifficulty {
    func toString() -> String {
        switch self {
        case .light:
            return "Light".localized()
        case .average:
            return "Average".localized()
        case .hard:
            return "Hard".localized()
        case .expert:
            return "Expert".localized()
        case .crazy:
            return "Crazy".localized()
        }
    }
}
