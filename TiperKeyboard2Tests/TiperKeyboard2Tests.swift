//
//  TiperKeyboard2Tests.swift
//  TiperKeyboard2Tests
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit
import XCTest

class TiperKeyboard2Tests: XCTestCase {
    
    var userVC = UserDataEntryViewController()
    var keyboardVC = KeyboardViewController()
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUserVCAddingNewItemIncreasesCount () {
        self.userVC.addNewItem()
        XCTAssertTrue(self.userVC.count > 0, "failed to add to key array")
    }
    
    
}
