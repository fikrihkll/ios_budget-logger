//
//  HomeViewModel.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 15/01/23.
//

import Foundation

class HomeViewModel: ObservableObject {
 
    @Published var listExpense = [Log]()
    
    func getListExpence() {
        listExpense = [
            Log(id: UUID(), nominal: 1000000.0, description: "BMW M5", date: Date().timeIntervalSince1970, category: "Car"),
            Log(id: UUID(), nominal: 2400000.0, description: "KTM 250", date: Date().timeIntervalSince1970, category: "Bike"),
            Log(id: UUID(), nominal: 9.0, description: "Coffee", date: Date().timeIntervalSince1970, category: "Drink")
        ]
    }
    
    func addExpense(log: Log) {
        listExpense.append(log)
    }
    
    func removeExpense(index: Int) {
        listExpense.remove(at: index)
    }
    
}
