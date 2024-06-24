//
//  AutocallApp.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import SwiftUI

@main
struct AutocallApp: App {
    @StateObject private var viewModel = ContactsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
