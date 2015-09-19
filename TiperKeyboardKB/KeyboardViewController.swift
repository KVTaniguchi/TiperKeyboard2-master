//
//  KeyboardViewController.swift
//  TiperKeyboardKB
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class NextKeyboardButton : UIButton {
    var keyboardImage : UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
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
    let sizeBucket = KeyBoardSizeBucket()
    
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    
    var midScreenWidth : CGFloat {
        get {
            return screenWidth / 2
        }
    }
    
    var midscreenHeight : CGFloat {
        get {
            return screenHeight / 2
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.redColor()

        if sharedDefaults?.objectForKey(defaultskey) != nil {
            data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        }
        
        if sharedDefaults?.objectForKey(defaultColors) != nil {
            colors = sharedDefaults?.objectForKey(defaultColors) as! [String:String]
        }
    }
    
    override func viewDidLayoutSubviews() {
        buttonArray.removeAll()
        
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        
        for (index, entry) in data.enumerate() {
            for (key, value) in entry {
//                if let color = self.colors[key] as String! {
////                    addVariableKeySizeButtonWithTitle(key, tag: index, keyText: value, colorIndex: color)
//                }
//                else {
                    addVariableKeySizeButtonWithTitle(key, tag: index, keyText: value, colorIndex: "0")
//                }
            }
        }

        addSystemKeys()
    }
    
    func addSystemKeys () {
        let nextButton = UIButton()
        nextButton.setImage(UIImage(named: "keyboard-75"), forState: .Normal)
        nextButton.backgroundColor = UIColor.darkGrayColor()
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action:"advanceToNextInputMode", forControlEvents: .TouchUpInside)
        nextButton.sizeToFit()
        nextButton.frame = CGRectMake(screenWidth - 50.0, screenHeight - 50.0, 50, 50)
        
        let deleteButton = UIButton()
        deleteButton.backgroundColor = UIColor.lightGrayColor()
        deleteButton.setTitle("del", forState: UIControlState.Normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: "deleteWord", forControlEvents: .TouchUpInside)
        deleteButton.sizeToFit()
        deleteButton.frame = CGRectMake(CGRectGetMinX(nextButton.frame) - 50, screenHeight - 50, 50, 50)
        
        view.addSubview(deleteButton)
        view.addSubview(nextButton)
    }
    
    func addVariableKeySizeButtonWithTitle(keyTitle : String, tag : NSInteger, keyText : String, colorIndex : String) {
//        let size = sizeBucket.getSizes(data.count, indexOfItem: tag, frame: CGRectMake(0, 0, 375, 166))
        let keyButton = UIButton(type: .Custom)
        keyButton.layer.cornerRadius = 10
        keyButton.setTitle("T \(tag)", forState: .Normal)
        keyButton.setTitle(keyText, forState: .Disabled)
        keyButton.addTarget(self, action: "keyPressed:", forControlEvents: .TouchUpInside)
        
        switch data.count {
        case 1 :
            keyButton.frame = CGRectMake(0, 0, screenWidth, screenHeight/2)
            break
        case 2:
            keyButton.frame = CGRectMake(tag == 0 ? 0 : midScreenWidth, 0, screenWidth/2 - 2, screenHeight/2)
            break
        case 3:
            if tag == 0 {
                keyButton.frame = CGRectMake(0, 0, screenWidth/2, 200)
                keyButton.backgroundColor = UIColor.blueColor()
            }
            else if tag == 1 {
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 0, screenWidth/2 - 5, 100)
                keyButton.backgroundColor = UIColor.purpleColor()
            }
            else {
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 101, screenWidth/2 - 5, 50)
                keyButton.backgroundColor = UIColor.orangeColor()
            }
            break
        case 4:            print("asdf")
        case 5:            print("asdf")
        case 6:            print("asdf")
        case 7:            print("asdf")
        case 8:
                        print("asdf")
        default:
            print("asdf")
        }
        
        view.addSubview(keyButton)
    }
    
    func keyPressed (button: UIButton) {
        let originalColor = button.backgroundColor
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            button.backgroundColor = UIColor.lightGrayColor()
        }) { (value) in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                button.backgroundColor = originalColor
            })
        }
        let text = button.titleForState(.Disabled)
        let proxy = textDocumentProxy 
        proxy.insertText(text!)
    }
    
    func deleteWord () {
        let proxy = textDocumentProxy 
        proxy.deleteBackward()
        let tokens = proxy.documentContextBeforeInput!.componentsSeparatedByString(" ")
        for var index = 0; index  < tokens.last!.utf16.count; index++ {
            proxy.deleteBackward()
        }
    }

    override func textWillChange(textInput: UITextInput?) {
    }

    override func textDidChange(textInput: UITextInput?) {
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
