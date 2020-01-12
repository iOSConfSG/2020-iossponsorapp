//
//  FormViewController.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 9/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import Firebase

struct Attendee {
    var name: String?
    var email: String?
    var company: String?
}

class FormViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var companyTextField: UITextField!

    var attendee: Attendee!

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

        nameTextField.text = attendee.name
        emailTextField.text = attendee.email
        companyTextField.text = attendee.company
    }
}

extension FormViewController  {
    @IBAction func saveButtonAction() {
        CredentialManager.shared.getUserProfile()
        guard let userID = CredentialManager.shared.userId else {
            return
        }
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var attendeeData = ["name": attendee.name, "email": attendee.email]
        if attendee.company != "" {
            attendeeData["company"] = attendee.company
        }
        ref.child("users").child(userID).setValue(["user": attendeeData])
    }

    @IBAction func cancelButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}
