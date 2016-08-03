//
//  ViewController.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/3.
//  Copyright © 2016年 cys. All rights reserved.
//

import UIKit
import WebKit

let jsConfigureName = "fenglin"

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    /*
     1. 苹果在 WKWebView 中的 js runtime 里事先注入了一个 window.webkit.messageHandlers.Rei.postMessage() 方法，我们可以使用这个方法直接向 Native 层传值，异常方便。首先，我们要把一个名为 OOXX 的 ScriptMessageHandler 注册到我们的 wk。
     */
    
    var web : WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configure = WKWebViewConfiguration();
        configure.userContentController.addScriptMessageHandler(self, name: jsConfigureName);
        
        self.web = WKWebView(frame: self.view.bounds, configuration: configure);
        self.web?.navigationDelegate = self;
        self.web?.UIDelegate = self;
//        let carkeyHtml = NSBundle.mainBundle().pathForResource("carkey", ofType: "html");
//        let content = try! String(contentsOfFile: carkeyHtml!);
//        self.web?.loadHTMLString(content, baseURL: nil);

        self.web?.loadRequest(NSURLRequest(URL: NSURL(string: "http://127.0.0.1:8020/HelloHBuilder/3.html")!));
        self.view.addSubview(self.web!);
        
    }
    
    
    
}


/*! A class conforming to the WKScriptMessageHandler protocol provides a
 method for receiving messages from JavaScript running in a webpage.
 */
extension ViewController{
    // JS 调用 swift 后得到传过来的消息。
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("\(message.name)  +  \(message.body)");
        
        if message.name == jsConfigureName {

            if let res = message.body as? NSDictionary {
                
                let className = res["className"]?.description;
                let functionName = res["functionName"]?.description;
                
                if let cls = NSClassFromString((NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description)! + "." + className!) as? NSObject.Type {
                    let obj = cls.init();
                    let functionSelector = Selector(functionName!);
                    if obj.respondsToSelector(functionSelector) {
                        obj.performSelector(functionSelector);
                    }else{
                        print("这个方法没有找到");
                    }
                }else{
                    print("这个类没有找到");
                }
            }
            
        }else{
            print("\(message.name) is wrong ");
        }
    }
}



extension ViewController{
    // 处理加载失败事件
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription);
    }
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription);
    }
}


extension ViewController{
    // 处理 alert() 事件
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action : UIAlertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil);
        }))
        self.presentViewController(alert, animated: true, completion: nil);
        
        // 必须回调，否则会报错。。。
        completionHandler();
    }
}




