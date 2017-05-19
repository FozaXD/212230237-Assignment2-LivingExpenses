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
    
    //BillInformation
    let field_BillID = "billID"
    let field_BillName = "billName"
    let field_StartDate = "startDate"
    let field_EndDate = "endDate"
    let field_UEC = "uec"
    let field_Cost = "cost"
    let field_Paid = "paid"
    let field_UtilityTypeID = "utiltiyID"
    let field_UtilityType = "utilitytype"
    let field_CostPerUnit = "costperunit"
    let field_DailyCost = "dailycost"
    
    let field_Total = "total"
    
    //BillPaymentInformation
    let field_PaymentID = "paymentID"
    let field_UserID = "userID"
    let field_UserName = "username"
    let field_Payment = "payment"
    
    //UtilityReadingsInformation
    let field_ReadingID = "readingID"
    let field_Reading = "reading"
    
    //UserPayInformation
    let field_UserPayID = "userpayID"
    let field_PaidOn = "paidon"
    let field_Other = "other"
    let field_Amount = "amount"

    //Settings
    let field_SettingsID = "settingsID"
    let field_User1Name = "user1name"
    let field_User2Name = "user2name"
    let field_User1Paid = "user1paid"
    let field_User2Paid = "user2paid"
    let field_User1LastPayDate = "user1lastpaydate"
    let field_User2LastPayDate = "user2lastpaydate"
    let field_User1NextPayDate = "user1nextpaydate"
    let field_User2NextPayDate = "user2nextpaydate"
    let field_User1Share = "user1share"
    
    let databaseFileName = "database.sqlite"
    
    static let shared: DBManager = DBManager()
    
    //MARK: Variables
    var pathToDatabase: String!
    var database: FMDatabase!
    
    //MARK: Functions
    func decimal(string: String) -> NSNumber {
        formatter.numberStyle = NumberFormatter.Style.decimal
        return (formatter.number(from: string)) ?? 0
    }
    
    //Create Databases Function
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    //SetupBillsDB
                    var createTableQuery = "create table BillsDB (\(field_BillID) integer primary key autoincrement not null, \(field_BillName) text not null, \(field_StartDate) text not null, \(field_EndDate) text not null, \(field_UEC) bool not null default 0, \(field_Cost) string not null, \(field_Paid) string not null, \(field_UtilityType) string, \(field_CostPerUnit) string, \(field_DailyCost) string)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    //SetupBillPaymentsDB
                    createTableQuery = "create table BillPaymentsDB (\(field_PaymentID) integer primary key autoincrement not null, \(field_BillID) integer not null, \(field_BillName) text not null, \(field_UserID) integer not null, \(field_UserName) text not null, \(field_Payment) string)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    //SetupUtilityReadingsDB
                    createTableQuery = "create table UtilityReadingsDB (\(field_ReadingID) integer primary key autoincrement not null, \(field_BillID) integer not null, \(field_BillName) text not null, \(field_Reading) integer)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    //SetupUtilityTypesDB
                    createTableQuery = "create table UtilityTypesDB (\(field_UtilityTypeID) integer primary key autoincrement not null, \(field_UtilityType) text not null)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    //SetupUserPayDB
                    createTableQuery = "create table UserPayDB (\(field_UserPayID) integer primary key autoincrement not null, \(field_UserID) integer not null, \(field_UserName) text not null, \(field_PaidOn) text not null, \(field_Other) bool not null default 0, \(field_Payment) string)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    //SetupSettingsDB
                    createTableQuery = "create table SettingsDB (\(field_SettingsID) integer primary key autoincrement not null, \(field_User1Name) text not null, \(field_User2Name) text not null, \(field_User1Paid) integer, \(field_User2Paid) integer, \(field_User1LastPayDate) text not null, \(field_User2LastPayDate) text not null, \(field_User1NextPayDate) text not null, \(field_User2NextPayDate) text not null, \(field_User1Share) integer)"
                    
                    do {
                        try database.executeUpdate(createTableQuery, values: nil)
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
    
    //Insert Functions
    func insertBillData(billName: String, startDate: String, endDate: String, uec: Bool, cost: NSNumber, utilityType: String, costPerUnit: NSNumber, dailyCost: NSNumber) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into BillsDB (\(field_BillID), \(field_BillName), \(field_StartDate), \(field_EndDate), \(field_UEC), \(field_Cost), \(field_Paid), \(field_UtilityType), \(field_CostPerUnit), \(field_DailyCost)) values (null, '\(billName)', '\(startDate)', '\(endDate)', '\(Int(NSNumber(value: uec)))', '\(cost)', 0, '\(utilityType)', '\(costPerUnit)', '\(dailyCost)');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func insertBillPaymentData(billID: Int, billName: String, userID: Int, userName: String,  payment: NSNumber) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into BillPaymentsDB (\(field_PaymentID), \(field_BillID), \(field_BillName), \(field_UserID), \(field_UserName), \(field_Payment)) values (null, '\(billID)', '\(billName)', '\(userID)', '\(userName)', '\(payment)');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func insertUtilityReadingData(billID: Int, billName: String, reading: Int) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into UtilityReadingsDB (\(field_ReadingID), \(field_BillID), \(field_BillName), \(field_Reading)) values (null, '\(billID)', '\(billName)', '\(reading)');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func insertUserPayData(userID: Int, userName: String, paidOn: String, other: Bool, amount: NSNumber) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into UserPayDB (\(field_UserPayID), \(field_UserID), \(field_UserName), \(field_PaidOn), \(field_Other), \(field_Amount)) values (null, '\(userID)', '\(userName)', '\(paidOn)', '\(Int(NSNumber(value: other)))', '\(amount)');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
    
    func insertSettingsData(user1Name: String, user2Name: String, user1Paid: Int, user2Paid: Int, user1LastPay: String, user2LastPay: String, user1NextPay: String, user2NextPay: String, user1Share: Int) {
        
        if openDatabase() {
            
            var query = ""
            query += "insert into SettingsDB (\(field_SettingsID), \(field_User1Name), \(field_User2Name), \(field_User1Paid), \(field_User2Paid), \(field_User1LastPayDate), \(field_User2LastPayDate), \(field_User1NextPayDate), \(field_User2NextPayDate), \(field_User1Share)) values (null, '\(user1Name)', '\(user2Name)', '\(user1Paid)', '\(user2Paid)', '\(user1LastPay)', '\(user2LastPay)', '\(user1NextPay)', '\(user2NextPay)', '\(user1Share)');"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }

    //Load Functions
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
                                               paid: decimal(string: results.string(forColumn: field_Paid)),
                                               utilitytype: results.string(forColumn: field_UtilityType),
                                               costperunit: decimal(string: results.string(forColumn: field_CostPerUnit)),
                                               dailycost: decimal(string: results.string(forColumn: field_DailyCost))
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
            database.close()
        }
        
        return bills
    }
    
    func loadBillPayments() -> [BillPaymentInformation]! {
        var billPayments: [BillPaymentInformation]!
        
        if openDatabase() {
            let query = "select * from BillPaymentsDB order by \(field_BillName) asc"
            
            do {
                print(database)
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let billPayment = BillPaymentInformation(paymentID: Int(results.int(forColumn: field_PaymentID)),
                                               billID: Int(results.int(forColumn: field_BillID)),
                                               billName: results.string(forColumn: field_BillName),
                                               userID: Int(results.int(forColumn: field_UserID)),
                                               user: results.string(forColumn: field_UserName),
                                               payment: decimal(string: results.string(forColumn: field_Payment))
                    )
                    if billPayments == nil {
                        billPayments = [BillPaymentInformation]()
                    }
                    
                    billPayments.append(billPayment)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        
        return billPayments
    }
    
    func loadUtilityTypes() -> [UtilityTypesInformation]! {
        var utilityTypes: [UtilityTypesInformation]!
        
        if openDatabase() {
            let query = "select * from UtilityTypesDB order by \(field_UtilityType) asc"
            
            do {
                print(database)
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let utilityType = UtilityTypesInformation(utilityID: Int(results.int(forColumn: field_UtilityTypeID)),
                                                             utilityName: results.string(forColumn: field_UtilityType)
                    )
                    if utilityTypes == nil {
                        utilityTypes = [UtilityTypesInformation]()
                    }
                    
                    utilityTypes.append(utilityType)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        
        return utilityTypes
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
                                               paid: decimal(string: results.string(forColumn: field_Paid)),
                                               utilitytype: results.string(forColumn: field_UtilityType),
                                               costperunit: decimal(string: results.string(forColumn: field_CostPerUnit)),
                                               dailycost: decimal(string: results.string(forColumn: field_DailyCost))
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
                                                      paid: decimal(string: results.string(forColumn: field_Paid)),
                                                      utilitytype: results.string(forColumn: field_UtilityType),
                                                      costperunit: decimal(string: results.string(forColumn: field_CostPerUnit)),
                                                      dailycost: decimal(string: results.string(forColumn: field_DailyCost))
                    )
                    print(billInformation)
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
    
    func loadSettings(withID ID: Int, completionHandler: (_ setting: Settings?) -> Void) {
        var setting: Settings!
        formatter.generatesDecimalNumbers = true
        
        if openDatabase() {
            let query = "select * from SettingsDB where \(field_SettingsID)=?"
            
            do {
                let results = try database.executeQuery(query, values: [ID])
                
                if results.next() {
                    setting = Settings(settingID: Int(results.int(forColumn: field_SettingsID)),
                                                      user1Name: results.string(forColumn: field_User1Name),
                                                      user2Name: results.string(forColumn: field_User2Name),
                                                      user1paid: Int(results.int(forColumn: field_User1Paid)),
                                                      user2paid: Int(results.int(forColumn: field_User2Paid)),
                                                      user1lastPayDate: results.string(forColumn: field_User1LastPayDate),
                                                      user2lastPayDate: results.string(forColumn: field_User2LastPayDate),
                                                      user1nextPayDate: results.string(forColumn: field_User1NextPayDate),
                                                      user2nextPayDate: results.string(forColumn: field_User2NextPayDate),
                                                      shareUser1: Int(results.int(forColumn: field_User1Share))
                    )
                    print(setting)
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
        
        completionHandler(setting)
    }

    
    //Update Functions
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
    
    func updateSettings(withID ID: Int, user1Name: String, user2Name: String, user1Paid: Int, user2Paid: Int, user1LastPay: String, user2LastPay: String, user1NextPay: String, user2NextPay: String, user1Share: Int) {
        if openDatabase() {
            let query = "update SettingsDB set \(field_User1Name)=?, \(field_User2Name)=?,  \(field_User1Paid)=?, \(field_User2Paid)=?, \(field_User1LastPayDate)=?, \(field_User2LastPayDate)=?, \(field_User1NextPayDate)=?, \(field_User2NextPayDate)=?, \(field_User1Share)=? where \(field_SettingsID)=?"
            
            do {
                try database.executeUpdate(query, values: [user1Name, user2Name, user1Paid, user2Paid, user1LastPay, user2LastPay, user1NextPay, user2NextPay, user1Share, ID])
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }
    
    //Delete functions
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
    
    func loadSettingsRecordCount() -> Int {
        var count: Int = 0
        if openDatabase() {
            if let rs = database.executeQuery("SELECT COUNT(*) as Count FROM SettingsDB", withArgumentsIn: nil) {
                while rs.next() {
                    count = Int(rs.int(forColumn: "Count"))
                }
            }
            database.close()
        }
        
        return count
    }
    
    
//MARK: Override Functions
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
}
