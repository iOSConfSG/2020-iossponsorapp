//
//  ViewController.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 8/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import Lock
import Firebase
import MBProgressHUD

class ViewController: UIViewController {
    var qrScannerViewController: QRScannerViewController?
    @IBOutlet var logoutButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if !CredentialManager.shared.hasValid() {
            presentLogin()
        } else {
            showQRScanner()
        }
    }
}

// MARK: - Private
extension ViewController {
    private func presentLogin() {
        let lock = Lock
        .classic(clientId: Secrets.auth0ClientID, domain: Secrets.auth0domain)
        .withOptions {
          $0.oidcConformant = true
          $0.scope = "openid profile offline_access email user_metadata"
            $0.allow = [.Login, .ResetPassword]
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
        self.view.bringSubviewToFront(self.logoutButton)

        self.qrScannerViewController = qrScannerViewController
    }

    @IBAction func didTapLogOut() {
        _ = CredentialManager.shared.clear()
        presentLogin()
    }

    private func showHUD() {
        let imageview = UIImageView.init(image: UIImage.init(named: "Checkmark")?.withRenderingMode(.alwaysTemplate))
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.customView = imageview
        hud.mode = .customView
        hud.label.text = "Saved"
        hud.show(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            hud.hide(animated: true)
        })
    }
}

extension ViewController: QRScannerViewControllerDelegate {
    func didTapTurnOnCamera() {
        //noop
    }

    func didCapture(qrcode: String) {
        guard let data = Data(base64Encoded: qrcode) else {
            return
        }

        let value = String(data: data, encoding: .utf8)
        let values = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: ",") ?? []
        var result = ["", "", ""]
        for (i, val) in values.enumerated() {
            result[i] = String(val)
        }

        let attendee = Attendee.init(name: result[0],
                                     email: result[1],
                                     additionalData: result[2])

        let formViewController = FormViewController.instantiate(attendee: attendee)
        formViewController.dismissAction = {
            self.qrScannerViewController?.startSession()
        }
        formViewController.saveAction =  {
            self.qrScannerViewController?.startSession()
            self.showHUD()
        }
        let navigationController = UINavigationController.init(rootViewController: formViewController)
        navigationController.presentationController?.delegate = self
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if self.qrScannerViewController?.parent != nil {
            self.qrScannerViewController?.startSession()
        }
    }
}
