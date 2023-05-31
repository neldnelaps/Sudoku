//
//  ContainerDI.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 30.05.2023.
//

import Foundation
import Swinject


class ContainerDI {
    
    static let container: Container = {
        let container = Container()
        container.register(RealmRepositoryProtocol.self) { _ in RealmRepository() }
        
        container.register(RealmUsecase.self) { r in RealmUsecase(realmRepository: r.resolve(RealmRepositoryProtocol.self)!) }
        
        container.register(MainViewModel.self) { r in
            MainViewModel(realmUsecase: r.resolve(RealmUsecase.self)!)
        }.inObjectScope(.container)
        
        container.register(GameViewModel.self)  {r in
            GameViewModel(realmUsecase: r.resolve(RealmUsecase.self)!)
        }.inObjectScope(.container)
    
    
        return container
    }()
    
}
