//
//  KeyboardViewController.swift
//  TiperKeyboardKB
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class KeyButton : UIButton {
    var keyText : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KeyboardViewController: UIInputViewController {
    
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var colors = [String:String]()
    var buttonArray = [UIButton]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var colorRef = [UIColor]()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.data = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        self.colors = self.sharedDefaults?.objectForKey(defaultColors) as! [String:String]
        
        self.colorRef = [UIColor.greenColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.darkGrayColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.magentaColor(), UIColor.purpleColor(), UIColor.lightGrayColor(), UIColor.brownColor()]
    
        self.data.append(["Next Keyboard":"Next Keyboard"])
        
        for (index, entry) in enumerate(data) {
            for (key, value) in entry {
                var color = self.colors[key] as String!
                self.addKeyboardButton("\(key) + \(color)", tag: index, keyText: value, colorIndex:"2")
            }
        }
    }
    
    func addKeyboardButton (keyTitle: String, tag: NSInteger, keyText: String, colorIndex: String) {
        let keyboardButton = KeyButton.buttonWithType(.Custom) as! KeyButton
        keyboardButton.setTitle(keyTitle, forState: .Normal)
        keyboardButton.keyText = keyText
        keyboardButton.layer.cornerRadius = 10
        keyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if keyTitle != "Next Keyboard" {
            keyboardButton.addTarget(self, action: "keyPressed:", forControlEvents: .TouchUpInside)
        }
        else {
            keyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        }

//        keyboardButton.backgroundColor = getRandomColor()
        keyboardButton.backgroundColor = self.colorRef[colorIndex.toInt()!]
        self.view.addSubview(keyboardButton)
        
        var keyboardTopConstraint = NSLayoutConstraint()
        if tag == 0 || tag == 5 {
            keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        }
        else if tag > 0 && tag < 10 {
            let previousButton = self.buttonArray[tag - 1] as UIButton
            keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: previousButton, attribute: .Bottom, multiplier: 1.0, constant: 0)
        }
        
        var keyboardWidth = NSLayoutConstraint(item: keyboardButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: self.data.count < 6 ? 1.0 : 0.5, constant: 0)
        
        var sideAttribute : NSLayoutAttribute?
        if tag <= 4 {
            sideAttribute = NSLayoutAttribute.Left
        }
        else if tag >= 5 {
            sideAttribute = NSLayoutAttribute.Right
        }
        var keyboardSideConstraint = NSLayoutConstraint(item: keyboardButton, attribute: sideAttribute!, relatedBy: .Equal, toItem: self.view, attribute: sideAttribute! , multiplier: 1.0, constant: 0)
        var keyboardHeight = NSLayoutConstraint(item: keyboardButton, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.2, constant: 0)
        
        self.view.addConstraints([keyboardTopConstraint, keyboardHeight, keyboardWidth, keyboardSideConstraint])
        self.buttonArray.append(keyboardButton)
    }
    
    func keyPressed (button: KeyButton) {
        let text = button.keyText
        let proxy = textDocumentProxy as!UITextDocumentProxy
        proxy.insertText(text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func textWillChange(textInput: UITextInput) {
    }

    override func textDidChange(textInput: UITextInput) {
        var textColor: UIColor
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        }
        else {
            textColor = UIColor.blackColor()
        }
    }
    
    func getRandomColor() -> UIColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
