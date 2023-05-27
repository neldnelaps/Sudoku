//
//  String.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 22.05.2023.
//

import Foundation

extension String {
    
    func localized() -> String {
        NSLocalizedString(self, tableName: "Localizable", bundle: Bundle(path: "Resources") ?? .main, value: self, comment: self)
    }
    
}
