//
//  ViewControllerTest.swift
//  TestYandex
//
//  Created by admin on 13.08.15.
//  Copyright (c) 2015 iosOleksii. All rights reserved.
//

import UIKit
import XCTest
import Quick
import Nimble
import TestYandex

class ViewControllerTest: QuickSpec {
    override func spec() {
        var viewController: ViewController!
        
        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController : UINavigationController? = storyboard.instantiateInitialViewController() as? UINavigationController
            viewController = storyboard.instantiateViewControllerWithIdentifier("ViewControllerID") as! ViewController
            UIApplication.sharedApplication().keyWindow!.rootViewController = viewController
            
            XCTAssertNotNil(navigationController?.view)
            XCTAssertNotNil(viewController.view)
            let _ = navigationController!.view
            let _ = viewController.view
        }
        
        describe(".viewDidLoad()") {
            it("check table view") {
                XCTAssertNotNil(viewController.tableView)
            }
            it("check title") {
                expect(viewController.title).to(equal("Яндекс.Денег"))
            }
        }
        
        describe("the view") {
            beforeEach {
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
        }
        
        describe(".viewWillDisappear()") {
            beforeEach {
                viewController.viewWillDisappear(false)
            }
        }
    }
}
