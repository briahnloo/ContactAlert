//
//  ContactsViewModel.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

//import callKit
import SwiftUI
import UniformTypeIdentifiers
import CoreXLSX

class ContactsViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var contacts: [Contact] = []
    @Published var showAlert = false
    @Published var alertMessage = ""

    // Function to present the document picker for uploading a spreadsheet
    func uploadSpreadsheet() {
        let supportedTypes: [UTType] = [.commaSeparatedText, UTType(filenameExtension: "xlsx")!, UTType(filenameExtension: "numbers")!]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        documentPicker.delegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    // Function to save contacts to the database
    private func saveContactsToDatabase(_ contacts: [Contact]) {
        for contact in contacts {
            DatabaseHelper.shared.insertContact(contact: contact)
        }
    }

    // Function to parse CSV file and save contacts
    private func parseCSV(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let content = String(data: data, encoding: .utf8) {
                let parsedContacts = CSVParser.parse(csvString: content)
                saveContactsToDatabase(parsedContacts)
                self.contacts = parsedContacts
                // reloadCallDirectoryExtension() // Uncomment if CallKit is being used
            }
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
            showAlert = true
            alertMessage = "Error reading CSV file: \(error.localizedDescription)"
        }
    }

    // Function to parse Excel file and save contacts
    private func parseExcel(at url: URL) {
        if let parsedContacts = CSVParser.parseExcel(at: url) {
            saveContactsToDatabase(parsedContacts)
            self.contacts = parsedContacts
            // reloadCallDirectoryExtension() // Uncomment if CallKit is being used
        } else {
            print("Error parsing Excel file.")
            showAlert = true
            alertMessage = "Error parsing Excel file."
        }
    }

    // Function to handle Numbers file (this requires third-party library or manual implementation)
    private func parseNumbers(at url: URL) {
        // Placeholder: Implement Numbers file parsing logic
        print("Parsing Numbers file at: \(url)")
        // Assuming parsedContacts is obtained after parsing the Numbers file
        // let parsedContacts: [Contact] = ...
        // saveContactsToDatabase(parsedContacts)
        // self.contacts = parsedContacts
    }

    // UIDocumentPickerDelegate method to handle document selection
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            print("No URL selected")
            showAlert = true
            alertMessage = "No URL selected"
            return
        }

        print("Selected URL: \(url)")

        // Ensure the file is accessible using NSFileCoordinator
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: url, error: &error) { (url) in
            print("Attempting to access security-scoped resource...")
            if url.startAccessingSecurityScopedResource() {
                defer {
                    print("Stopping access to security-scoped resource")
                    url.stopAccessingSecurityScopedResource()
                }

                print("Successfully accessed security-scoped resource")

                if url.pathExtension == "csv" {
                    parseCSV(at: url)
                } else if url.pathExtension == "xlsx" {
                    parseExcel(at: url)
                } else if url.pathExtension == "numbers" {
                    parseNumbers(at: url)
                } else {
                    print("Unsupported file type")
                    showAlert = true
                    alertMessage = "Unsupported file type"
                }
            } else {
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

    // Function to handle incoming call and display an alert if it's a sales call
    func handleIncomingCall(with phoneNumber: String) {
        if let contact = contacts.first(where: { $0.phoneNumber == phoneNumber }) {
            alertMessage = "SALES CALL: \(contact.name)"
            showAlert = true
        }
    }

    // Uncomment and implement if CallKit functionality is needed
    // func reloadCallDirectoryExtension() {
    //     CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.yourcompany.SalesCallApp.CallDirectoryExtension") { error in
    //         if let error = error {
    //             print("Error reloading extension: \(error.localizedDescription)")
    //             self.showAlert = true
    //             self.alertMessage = "Error reloading extension: \(error.localizedDescription)"
    //         } else {
    //             print("Extension reloaded successfully")
    //         }
    //     }
    // }
}
