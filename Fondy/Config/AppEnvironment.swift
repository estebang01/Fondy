//
//  AppEnvironment.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 22/02/26.
//

import Foundation

enum AppEnvironmentType: String {
    case development = "DEVELOPMENT"
    case production = "PRODUCTION"
}

enum AppEnvironment {
    
    static var current: AppEnvironmentType {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "APP_ENVIRONMENT"
        ) as? String,
              let env = AppEnvironmentType(rawValue: value) else {
            fatalError("ENVIRONMENT not configured")
        }
        return env
    }

    static let supabaseURL: URL = {
        guard let urlString = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_URL"
        ) as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not configured")
        }
        return url
    }()
    
    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_ANON_KEY"
        ) as? String else {
            fatalError("SUPABASE_ANON_KEY not configured")
        }
        return key
    }()
}
