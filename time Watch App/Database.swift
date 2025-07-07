//
//  Database.swift
//  time Watch App
//
//  Created by Show on 2025/1/11.
//

import Foundation
import SQLite3

// MARK: - Models

struct TimerItem: Identifiable {
    let id: Int
    let name: String
}

struct TimerRecord: Identifiable {
    let id: Int
    let itemId: Int
    let startTime: Int64
    let endTime: Int64
}

// MARK: - Protocols

protocol DatabaseManager {
    var db: OpaquePointer? { get }
    func openDatabase() -> Bool
    func closeDatabase()
}

protocol TimerItemRepository {
    func saveItem(name: String) -> Bool
    func getItems() -> [TimerItem]
    func deleteItem(id: Int) -> Bool
    func updateItem(id: Int, name: String) -> Bool
}

protocol TimerRecordRepository {
    func saveRecord(itemId: Int, startTime: Int64, endTime: Int64) -> Bool
    func getRecords(itemId: Int) -> [TimerRecord]
    func deleteRecord(id: Int) -> Bool
    func deleteRecords(itemId: Int) -> Bool
}

// MARK: - Implementation

class SQLiteDatabaseManager: DatabaseManager {
    var db: OpaquePointer?
    private let dbPath: String
    
    init() {
        dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/timer.sqlite")
    }
    
    func openDatabase() -> Bool {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened database")
            createTables()
            return true
        } else {
            print("Unable to open database")
            return false
        }
    }
    
    func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
        }
    }
    
    private func createTables() {
        let createItemTable = """
        CREATE TABLE IF NOT EXISTS TimerItem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        );
        """
        
        let createRecordTable = """
        CREATE TABLE IF NOT EXISTS TimerRecord (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId INTEGER,
            startTime INTEGER,
            endTime INTEGER,
            FOREIGN KEY (itemId) REFERENCES TimerItem(id)
        );
        """
        
        executeQuery(query: createItemTable)
        executeQuery(query: createRecordTable)
    }
    
    private func executeQuery(query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Query executed successfully")
            } else {
                print("Query execution failed")
            }
        } else {
            print("Query preparation failed")
        }
        sqlite3_finalize(statement)
    }
}

class SQLiteTimerItemRepository: TimerItemRepository {
    private let dbManager: DatabaseManager
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    func saveItem(name: String) -> Bool {
        let query = "INSERT INTO TimerItem (name) VALUES (?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer item saved successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to save timer item")
            }
        } else {
            print("INSERT statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func getItems() -> [TimerItem] {
        var items: [TimerItem] = []
        let query = "SELECT id, name FROM TimerItem;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                items.append(TimerItem(id: id, name: name))
            }
        }
        sqlite3_finalize(statement)
        return items
    }
    
    func deleteItem(id: Int) -> Bool {
        let query = "DELETE FROM TimerItem WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer item deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to delete timer item")
            }
        } else {
            print("DELETE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func updateItem(id: Int, name: String) -> Bool {
        let query = "UPDATE TimerItem SET name = ? WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer item updated successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to update timer item")
            }
        } else {
            print("UPDATE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
}

class SQLiteTimerRecordRepository: TimerRecordRepository {
    private let dbManager: DatabaseManager
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    func saveRecord(itemId: Int, startTime: Int64, endTime: Int64) -> Bool {
        let query = "INSERT INTO TimerRecord (itemId, startTime, endTime) VALUES (?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(itemId))
            sqlite3_bind_int64(statement, 2, startTime)
            sqlite3_bind_int64(statement, 3, endTime)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer record saved successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to save timer record")
            }
        } else {
            print("INSERT statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func getRecords(itemId: Int) -> [TimerRecord] {
        var records: [TimerRecord] = []
        let query = "SELECT id, startTime, endTime FROM TimerRecord WHERE itemId = ? ORDER BY startTime DESC;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(itemId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let startTime = sqlite3_column_int64(statement, 1)
                let endTime = sqlite3_column_int64(statement, 2)
                records.append(TimerRecord(id: id, itemId: itemId, startTime: startTime, endTime: endTime))
            }
        }
        sqlite3_finalize(statement)
        return records
    }
    
    func deleteRecord(id: Int) -> Bool {
        let query = "DELETE FROM TimerRecord WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer record deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to delete timer record")
            }
        } else {
            print("DELETE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func deleteRecords(itemId: Int) -> Bool {
        let query = "DELETE FROM TimerRecord WHERE itemId = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(itemId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Timer records deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to delete timer records")
            }
        } else {
            print("DELETE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
}

class TimerManager {
    static let shared = TimerManager()
    
    private let dbManager: SQLiteDatabaseManager
    private let itemRepository: TimerItemRepository
    private let recordRepository: TimerRecordRepository
    
    private init() {
        dbManager = SQLiteDatabaseManager()
        _ = dbManager.openDatabase()
        itemRepository = SQLiteTimerItemRepository(dbManager: dbManager)
        recordRepository = SQLiteTimerRecordRepository(dbManager: dbManager)
    }
    
    func getAllItems() -> [TimerItem] {
        return itemRepository.getItems()
    }
    
    func addItem(name: String) -> Bool {
        return itemRepository.saveItem(name: name)
    }
    
    func deleteItem(id: Int) -> Bool {
        _ = recordRepository.deleteRecords(itemId: id)
        return itemRepository.deleteItem(id: id)
    }
    
    func updateItem(id: Int, name: String) -> Bool {
        return itemRepository.updateItem(id: id, name: name)
    }
    
    func saveRecord(itemId: Int, startTime: Int64, endTime: Int64) -> Bool {
        return recordRepository.saveRecord(itemId: itemId, startTime: startTime, endTime: endTime)
    }
    
    func getRecords(itemId: Int) -> [TimerRecord] {
        return recordRepository.getRecords(itemId: itemId)
    }
    
    deinit {
        dbManager.closeDatabase()
    }
}
