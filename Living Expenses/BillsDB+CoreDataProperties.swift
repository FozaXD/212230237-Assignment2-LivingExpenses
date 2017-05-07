//
//  BillsDB+CoreDataProperties.swift
//  
//
//  Created by Alexander Fotheringham on 5/5/17.
//
//

import Foundation
import CoreData


extension BillsDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BillsDB> {
        return NSFetchRequest<BillsDB>(entityName: "BillsDB")
    }

    @NSManaged public var billname: String?
    @NSManaged public var cost: NSDecimalNumber?

}
