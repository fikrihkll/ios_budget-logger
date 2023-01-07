//
//  BudgetLogApp.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 07/01/23.
//

import SwiftUI

@main
struct BudgetLogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
