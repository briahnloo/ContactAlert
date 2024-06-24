//
//  Contact.swift
//  Autocall
//
//  Created by Brian Liu on 6/23/24.
//

import Foundation

struct Contact: Identifiable {
    var id = UUID()
    var phoneNumber: String
    var name: String
    var company: String
    var notes: String
}
