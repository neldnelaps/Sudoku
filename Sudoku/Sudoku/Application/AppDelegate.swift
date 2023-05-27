//
//  AppDelegate.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 21.05.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var sudoku: SudokuClass = SudokuClass()
    var load: SudokuData?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        do {
            try saveLocalStorage(save: sudoku.grid)
        } catch {
            let nserror = error as NSError
            fatalError("Error: \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Sudoku")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: -  Save files
    func saveLocalStorage(save: SudokuData) throws {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let saveURL = documentsDirectory.appendingPathComponent("sudoku_save").appendingPathExtension("plist")

        guard let saveGame = try? PropertyListEncoder().encode(save) else {
            throw NSError(domain: "com.example.sudoku", code: 1, userInfo: [NSLocalizedDescriptionKey: "Save data encoding error"])
        }
        do {
            try saveGame.write(to: saveURL)
        } catch {
            throw NSError(domain: "com.example.sudoku", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error writing save data to file: \(error)"])
        }
    }
       
    // MARK: - Load Files
//    func loadLocalStorage() -> sudokuData {
//        let documentsDirectory =
//        FileManager.default.urls(for: .documentDirectory,
//                                 in: .userDomainMask).first!
//        let loadURL = documentsDirectory.appendingPathComponent("sudoku_save").appendingPathExtension("plist")
//        // Decode and Load from Local Storage
//        if let data = try? Data(contentsOf: loadURL) {
//            let decoder = PropertyListDecoder()
//            load = try? decoder.decode(sudokuData.self, from: data)
//            // once loaded, delete save
//            try? FileManager.default.removeItem(at: loadURL)
//        }
//
//        return load!
//    }
    
    func loadLocalStorage() throws -> SudokuData {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let loadURL = documentsDirectory.appendingPathComponent("sudoku_save").appendingPathExtension("plist")

        do {
            let data = try Data(contentsOf: loadURL)
            let decoder = PropertyListDecoder()
            let loadedData = try decoder.decode(SudokuData.self, from: data)
            try FileManager.default.removeItem(at: loadURL)
            return loadedData
        } catch let error {
            throw NSError(domain: "com.example.sudoku", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error loading save data: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - getPuzzles
    func getPuzzles(_ name : GameDifficulty) -> [String] {
        guard let url = Bundle.main.url(forResource: name.rawValue, withExtension: "plist") else { return [] }
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard let array = try? PropertyListDecoder().decode([String].self, from: data) else { return [] }
        return array
    }

}

