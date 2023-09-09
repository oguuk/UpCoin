//
//  CoreDataManager1.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/07.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    static var `default` = CoreDataManager()
    
    func count(forEntityName: String) -> Int {
        var count = 0
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: forEntityName)
        fetchRequest.resultType = .countResultType
        do {
            count = try context?.count(for: fetchRequest) ?? 0
        } catch {
            print("Error fetching count: \(error)")

        }
        return count
    }
    
    func save<T>(forEntityName: String, value: T) {
        guard let context = context,
              let entity = NSEntityDescription.entity(forEntityName: forEntityName, in: context) else { return }
        
        let mirror = Mirror(reflecting: value)
        
        guard let uniqueValue = mirror.descendant("koreanName") as? String else {
            print("Data does not have 'koreanName'.")
            return
        }
        
        if existEntityWith(uniqueValue: uniqueValue, entityName: forEntityName) { return }
        
        let newData = NSManagedObject(entity: entity, insertInto: context)
        
        mirror.children.forEach { (k, v) in
            guard let k else { return }
            newData.setValue(v, forKey: k)
        }
        
        contextSave(context: context)
    }
    
    func fetch<T: NSManagedObject & Nameable>(type: T.Type, name: String? = nil) -> [T]? {
        guard let context else { return nil }
        var data: [T]?
        do {
            data = try context.fetch(type.fetchRequest()) as? [T]
        } catch {
            print(error.localizedDescription)
        }
        return name == nil ? data : data?.filter { $0.Market! == name! || $0.KoreanName!.contains(name!) || $0.EnglishName!.contains(name!) }
    }
    
    func delete<T: NSManagedObject & Nameable>(type: T.Type, name: String? = nil) {
        guard let context else { return }
        guard let objects = fetch(type: type, name: name) else { return }
        for object in objects {
            context.delete(object)
            print("DEBUG : delete Complete \(object.entity.properties.map { $0.name })")
        }
        contextSave(context: context)
    }
    
    private func existEntityWith(uniqueValue: String, entityName: String) -> Bool {
        guard let context = context else { return false }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "koreanName == %@", uniqueValue)
        
        do {
            let existingData = try context.fetch(request)
            return existingData.count > 0
        } catch {
            print("Failed to fetch data: \(error)")
            return false
        }
    }
    
    private func contextSave(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("DEBUG: Save after delete successful!")
        } catch {
            print("DEBUG: Error saving context after delete: \(error)")
        }
    }
}
