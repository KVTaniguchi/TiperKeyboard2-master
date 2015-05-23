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
    let trialRunText = "Press the Globe next to the Space Bar and Select Short Key to try out Short Key"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()

        var swipeGestureRecognizer : UISwipeGestureRecognizer?
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeGestureRecognizer?.direction = .Down
        view.addGestureRecognizer(swipeGestureRecognizer!)
        
        introLabel.text = "How To Start Using Short Key"
        introLabel.textAlignment = .Center
        introLabel.textColor = UIColor.darkGrayColor()
        introLabel.preferredMaxLayoutWidth = view.frame.width
        introLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(introLabel)
        
        previewTextField.textAlignment = .Center
        previewTextField.backgroundColor = UIColor.lightGrayColor()
        previewTextField.placeholder = "Tap to try out Short Key"
        previewTextField.delegate = self
        previewTextField.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(previewTextField)
        
        settingsInstructionLabel.text = instructionText
        settingsInstructionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        settingsInstructionLabel.numberOfLines = 0
        settingsInstructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        settingsInstructionLabel.textAlignment = .Left
        settingsInstructionLabel.textColor = UIColor.darkGrayColor()
        settingsInstructionLabel.preferredMaxLayoutWidth = view.frame.width
        view.addSubview(settingsInstructionLabel)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[intro]-[settingsInstructionLabel]-20-[preview(44)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["settingsInstructionLabel":settingsInstructionLabel, "preview":previewTextField, "intro":introLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[settingsInstructionLabel]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["settingsInstructionLabel":settingsInstructionLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[preview]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["preview":previewTextField]))
        view.addConstraint(NSLayoutConstraint(item: introLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        settingsInstructionLabel.text = trialRunText
    }
    
    func swipeDown () {
        if previewTextField.isFirstResponder() {
            previewTextField.resignFirstResponder()
            settingsInstructionLabel.text = instructionText
        }
    }
}
