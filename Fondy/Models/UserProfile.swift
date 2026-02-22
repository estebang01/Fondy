//
//  UserProfile.swift
//  Fondy
//
//  Observable model for user profile data displayed in settings.
//

import SwiftUI

/// Observable model holding user profile information for display and editing.
@Observable
class UserProfile {
    var fullName: String
    var revtag: String
    var dateOfBirth: String
    var residentialAddress: String
    var country: String
    var phoneNumber: String
    var email: String
    var initials: String

    init(
        fullName: String = "",
        revtag: String = "",
        dateOfBirth: String = "",
        residentialAddress: String = "",
        country: String = "",
        phoneNumber: String = "",
        email: String = "",
        initials: String = ""
    ) {
        self.fullName = fullName
        self.revtag = revtag
        self.dateOfBirth = dateOfBirth
        self.residentialAddress = residentialAddress
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.initials = initials
    }

    /// Creates a mock profile for previews and development.
    static func createMock() -> UserProfile {
        UserProfile(
            fullName: "John Smith",
            revtag: "johnsmith92",
            dateOfBirth: "Jan 4, 1993",
            residentialAddress: "87 Ceylon Road\n#03-04\nSingapore 429665",
            country: "Singapore",
            phoneNumber: "+65 9123 4567",
            email: "john.smith@email.com",
            initials: "JS"
        )
    }

    /// Creates a profile from an authenticated UserRecord.
    static func from(user: UserRecord?) -> UserProfile {
        guard let user else { return createMock() }
        let names = user.fullName.split(separator: " ")
        let initials = names.compactMap { $0.first }.prefix(2).map { String($0).uppercased() }.joined()
        return UserProfile(
            fullName: user.fullName,
            revtag: user.email.components(separatedBy: "@").first ?? "",
            dateOfBirth: "",
            residentialAddress: "",
            country: "Singapore",
            phoneNumber: "",
            email: user.email,
            initials: initials
        )
    }
}
