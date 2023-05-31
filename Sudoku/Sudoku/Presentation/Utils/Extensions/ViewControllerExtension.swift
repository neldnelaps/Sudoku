//
//  ViewControllerExtension.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation
import UIKit
import Swinject

extension UIViewController {

    var container: Container {
        ContainerDI.container
    }

}
