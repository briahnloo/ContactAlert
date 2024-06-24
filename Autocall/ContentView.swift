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
                VStack(alignment: .leading) {
                    Text(contact.name)
                        .font(.headline)
                    Text(contact.phoneNumber)
                        .font(.subheadline)
                    if !contact.company.isEmpty {
                        Text("Company: \(contact.company)")
                            .font(.subheadline)
                    }
                    if !contact.notes.isEmpty {
                        Text("Notes: \(contact.notes)")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Contacts")
            .onAppear {
                viewModel.reloadCallDirectoryExtension()
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
                        viewModel.handleIncomingCall(with: "1234567890") // Replace with a test number
                    }) {
                        Text("Test Call")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
