//
//  Parser.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import Foundation

class CSVParser {
    static func parse(csvString: String) -> [Contact] {
        var contacts: [Contact] = []
        let rows = csvString.components(separatedBy: "\n")
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 3 {
                let contact = Contact(phoneNumber: columns[0], name: columns[1], company: columns[2], notes: columns.count > 3 ? columns[3] : "")
                contacts.append(contact)
            }
        }
        
        return contacts
    }
}
