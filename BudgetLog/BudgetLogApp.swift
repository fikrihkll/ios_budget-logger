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
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
