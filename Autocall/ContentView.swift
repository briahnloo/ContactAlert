//
//  ContentView.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContactsViewModel

    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                VStack(alignment: .leading, spacing: 10) {
                    Text("• Name: \(contact.name)")
                        .font(.headline)
                    Text("• Phone Number: \(contact.phoneNumber)")
                        .font(.subheadline)
                    if !contact.company.isEmpty {
                        Text("• Company: \(contact.company)")
                            .font(.subheadline)
                    }
                    if !contact.notes.isEmpty {
                        Text("• Notes: \(contact.notes)")
                            .font(.subheadline)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("Contacts")
            .onAppear {
                // Optionally reload Call Directory Extension if needed
                // viewModel.reloadCallDirectoryExtension()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.uploadSpreadsheet()
                    }) {
                        Text("Upload")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.handleIncomingCall(with: "4159964437") // my own number?
                    }) {
                        Text("Test Call")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("SALES CALL"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
