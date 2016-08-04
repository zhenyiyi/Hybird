//
//  TestViewController.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/4.
//  Copyright © 2016年 cys. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, JSNativeResponseDelegate {

    var webMediator: WebViewMediator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webMediator = WebViewMediator(url: "", viewController: self);
        webMediator?.loadWebView();
    
    }
    @IBAction func callJS(sender: AnyObject) {
         webMediator?.nativeCallJS([ "1" : 2] as NSDictionary);
    }

    
    func js_test(param: NSDictionary?) {
        print(param!);
    }
    
    
    


}
