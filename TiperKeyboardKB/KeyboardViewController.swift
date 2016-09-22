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
    var buttonArray = [UIButton]()
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var colors = [String: String]()
    var sharedDefaults = UserDefaults(suiteName: "group.InfoKeyboard")
    
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    
    var midScreenWidth : CGFloat { return screenWidth / 2 }
    var midscreenHeight : CGFloat { return screenHeight / 2 }

    override func viewDidLoad() {
        super.viewDidLoad()

        if sharedDefaults?.object(forKey: defaultskey) != nil {
            let tempData = sharedDefaults?.object(forKey: defaultskey) as! [[String:String]]
            
            data = sharedDefaults?.object(forKey: defaultskey) as! [[String:String]]
            
        }
        view.backgroundColor = UIColor.white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        
        for (index, entry) in data.enumerated() {
            for (key, value) in entry {
                addVariableKeySizeButtonWithTitle(key, tag: index, keyText: value)
            }
        }
        
        addSystemKeys()
    }
    
    func addSystemKeys () {
        let nextButton = UIButton()
        nextButton.setImage(UIImage(named: "keyboard-75"), for: UIControlState())
        nextButton.backgroundColor = UIColor.white
        nextButton.layer.cornerRadius = 2
        nextButton.addTarget(self, action:#selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
        nextButton.frame = CGRect(x: screenWidth - screenWidth/8, y: screenHeight - screenWidth/8, width: screenWidth/8 - 1, height: screenWidth/8)
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(named: "delete_sign-50"), for: UIControlState())
        deleteButton.layer.cornerRadius = 2
        deleteButton.addTarget(self, action: #selector(KeyboardViewController.deleteWord), for: .touchUpInside)
        deleteButton.frame = CGRect(x: nextButton.frame.minX - screenWidth/8, y: screenHeight - screenWidth/8, width: screenWidth/8 - 1, height: screenWidth/8)
        buttonArray.append(nextButton)
        buttonArray.append(deleteButton)
        view.addSubview(deleteButton)
        view.addSubview(nextButton)
    }
    
    func addVariableKeySizeButtonWithTitle(_ keyTitle : String, tag : NSInteger, keyText : String) {
        let keyButton = UIButton(type: .custom)
        keyButton.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        keyButton.setTitleColor(UIColor.black, for: UIControlState())
        keyButton.layer.cornerRadius = 2
        keyButton.layer.borderColor = UIColor.darkGray.cgColor
        keyButton.layer.borderWidth = 1.0
        keyButton.setTitle(keyTitle, for: UIControlState())
        keyButton.setTitle(keyText, for: .disabled)
        keyButton.addTarget(self, action: #selector(KeyboardViewController.keyPressed(_:)), for: .touchUpInside)
        buttonArray.append(keyButton)
        
        switch data.count {
        case 1 :
            keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - screenWidth/8 - 10)
            break
        case 2:
            if tag == 0 {
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth/2 - 2, height: screenWidth/2 - 2)
            }
            else {
                keyButton.frame = CGRect(x: midScreenWidth, y: 0, width: screenWidth/2 - 2, height: screenWidth/2 - 40)
            }
            break
        case 3:
            if tag == 0 {
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth/2, height: 200)
            }
            else if tag == 1 {
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 0, width: screenWidth/2 - 5, height: 100)
            }
            else {
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 101, width: screenWidth/2 - 5, height: 48)
            }
            break
        case 4:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 2/3 - 1, height: 100)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth * 2/3, y: 0, width: screenWidth/3 - 1, height: 100)
                break
            case 2:
                keyButton.frame = CGRect(x: 0, y: 101, width: screenWidth/2 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 101, width: screenWidth/2 - 1, height: 58)
                break
            default: keyButton.frame = CGRect.zero
            }
        case 5:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 2/3 - 1, height: 100)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth * 2/3, y: 0, width: screenWidth/3 - 1, height: 100)
                break
            case 2:
                keyButton.frame = CGRect(x: 0, y: 101, width: screenWidth/3 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: screenWidth/3 - 1, y: 101, width: screenWidth/3 - 1, height: 100)
                break
            case 4:
                keyButton.frame = CGRect(x: (screenWidth * 2/3) - 1, y: 101, width: screenWidth/3 - 1, height: 58)
                break
            default:
                keyButton.frame = CGRect.zero
            }
        case 6:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 2/3 - 1, height: 110)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth * 2/3, y: 0, width: screenWidth/3 - 1, height: 110)
                break
            case 2:
                keyButton.frame = CGRect(x: 0, y: 111, width: screenWidth/4 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: screenWidth/4 - 1, y: 111, width: screenWidth/4 - 1, height: 100)
                break
            case 4:
                keyButton.frame = CGRect(x: screenWidth/2 - 1, y: 111, width: screenWidth/4 - 1, height: 100)
                break
            case 5:
                keyButton.frame = CGRect(x: (screenWidth * 3/4) + 1, y: 111, width: screenWidth/4 - 1, height: 58)
                break
            default:
                keyButton.frame = CGRect.zero
            }
        case 7:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth/2 - 1, height: 100)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth/2, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 2:
                keyButton.frame = CGRect(x: screenWidth * 3/4, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: 0, y: 101, width: screenWidth/4 - 1, height: 100)
                break
            case 4:
                keyButton.frame = CGRect(x: screenWidth/4 - 1, y: 101, width: screenWidth/4 - 1, height: 100)
                break
            case 5:
                keyButton.frame = CGRect(x: screenWidth/2 - 1, y: 101, width: screenWidth/4 - 1, height: 100)
                break
            case 6:
                keyButton.frame = CGRect(x: (screenWidth * 3/4) + 1, y: 101, width: screenWidth/4 - 1, height: 58)
                break
            default:
                keyButton.frame = CGRect.zero
            }
        
        case 8:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth/2 - 1, height: 100)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth/2, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 2:
                keyButton.frame = CGRect(x: screenWidth * 3/4, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: 0, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 4:
                keyButton.frame = CGRect(x: screenWidth/4 + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 5:
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 6:
                keyButton.frame = CGRect(x: (screenWidth * 3/4) + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 7:
                keyButton.frame = CGRect(x: 0, y: 169, width: screenWidth * 3/4 - 1, height: 47)
            default:
                keyButton.frame = CGRect.zero
            }
            
        case 9:
            switch tag {
            case 0:
                keyButton.frame = CGRect(x: 0, y: 0, width: screenWidth/2 - 1, height: 100)
                break
            case 1:
                keyButton.frame = CGRect(x: screenWidth/2, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 2:
                keyButton.frame = CGRect(x: screenWidth * 3/4, y: 0, width: screenWidth/4 - 1, height: 100)
                break
            case 3:
                keyButton.frame = CGRect(x: 0, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 4:
                keyButton.frame = CGRect(x: screenWidth/4 + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 5:
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 6:
                keyButton.frame = CGRect(x: (screenWidth * 3/4) + 1, y: 101, width: screenWidth/4 - 1, height: 67)
                break
            case 7:
                keyButton.frame = CGRect(x: 0, y: 169, width: screenWidth/2, height: 48)
                break
            case 8:
                keyButton.frame = CGRect(x: screenWidth/2 + 1, y: 169, width: screenWidth/4 - 1, height: 46)
                break
            default:
                keyButton.frame = CGRect.zero
            }
            
            default: keyButton.frame = CGRect.zero
        }
        
        view.addSubview(keyButton)
    }
    
    func keyPressed (_ button: UIButton) {
        let originalColor = button.backgroundColor
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            button.backgroundColor = UIColor.lightGray
        }) { (value) in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                button.backgroundColor = originalColor
            })
        }
        let text = button.title(for: .disabled)
        let proxy = textDocumentProxy 
        proxy.insertText(text!)
        
        advanceToNextInputMode()
    }
    
    func deleteWord () {
        let proxy = textDocumentProxy 
        proxy.deleteBackward()
        let tokens = proxy.documentContextBeforeInput!.components(separatedBy: " ")
        for _ in 0 ..< tokens.last!.utf16.count {
            proxy.deleteBackward()
        }
    }

    override func textWillChange(_ textInput: UITextInput?) {
        
    }

    override func textDidChange(_ textInput: UITextInput?) {
    }
}
