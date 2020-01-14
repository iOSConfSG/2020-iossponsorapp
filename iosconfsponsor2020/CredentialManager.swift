//
//  CredentialManager.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 8/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import Foundation
import Auth0

class CredentialManager {
    static var shared: CredentialManager = CredentialManager()
    private static var auth0Authentication: Authentication {
        return Auth0.authentication(clientId: Secrets.auth0ClientID,
                                    domain: Secrets.auth0domain,
                                    session: URLSession.shared)
    }
    private let credentialManager = CredentialsManager(authentication: auth0Authentication)
    private(set) var profile: UserInfo? 

    private init() { }

    // MARK: - Manager
    func store(credentials: Credentials) {
        _ = credentialManager.store(credentials: credentials)
    }

    func retrieve(callback: @escaping (Credentials?) -> Void) {
        credentialManager.credentials { (error, credentials) in
            callback(credentials)
        }
    }

    func hasValid() -> Bool {
        return credentialManager.hasValid()
    }

    func clear() -> Bool {
        self.profile = nil
        return credentialManager.clear()
    }

    func getUserProfile() {
        guard hasValid() else {
            return
        }

        retrieve { credentials in
            guard let accessToken = credentials?.accessToken else { return }
            CredentialManager.auth0Authentication
                .userInfo(withAccessToken: accessToken)
                .start { result in
                    switch result {
                    case .success(let profile):
                        self.profile = profile
                    case .failure:
                        break
                    }
            }
        }
    }
}
