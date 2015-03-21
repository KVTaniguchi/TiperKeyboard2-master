//
//  InterfaceController.swift
//  TiperKeyboard2 WatchKit Extension
//
//  Created by Kevin Taniguchi on 3/13/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("did awake with context")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
