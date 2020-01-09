//
//  ViewController.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 8/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import Lock

class ViewController: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if !CredentialManager.shared.hasValid() {
            presentLogin()
        }
    }
}

// MARK: - Private
extension ViewController {
    private func presentLogin() {
        let lock = Lock
        .classic()
        // withConnections, withOptions, withStyle, and so on
        .withOptions {
          $0.oidcConformant = true
          $0.scope = "openid profile offline_access email user_metadata"
        }
        .withConnections {
            $0.database(name: "Username-Password-Authentication", requiresUsername: true)
        }
        .onAuth { credentials in
            CredentialManager.shared.store(credentials: credentials)
            CredentialManager.shared.getUserProfile()
            print("Obtained credentials \(credentials)")
        }
        .onError {
          print("Failed with \($0)")
        }
        .onCancel {
          print("User cancelled")
        }

        let loginViewController = LockViewController.init(lock: lock)
        DispatchQueue.main.async {
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}

