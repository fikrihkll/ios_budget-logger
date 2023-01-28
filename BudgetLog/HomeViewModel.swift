//
//  HomeViewModel.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 15/01/23.
//

import Foundation
import CoreData

class HomeViewModel: ObservableObject {
 
    @Published var listExpense = [Log]()
    var budgetId: UUID? = nil
    @Published var budgetInfo: Budget? = nil
    
    func getListExpence(budgetId: UUID, moc: NSManagedObjectContext) {
        listExpense.removeAll()
        
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        fetchRequest.predicate = NSPredicate(format: "budgetId = %@", budgetId as CVarArg)
        do {
            guard let result = try moc.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            
            for data in result {
                let currentLog = Log(
                    id: data.value(forKey: "id") as? UUID ?? UUID(),
                    budgetId: budgetId,
                    nominal: data.value(forKey: "nominal") as? Double ?? 0.0,
                    description: data.value(forKey: "desc") as? String ?? "",
                    date: data.value(forKey: "date") as? Double ?? 0.0,
                    category: data.value(forKey: "category") as? String ?? ""
                )
                listExpense.append(currentLog)
            }
            debugPrint("Log Count: \(listExpense.count)")
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func addExpense(moc: NSManagedObjectContext, log: Log) {
        listExpense.append(log)
        let saveableItem = LogData(context: moc)
        saveableItem.id = log.id
        saveableItem.budgetId = budgetId
        saveableItem.nominal = log.nominal ?? 0.0
        saveableItem.desc = log.description
        saveableItem.category = log.category
        saveableItem.date = log.date ?? 0.0
        
        do {
            try moc.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func setBudgetId(newBudgetId: UUID, moc: NSManagedObjectContext) {
        self.budgetId = newBudgetId
        getBudgetObject(moc: moc)
        getListExpence(budgetId: newBudgetId, moc: moc)
    }
    
    func getBudgetObject(moc: NSManagedObjectContext) {
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BudgetData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", budgetId! as CVarArg)
        do {
            guard let result = try moc.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            
            for data in result {
                budgetInfo = Budget(
                    id: budgetId!,
                    name: data.value(forKey: "name") as? String ?? "",
                    nominal: data.value(forKey: "nominal") as? Double ?? 0.0
                )
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func removeExpense(log: Log, moc: NSManagedObjectContext) {
        listExpense.removeAll { $0.id == log.id }
        deleteFromCoreData(id: log.id, moc: moc)
    }
    
    func deleteFromCoreData(id: UUID, moc: NSManagedObjectContext) {
        debugPrint("\(id.uuidString) will be deleted")
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        do {
            guard let result = try moc.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            guard let objc = result.first else { return }
            moc.delete(objc)
            try moc.save()
            debugPrint("Data Deleted")
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func editBudget(budgetId: UUID, newName: String, newNominal: Double, moc: NSManagedObjectContext) {
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BudgetData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", budgetId as CVarArg)
        do {
            guard let result = try moc.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            guard let objc = result.first else { return }
            objc.setValue(newName, forKey: "name")
            objc.setValue(newNominal, forKey: "nominal")
            do {
                try moc.save()
                budgetInfo?.name = newName
                budgetInfo?.nominal = newNominal
                debugPrint("Data Updated")
            } catch let error as NSError {
                debugPrint(error)
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
}
