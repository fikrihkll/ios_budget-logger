//
//  BudgetListBottomSheetViewModel.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 28/01/23.
//

import Foundation
import CoreData

class BudgetListViewModel: ObservableObject {
    
    @Published var listBudget = [Budget]()
    
    func getListBudget(moc: NSManagedObjectContext) {
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BudgetData")
        do {
            guard let result = try moc.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            
            for data in result {
                let currentBudget = Budget(
                    id: data.value(forKey: "id") as? UUID ?? UUID(),
                    name: data.value(forKey: "name") as? String ?? "",
                    nominal: data.value(forKey: "nominal") as? Double ?? 0.0
                )
                listBudget.append(currentBudget)
            }
            debugPrint("HERE")
            debugPrint(listBudget.count)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func addNewBudget(name: String, moc: NSManagedObjectContext) -> UUID? {
        let saveableItem = BudgetData(context: moc)
        saveableItem.id = UUID()
        saveableItem.name = name
        saveableItem.nominal =  0.0
        
        do {
            try moc.save()
            return saveableItem.id
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func removeBudget(id: UUID, moc: NSManagedObjectContext) {
        deleteFromCoreData(id: id, moc: moc)
        listBudget.removeAll{ $0.id == id }
    }
    
    func deleteFromCoreData(id: UUID, moc: NSManagedObjectContext) {
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BudgetData")
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
    
}
