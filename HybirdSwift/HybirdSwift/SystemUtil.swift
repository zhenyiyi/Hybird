//
//  SystemUtil.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/3.
//  Copyright © 2016年 cys. All rights reserved.
//  https://lvwenhan.com/ios/461.html  

import UIKit


class SystemUtil: NSObject {

    func call(tel : String?) {
        print("will call \(tel) 注释：有参数");
        if let phoneNumber = tel {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!);
        }
    }
    func call() {
        print("call --> 注释：没有参数")
    }
}
