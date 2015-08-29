//
//  LocationUpdate.swift
//  
//
//  Created by Nicky Advokaat on 28/08/15.
//
//

import Foundation
import CoreData

@objc(LocationUpdate)
class LocationUpdate: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("LocationUpdate", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    func toString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        let dateString = dateFormatter.stringFromDate(date)
        
        return "\(dateString) \(longitude), \(latitude)"
    }
    
}
