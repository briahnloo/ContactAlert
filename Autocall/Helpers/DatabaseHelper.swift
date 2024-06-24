//
//  DatabaseHelper.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import Foundation
import SQLite

class DatabaseHelper {
    static let shared = DatabaseHelper()
    private var db: Connection?

    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch {
            print("Unable to open database: \(error.localizedDescription)")
        }
    }

    private func createTable() {
        let contacts = Table("contacts")
        let id = Expression<Int64>("id")
        let phoneNumber = Expression<String>("phoneNumber")
        let name = Expression<String>("name")
        let company = Expression<String>("company")
        let notes = Expression<String>("notes")
        
        do {
            try db?.run(contacts.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(phoneNumber, unique: true)
                t.column(name)
                t.column(company)
                t.column(notes)
            })
        } catch {
            print("Unable to create table: \(error.localizedDescription)")
        }
    }

    func insertContact(contact: Contact) {
        let contacts = Table("contacts")
        let phoneNumber = Expression<String>("phoneNumber")
        let name = Expression<String>("name")
        let company = Expression<String>("company")
        let notes = Expression<String>("notes")

        let insert = contacts.insert(phoneNumber <- contact.phoneNumber, name <- contact.name, company <- contact.company, notes <- contact.notes)
        
        do {
            try db?.run(insert)
        } catch {
            print("Unable to insert contact: \(error.localizedDescription)")
        }
    }

    func getAllContacts() -> [Contact] {
        let contacts = Table("contacts")
        let phoneNumber = Expression<String>("phoneNumber")
        let name = Expression<String>("name")
        let company = Expression<String>("company")
        let notes = Expression<String>("notes")

        var contactList = [Contact]()

        do {
            for contact in try db!.prepare(contacts) {
                let contact = Contact(
                    phoneNumber: contact[phoneNumber],
                    name: contact[name],
                    company: contact[company],
                    notes: contact[notes]
                )
                contactList.append(contact)
            }
        } catch {
            print("Unable to fetch contacts: \(error.localizedDescription)")
        }

        return contactList
    }
}
