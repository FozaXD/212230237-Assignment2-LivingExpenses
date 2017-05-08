//
//  DBManager.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 6/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit
//Global constant
let formatter = NumberFormatter()

class DBManager: NSObject {
    //MARK: Constants
    let field_BillID = "billID"
    let field_BillName = "billName"
    let field_StartDate = "startDate"
    let field_EndDate = "endDate"
    let field_UEC = "uec"
    let field_Cost = "cost"
    let field_Paid = "paid"
    let field_Total = "total"
    
    let databaseFileName = "database.sqlite"
    
    static let shared: DBManager = DBManager()
    
    //MARK: Variables
    var pathToDatabase: String!
    var database: FMDatabase!
    
    //MARK: Functions
    func decimal(string: String) -> NSNumber {
        formatter.maximumFractionDigits = 2
        return (formatter.number(from: string)) ?? 0
    }
    
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    let createBillsTableQuery = "create table BillsDB (\(field_BillID) integer primary key autoincrement not null, \(field_BillName) text not null, \(field_StartDate) text not null, \(field_EndDate) text not null, \(field_UEC) bool not null default 0, \(field_Cost) string not null, \(field_Paid) string not null)"
                    
                    do {
                        try database.executeUpdate(createBillsTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        
        return created
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
    func insertBillData(billName: String, startDate: String, endDate: String, uec: Bool, cost: NSNumber) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into BillsDB (\(field_BillID), \(field_BillName), \(field_StartDate), \(field_EndDate), \(field_UEC), \(field_Cost), \(field_Paid)) values (null, '\(billName)', '\(startDate)', '\(endDate)', '\(uec)', '\(cost)', '0');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func loadBills() -> [BillInformation]! {
        var bills: [BillInformation]!
        
        if openDatabase() {
            let query = "select * from BillsDB order by \(field_BillName) asc"
            
            do {
                print(database)
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let bill = BillInformation(billID: Int(results.int(forColumn: field_BillID)),
                                               billName: results.string(forColumn: field_BillName),
                                               startDate: results.string(forColumn: field_StartDate),
                                               endDate: results.string(forColumn: field_EndDate),
                                               uec: results.bool(forColumn: field_UEC),
                                               cost: decimal(string: results.string(forColumn: field_Cost)),
                                               paid: decimal(string: results.string(forColumn: field_Paid))
                    )
                    if bills == nil {
                        bills = [BillInformation]()
                    }
                    
                    bills.append(bill)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            print(bills)
            database.close()
        }
        
        return bills
    }
    
    func loadBillsForDate(date: Date) -> [BillInformation]! {
        var billsBySetDate: [BillInformation]!
        
        var dateToString: String
        
        dateFormatter.dateFormat = "dd/MM/yy"
        dateToString = dateFormatter.string(from: date)
        
        if openDatabase() {
            let query = "select * from BillsDB where \(field_EndDate) = '\(dateToString)' order by \(field_BillName) asc"
            
            do {
                print(database)
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let bill = BillInformation(billID: Int(results.int(forColumn: field_BillID)),
                                               billName: results.string(forColumn: field_BillName),
                                               startDate: results.string(forColumn: field_StartDate),
                                               endDate: results.string(forColumn: field_EndDate),
                                               uec: results.bool(forColumn: field_UEC),
                                               cost: decimal(string: results.string(forColumn: field_Cost)),
                                               paid: decimal(string: results.string(forColumn: field_Paid))
                    )
                    if billsBySetDate == nil {
                        billsBySetDate = [BillInformation]()
                    }
                    
                    billsBySetDate.append(bill)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            print(billsBySetDate)
            database.close()
        }
        
        return billsBySetDate
    }

    
    func loadBillsTotal() -> NSNumber {
        var result: NSNumber = 0.00
        
        if openDatabase() {
            let query = "select sum(\(field_Cost)) as \(field_Total) from BillsDB"
            
            do {
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    if results.string(forColumn: field_Total) != nil
                    {
                        let total: NSNumber = decimal(string: results.string(forColumn: field_Total))
                        result = total
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        return result
    }
    
    func loadBill(withID ID: Int, completionHandler: (_ billInformation: BillInformation?) -> Void) {
        var billInformation: BillInformation!
        formatter.generatesDecimalNumbers = true
        
        if openDatabase() {
            let query = "select * from BillsDB where \(field_BillID)=?"
            
            do {
                let results = try database.executeQuery(query, values: [ID])
                
                if results.next() {
                    billInformation = BillInformation(billID: Int(results.int(forColumn: field_BillID)),
                                                      billName: results.string(forColumn: field_BillName),
                                                      startDate: results.string(forColumn: field_StartDate),
                                                      endDate: results.string(forColumn: field_EndDate),
                                                      uec: results.bool(forColumn: field_UEC),
                                                      cost: decimal(string: results.string(forColumn: field_Cost)),
                                                      paid: decimal(string: results.string(forColumn: field_Paid))
                    )
                    
                }
                else {
                    print(database.lastError())
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        completionHandler(billInformation)
    }
    
    func updateBill(withID ID: Int, billName: String, cost: NSNumber, paid: NSNumber) {
        if openDatabase() {
            let query = "update BillsDB set \(field_BillName)=?, \(field_Cost)=?,  \(field_Paid)=? where \(field_BillID)=?"
            
            do {
                try database.executeUpdate(query, values: [billName, cost, paid, ID])
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }
    
    func deleteBill(withID ID: Int) -> Bool {
        var deleted = false
        
        if openDatabase() {
            let query = "delete from BillsDB where \(field_BillID)=?"
            
            do {
                try database.executeUpdate(query, values: [ID])
                deleted = true
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return deleted
    }
    
//MARK: Override Functions
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
}
