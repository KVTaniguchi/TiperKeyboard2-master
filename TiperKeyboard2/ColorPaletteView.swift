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
    var updateColorCallback : ((_ colorIndex: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let metrics = ["width": ((UIScreen.main.bounds.width - 40)/5)]
        
        for index in 0...9 {
            var colorButton = UIButton(type: UIButtonType.custom)
            colorButton = UIButton(type: UIButtonType.custom)
            colorButton.tag = index
            colorButton.addTarget(self, action: #selector(ColorPaletteView.activateColorPicker(_:)), for: UIControlEvents.touchUpInside)
            colorButton.translatesAutoresizingMaskIntoConstraints = false
            colorButton.backgroundColor = colors[index]
            buttonArray.append(colorButton)
            addSubview(colorButton)
            
            if index == 0 || index == 5 {
                addConstraint(NSLayoutConstraint(item: colorButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            }
            else {
                let previousButton = buttonArray[index - 1]
                addConstraint(NSLayoutConstraint(item: colorButton, attribute: .left, relatedBy: .equal, toItem: previousButton, attribute: .right, multiplier: 1.0, constant: 0))
                if index == 9 || index == 4 {
                    addConstraint(NSLayoutConstraint(item: colorButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
                }
            }
            
            if index < 5 {
                addConstraint(NSLayoutConstraint(item: colorButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            }
            else {
                addConstraint(NSLayoutConstraint(item: colorButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
            }
            
            addConstraint(NSLayoutConstraint(item: colorButton, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[colorButton(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views:["colorButton":colorButton]))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activateColorPicker (_ sender : UIButton) {
        updateColorCallback?(sender.tag)
    }
    
}
