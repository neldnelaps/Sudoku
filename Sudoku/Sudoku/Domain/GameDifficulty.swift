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
