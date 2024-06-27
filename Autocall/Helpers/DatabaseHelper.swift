//
//  Parser.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import Foundation
import CoreXLSX

struct CSVParser {
    static func parse(csvString: String) -> [Contact] {
        var contacts: [Contact] = []
        let rows = csvString.components(separatedBy: "\n")
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 3 {
                let contact = Contact(
                    phoneNumber: columns[1].trimmingCharacters(in: .whitespaces),
                    name: columns[0].trimmingCharacters(in: .whitespaces),
                    company: columns[2].trimmingCharacters(in: .whitespaces),
                    notes: columns.count > 3 ? columns[3].trimmingCharacters(in: .whitespaces) : ""
                )
                contacts.append(contact)
            }
        }
        return contacts
    }
    
    static func parseExcel(at url: URL) -> [Contact]? {
        guard let file = XLSXFile(filepath: url.path) else { return nil }
        
        do {
            guard let sharedStrings = try file.parseSharedStrings() else { return nil }
            var contacts: [Contact] = []
            
            for path in try file.parseWorksheetPaths() {
                let worksheet = try file.parseWorksheet(at: path)
                for row in worksheet.data?.rows ?? [] {
                    let columns = row.cells.map { cell -> String in
                        if let stringValue = cell.stringValue(sharedStrings) {
                            return stringValue
                        } else if let value = cell.value {
                            return value
                        } else {
                            return ""
                        }
                    }
                    if columns.count >= 3 {
                        let contact = Contact(
                            phoneNumber: columns[1],
                            name: columns[0],
                            company: columns[2],
                            notes: columns.count > 3 ? columns[3] : ""
                        )
                        contacts.append(contact)
                    }
                }
            }
            return contacts
        } catch {
            print("Error parsing Excel file: \(error.localizedDescription)")
            return nil
        }
    }
}
