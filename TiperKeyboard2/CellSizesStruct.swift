//
//  CellSizesStruct.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/25/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import Foundation

public struct SizeBucket {
    func getSizes (_ numberOfKeys : Int, indexOfItem : Int, frame : CGRect) -> CGSize {
        var radius = CGFloat(0.0)
        switch numberOfKeys {
        case 1 : radius = 0.63 * frame.width
        case 2 : radius = indexOfItem == 0 ? 0.57 * frame.width : 0.37 * frame.width
        case 3 :
            switch indexOfItem {
            case 0 : radius = 0.50 * frame.width
            case 1 : radius = 0.45 * frame.width
            default : return CGSize(width: frame.width - 2, height: 0.20 * frame.height)
            }
        case 4 :
            switch indexOfItem {
            case 0: return CGSize(width: 0.58 * frame.width, height: 0.72 * frame.height)
            case 1: radius = 0.37 * frame.width
            default: return CGSize(width: 0.49 * frame.width, height: 0.26 * frame.height)
            }
        case 5 :
            switch indexOfItem {
            case 0: return CGSize(width: 0.58 * frame.width, height: 0.72 * frame.height)
            case 1: radius = 129
            default: return CGSize(width: 112, height: 64)
            }
        case 6 :
            switch indexOfItem {
            case 0: return CGSize(width: 0.58 * frame.width, height: 0.72 * frame.height)
            case 1: radius = 0.38 * frame.width
            default: return CGSize(width: 0.24 * frame.width, height: 0.26 * frame.height)
            }
        case 7 :
            switch indexOfItem {
            case 0: return CGSize(width: 0.4 * frame.width, height: 0.59 * frame.height)
            case 1 : return CGSize(width: 0.29 * frame.width, height: 0.59 * frame.height)
            case 2 : return CGSize(width: 0.29 * frame.width, height: 0.59 * frame.height)
            default : return CGSize(width: 0.24 * frame.width, height: 0.38 * frame.height)
            }
        case 8 :
            switch indexOfItem {
            case 0 : return CGSize(width: 0.59 * frame.width, height: 0.38 * frame.height)
            case 1 : return CGSize(width: 0.39 * frame.width, height: 0.38 * frame.height)
            case 2 : return CGSize(width: 0.49 * frame.width, height: 0.33 * frame.height)
            case 3 : return CGSize(width: 0.49 * frame.width, height: 0.33 * frame.height)
            default : return CGSize(width: 0.24 * frame.width, height: 0.24 * frame.height)
            }
        case 9 :
            switch indexOfItem {
            case 0 : return CGSize(width: 0.59 * frame.width, height: 0.38 * frame.height)
            case 1 : return CGSize(width: 0.39 * frame.width, height: 0.38 * frame.height)
            case 2 : return CGSize(width: 0.32 * frame.width, height: 0.33 * frame.height)
            case 3 : return CGSize(width: 0.32 * frame.width, height: 0.33 * frame.height)
            case 4 : return CGSize(width: 0.32 * frame.width, height: 0.33 * frame.height)
            default : return CGSize(width: 0.24 * frame.width, height: 0.24 * frame.height)
            }
        default : radius = 0
        }
        
        return CGSize(width: radius, height: radius)
    }
}
