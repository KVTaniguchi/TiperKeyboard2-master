//
//  ShortKeyUITests.swift
//  ShortKeyUITests
//
//  Created by Kevin Taniguchi on 9/27/15.
//  Copyright © 2015 Kevin Taniguchi. All rights reserved.
//

import XCTest
import UIKit

class ShortKeyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // WARNING : For this test to work, the keyboard needs to start from a zero state with no saved keys
    func testKeyAdditions() {
        
        let qqqElement = XCUIApplication().scrollViews.otherElements.collectionViews.cells.otherElements.containingType(.StaticText, identifier:"Qqq").element
        qqqElement.tap()
        
        let displayTextField = XCUIApplication().scrollViews.otherElements.textFields["Www"]
        XCTAssertEqual(displayTextField.value as? String, "Www", "Failed to correctly set the value of the collection view key cell")
    }
    
}
