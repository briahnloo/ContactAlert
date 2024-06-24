//
//  ContactsViewModel.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import SwiftUI
import UniformTypeIdentifiers
import CallKit
import CoreXLSX

class ContactsViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var contacts: [Contact] = []
    @Published var showAlert = false
    @Published var alertMessage = ""

    func uploadSpreadsheet() {
        let supportedTypes: [UTType] = [.commaSeparatedText, UTType(filenameExtension: "xlsx")!]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
    }

    func reloadCallDirectoryExtension() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.yourcompany.SalesCallApp.CallDirectoryExtension") { error in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
                self.showAlert = true
                self.alertMessage = "Error reloading extension: \(error.localizedDescription)"
            } else {
                print("Extension reloaded successfully")
            }
        }
    }


    private func saveContactsToDatabase(_ contacts: [Contact]) {
        for contact in contacts {
            DatabaseHelper.shared.insertContact(contact: contact)
        }
    }

    private func parseCSV(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let content = String(data: data, encoding: .utf8) {
                let parsedContacts = CSVParser.parse(csvString: content)
                saveContactsToDatabase(parsedContacts)
                self.contacts = parsedContacts
                reloadCallDirectoryExtension()
            }
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
            showAlert = true
            alertMessage = "Error reading CSV file: \(error.localizedDescription)"
        }
    }

    private func parseExcel(at url: URL) {
        do {
            guard let file = XLSXFile(filepath: url.path) else {
                print("Error opening Excel file")
                showAlert = true
                alertMessage = "Error opening Excel file"
                return
            }
            guard let sharedStrings = try file.parseSharedStrings() else {
                print("Error parsing shared strings")
                showAlert = true
                alertMessage = "Error parsing shared strings"
                return
            }
            var parsedContacts: [Contact] = []

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
                        let contact = Contact(phoneNumber: columns[1], name: columns[0], company: columns[2], notes: columns.count > 3 ? columns[3] : "")
                        parsedContacts.append(contact)
                    }
                }
            }

            saveContactsToDatabase(parsedContacts)
            self.contacts = parsedContacts
            reloadCallDirectoryExtension()
        } catch {
            print("Error reading Excel file: \(error.localizedDescription)")
            showAlert = true
            alertMessage = "Error reading Excel file: \(error.localizedDescription)"
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        // Ensure the file is accessible using NSFileCoordinator
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: url, error: &error) { (url) in
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                
                if url.pathExtension == "csv" {
                    parseCSV(at: url)
                } else if url.pathExtension == "xlsx" {
                    parseExcel(at: url)
                } else {
                    print("Unsupported file type")
                    showAlert = true
                    alertMessage = "Unsupported file type"
                }
            } else {
                print("Could not access security-scoped resource")
                showAlert = true
                alertMessage = "Could not access security-scoped resource"
            }
        }

        if let error = error {
            print("File coordination error: \(error.localizedDescription)")
            showAlert = true
            alertMessage = "File coordination error: \(error.localizedDescription)"
        }
    }

    func handleIncomingCall(with phoneNumber: String) {
        if let contact = contacts.first(where: { $0.phoneNumber == phoneNumber }) {
            alertMessage = "SALES CALL: \(contact.name)"
            showAlert = true
        }
    }
}
