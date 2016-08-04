//
//  JSPlugin.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/3.
//  Copyright © 2016年 cys. All rights reserved.
//

import UIKit
import WebKit



protocol JSPluginDelegate {
    var _web : WKWebView! { set get}
    var _taskId : Int!    { set get}
    var _data : NSDictionary?   { set get}
    func callback(values: NSDictionary?, compeletion: ((success: Bool, error: NSError?)->Void)?);
    func errorCallback(errorMessage : String);
}

///插件。。。。
class JSPlugin: NSObject, JSPluginDelegate {
    var _web: WKWebView!
    var _taskId: Int!
    var _data: NSDictionary?
    required override init() {
        
    }
    func callback(values: NSDictionary?, compeletion: ((success: Bool, error: NSError?)->Void)?) {
        do {
            var jsScript = "";
            if values != nil {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(values!, options: NSJSONWritingOptions());
                let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding);
                jsScript = "fireTask(\(self._taskId),\(jsonString!))";
            }else{
                jsScript = "fireTask(\(self._taskId))";
            }
            self._web.evaluateJavaScript(jsScript, completionHandler: { (response : AnyObject?, error : NSError?) in
                if let err = error {
                    if compeletion != nil{
                        compeletion!(success:false, error: err);
                    }
                }else {
                    if compeletion != nil{
                        compeletion!(success: true, error: nil);
                    }
                }
            })
        }catch let error as NSError{
            print(error.description);
            if compeletion != nil{
                compeletion!(success:false, error: error);
            }
        }
    }
    
    func errorCallback(errorMessage: String) {
        let js = "fireTask(\(self._taskId),\(errorMessage))";
        self._web.evaluateJavaScript(js) { (response : AnyObject?, error : NSError?) in
            
        }
    }
}

//MARK : 自定义实现JS conlose.log()；方法；

class Conlose: JSPlugin {
    func js_log()  {
        print(self._data);
    }
}



