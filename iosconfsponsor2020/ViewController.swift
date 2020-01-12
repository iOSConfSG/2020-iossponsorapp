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
        } else {
            showQRScanner()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.didCapture(qrcode: "Nikhil, he is awesome")
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
          $0.allow = [.Login]
        }
        .withConnections {
            $0.database(name: "Username-Password-Authentication", requiresUsername: true)
        }
        .onAuth { credentials in
            CredentialManager.shared.store(credentials: credentials)
            CredentialManager.shared.getUserProfile()
            print("Obtained credentials \(credentials)")
            self.showQRScanner()
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

    private func showQRScanner() {
        let qrScannerViewController = QRScannerViewController.instantiate()
        addChild(qrScannerViewController)
        qrScannerViewController.view.frame = view.bounds
        qrScannerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(qrScannerViewController.view)
        qrScannerViewController.didMove(toParent: self)
        qrScannerViewController.delegate = self
    }
}

extension ViewController: QRScannerViewControllerDelegate {
    func didTapTurnOnCamera() {
        //noop
    }

    func didCapture(qrcode: String) {
        let values = qrcode.split(separator: ",")
        var result = ["", "", ""]
        for (i, val) in values.enumerated() {
            result[i] = String(val)
        }

        let attendee = Attendee.init(name: result[0],
                                     email: result[1],
                                     company: result[2])

        let formViewController = FormViewController.instantiate(attendee: attendee)
        present(formViewController, animated: true, completion: nil)
    }
}

