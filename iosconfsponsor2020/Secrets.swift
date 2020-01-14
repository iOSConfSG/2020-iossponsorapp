//
//  Secrets.swift
//  iosconfsponsor2020
//
//  Created by Nikhil Sharma on 13/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import Foundation

struct Secrets {
    static let auth0ClientID = Bundle.main.infoDictionary?["auth0ClientID"] as! String
    static let auth0domain = Bundle.main.infoDictionary?["auth0domain"] as! String
    static let googleAppID = Bundle.main.infoDictionary?["googleAppID"] as! String
    static let gcmSenderID = Bundle.main.infoDictionary?["gcmSenderID"] as! String
    static let googleApiKey = Bundle.main.infoDictionary?["googleApiKey"] as! String
    static let googleClientID = Bundle.main.infoDictionary?["googleClientID"] as! String
    static let googleDatabaseURL = Bundle.main.infoDictionary?["googleDatabaseURL"] as! String
}
