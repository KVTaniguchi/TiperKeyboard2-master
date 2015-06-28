//
//  CellSizesStruct.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/25/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import Foundation

public struct SizeBucket {
     func getSizes (collectionView : CGRect, count: Int, indexPath: NSIndexPath) -> CGSize {
        var size = CGSize()
        switch count {
        case 1:
            size = CGSizeMake(collectionView.width - 2, collectionView.height - 2)
        case 2:
            size = CGSizeMake((collectionView.width/2) - 2, collectionView.height - 2)
        case 3:
            size = CGSizeMake(collectionView.width - 2, collectionView.height/3 - 2)
        case 4:
            size = CGSizeMake((collectionView.width/2) - 2, (collectionView.height/2) - 2)
        case 5:
            if indexPath.item < 2 {
                size = CGSizeMake((collectionView.width/2) - 2, (collectionView.height/2) - 2)
            }
            else {
                size = CGSizeMake(collectionView.width/2 - 2, collectionView.height/3 - 2)
            }
        case 6:
            size = CGSizeMake((collectionView.width/2) - 2, (collectionView.height/3) - 2)
        case 7:
            if indexPath.item < 3 {
                size = CGSizeMake(collectionView.width/2 - 2, collectionView.height/3 - 2)
            }
            else {
                size = CGSizeMake(collectionView.width/2 - 2, collectionView.height/4 - 2)
            }
        case 8:
            size = CGSizeMake(collectionView.width/2 - 3, collectionView.height/4 - 3)
        default:
            println("2")
        }
        
        return size
    }
}