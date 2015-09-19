//
//  CellSizesStruct.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/25/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import Foundation
import UIKit

public struct KeyBoardSizeBucket {
    func getSizes (numberOfKeys : Int, indexOfItem : Int, frame : CGRect) -> CGSize {
        var radius = CGFloat(0.0)
        switch numberOfKeys {
        case 1 : radius = 0.45 * frame.width
        case 2 : radius = indexOfItem == 0 ? 0.45 * frame.width : 0.30 * frame.width
        case 3 :
            switch indexOfItem {
            case 0 : radius = 0.58 * frame.width
            case 1 : radius = 0.38 * frame.width
            default : return CGSizeMake(frame.width - 2, 0.21 * frame.height)
            }
        case 4 :
            switch indexOfItem {
            case 0: return CGSizeMake(0.58 * frame.width, 0.73 * frame.height)
            case 1: radius = 0.38 * frame.width
            default: return CGSizeMake(0.49 * frame.width, 0.27 * frame.height)
            }
        case 5 :
            switch indexOfItem {
            case 0: return CGSizeMake(0.58 * frame.width, 0.73 * frame.height)
            case 1: radius = 130
            default: return CGSizeMake(112, 65)
            }
        case 6 :
            switch indexOfItem {
            case 0: return CGSizeMake(0.58 * frame.width, 0.73 * frame.height)
            case 1: radius = 0.38 * frame.width
            default: return CGSizeMake(0.24 * frame.width, 0.27 * frame.height)
            }
        case 7 :
            switch indexOfItem {
            case 0: return CGSizeMake(0.4 * frame.width, 0.60 * frame.height)
            case 1 : return CGSizeMake(0.29 * frame.width, 0.60 * frame.height)
            case 2 : return CGSizeMake(0.29 * frame.width, 0.60 * frame.height)
            default : return CGSizeMake(0.24 * frame.width, 0.39 * frame.height)
            }
        case 8 :
            switch indexOfItem {
            case 0 : return CGSizeMake(0.59 * frame.width, 0.39 * frame.height)
            case 1 : return CGSizeMake(0.39 * frame.width, 0.39 * frame.height)
            case 2 : return CGSizeMake(0.49 * frame.width, 0.34 * frame.height)
            case 3 : return CGSizeMake(0.49 * frame.width, 0.34 * frame.height)
            default : return CGSizeMake(0.24 * frame.width, 0.25 * frame.height)
            }
        case 9 :
            switch indexOfItem {
            case 0 : return CGSizeMake(0.59 * frame.width, 0.39 * frame.height)
            case 1 : return CGSizeMake(0.39 * frame.width, 0.39 * frame.height)
            case 2 : return CGSizeMake(0.32 * frame.width, 0.34 * frame.height)
            case 3 : return CGSizeMake(0.32 * frame.width, 0.34 * frame.height)
            case 4 : return CGSizeMake(0.32 * frame.width, 0.34 * frame.height)
            default : return CGSizeMake(0.24 * frame.width, 0.25 * frame.height)
            }
        default : radius = 0
        }
        
        return CGSizeMake(radius, radius)
    }
}