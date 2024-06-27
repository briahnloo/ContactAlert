////
////  CallDirectoryHandler.swift
////  Autocall
////
////  Created by Brian Liu on 6/23/24.
////
//
//import CallKit
//
//class CallDirectoryHandler: CXCallDirectoryProvider {
//    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
//        context.delegate = self
//        addIdentificationPhoneNumbers(to: context)
//        context.completeRequest()
//    }
//
//    private func addIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
//        let contacts = loadContactsFromDatabase()
//        for contact in contacts {
//            if let phoneNumberInt = Int64(contact.phoneNumber) {
//                context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumberInt, label: contact.name)
//            }
//        }
//    }
//
//    private func loadContactsFromDatabase() -> [Contact] {
//        // Load contacts from local database (CoreData, SQLite, etc.)
//        return DatabaseHelper.shared.getAllContacts()
//    }
//} 
// 
//extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
//    func requestFailed(for context: CXCallDirectoryExtensionContext, withError error: Error) {
//        print("Request failed: \(error.localizedDescription)")
//    }
//}
