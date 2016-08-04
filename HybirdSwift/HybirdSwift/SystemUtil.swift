//
//  SystemUtil.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/3.
//  Copyright © 2016年 cys. All rights reserved.
//  https://lvwenhan.com/ios/461.html  

import UIKit


class SystemUtil: JSPlugin {

    func js_call() {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self._data!["phoneNumber"]!)")!);
    }
}
