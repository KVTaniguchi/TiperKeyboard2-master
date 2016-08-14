//
//  InformationViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/22/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController, UITextFieldDelegate {

    let previewTextField = UITextField()
    var settingsInstructionLabel = UILabel()
    let introLabel = UILabel()
    let instructionText = "1. Press the Home Button\n2. Open the Settings App.\n3. Tap General.\n4. Tap Keyboard.\n5. Tap Keyboards.\n6. Tap Add New Keyboard.\n7. Tap Short Key under Third Party Keyboards.\n8. Tap Short Key - Short Key.\n9. Toggle Allow Full Access.\n10. Press home and reopen Short Key."
    let trialRunText = "After enabling Short Key as a 3rd Party Keyboard in Settings, press the Globe next to the Space Bar and select Short\n Key."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        var swipeGestureRecognizer : UISwipeGestureRecognizer?
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(InformationViewController.swipeDown))
        swipeGestureRecognizer?.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer!)
        
        introLabel.numberOfLines = 0
        introLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        introLabel.font = UIFont.boldSystemFont(ofSize: 25)
        introLabel.text = "How To Start Using Short Key"
        introLabel.textAlignment = .center
        introLabel.textColor = UIColor.black
        introLabel.preferredMaxLayoutWidth = view.frame.width
        introLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(introLabel)
        
        previewTextField.autocorrectionType = .no
        previewTextField.clearButtonMode = .always
        previewTextField.textAlignment = .center
        previewTextField.backgroundColor = UIColor.lightGray
        previewTextField.placeholder = "Tap to try out Short Key"
        previewTextField.delegate = self
        previewTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewTextField)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attrString = NSMutableAttributedString(string: instructionText)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        settingsInstructionLabel.attributedText = attrString
        settingsInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsInstructionLabel.numberOfLines = 0
        settingsInstructionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        settingsInstructionLabel.textAlignment = .left
        settingsInstructionLabel.textColor = UIColor.darkGray
        settingsInstructionLabel.preferredMaxLayoutWidth = view.frame.width
        view.addSubview(settingsInstructionLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[intro]-[settingsInstructionLabel]-30-[preview(44)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["settingsInstructionLabel":settingsInstructionLabel, "preview":previewTextField, "intro":introLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[settingsInstructionLabel]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["settingsInstructionLabel":settingsInstructionLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[preview]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["preview":previewTextField]))
        view.addConstraint(NSLayoutConstraint(item: introLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        settingsInstructionLabel.text = trialRunText
        view.updateConstraintsIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyBoard()
    }
    
    func swipeDown () {
        dismissKeyBoard()
    }
    
    func dismissKeyBoard () {
        if previewTextField.isFirstResponder {
            previewTextField.resignFirstResponder()
            settingsInstructionLabel.text = instructionText
            previewTextField.text = ""
        }
    }
}
