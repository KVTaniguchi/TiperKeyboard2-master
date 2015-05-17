//
//  ColorPaletteView.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/16/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class ColorPaletteView: UIView {
    
    var buttonArray = [UIButton]()
    let colors = ColorPalette.colorRef
    var updateColorCallback : ((colorIndex: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var metrics = ["width": (UIScreen.mainScreen().bounds.width/5)]
        
        for index in 0...9 {
            var colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton.tag = index
            colorButton.addTarget(self, action: "activateColorPicker:", forControlEvents: UIControlEvents.TouchUpInside)
            colorButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            colorButton.backgroundColor = colors[index]
            buttonArray.append(colorButton)
            self.addSubview(colorButton)
            
            if index == 0 || index == 5 {
                self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0))
            }
            else {
                let previousButton = self.buttonArray[index - 1]
                self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Left, relatedBy: .Equal, toItem: previousButton, attribute: .Right, multiplier: 1.0, constant: 0))
                if index == 9 || index == 4 {
                    self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0))
                }
            }
            
            if index < 5 {
                self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
            }
            else {
                self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }
            
            self.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.5, constant: 0))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[colorButton(width)]", options: NSLayoutFormatOptions(0), metrics: metrics, views:["colorButton":colorButton]))
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activateColorPicker (sender : UIButton) {
        self.updateColorCallback?(colorIndex:sender.tag)
    }
    
}
