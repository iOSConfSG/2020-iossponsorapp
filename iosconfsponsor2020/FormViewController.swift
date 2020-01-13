//
//  FormViewController.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 9/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CryptoSwift

struct Attendee: Encodable {
    var name: String?
    var email: String?
    var additionalData: String?
}

class FormViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var additionalInfoTextView: UITextView!

    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    var attendee: Attendee!
    var dismissAction: (() -> Void)?
    var saveAction: (() -> Void)?

    // MARK: - Init
    class func instantiate(attendee: Attendee) -> FormViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(FormViewController.self)")  as! FormViewController
        viewController.attendee = attendee

        return viewController
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        nameTextField.text = attendee.name
        emailTextField.text = attendee.email
        additionalInfoTextView.text = attendee.additionalData

        CredentialManager.shared.getUserProfile()
    }

    private func configure() {
        self.title = "Attendee Details"
        _ = [nameTextField, emailTextField, additionalInfoTextView].map { $0?.setAppTheme() }
        saveButton.layer.cornerRadius = 5.0
        cancelButton.layer.cornerRadius = 5.0
    }
}

extension FormViewController  {
    @IBAction func saveButtonAction() {
        attendee.name = nameTextField.text
        attendee.email = emailTextField.text
        attendee.additionalData = additionalInfoTextView.text
        guard let name = CredentialManager.shared.profile?.name,
            let email = attendee.email else {
            return
        }

        var attendeeData = [
            "name": self.attendee.name,
            "email": self.attendee.email
        ]
        if self.attendee.additionalData?.isEmpty == false {
            attendeeData["additionalData"] = self.attendee.additionalData
        }

        Auth.auth().signInAnonymously() { (authResult, error) in
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child(name).child(email.md5()).setValue(attendeeData)
            self.dismissOnSave()
        }
    }

    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: { [weak self] in
            self?.dismissAction?()
        })
    }

    func dismissOnSave() {
        dismiss(animated: true) { [weak self] in
            self?.saveAction?()
        }
    }
}
