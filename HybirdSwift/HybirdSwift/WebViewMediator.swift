//
//  WebViewMediator.swift
//  HybirdSwift
//
//  Created by fenglin on 16/8/4.
//  Copyright © 2016年 cys. All rights reserved.
//

import UIKit
import WebKit




//JSBridge通信中，模块类名
let CKJSKey_AppFunctions = "AppFunctions";
//JSBridge通信中，对应模块的方法名
let CKJSKey_NativeFunctions = "NativeFunctions";

//JSBridge通信中，对应模块的方法名
let CKJSClassNameKey = "classMap";
let CKJSMethodKey = "method";
let CKJSParamsKey = "params";
let CKJSTaskIdKey = "callbackId";
let CKJSKey_Callback = "callBack";
let CKJSKey_Code = "code";
let CKJSKey_CallbackId = "callbackId";
let CKJSKey_CallbackData = "data";
let CKJSKey_CallbackMessage = "msg";



let CKJSKey_CallJSMethodName = "callJS";
let CKJSKey_CallJSMethod_WebViewFinishedLoad = "web_view_finished_load";



let CKJSKey_CallbackMessage_NoFunction = "Have no this function，please check！";
let CKJSKey_CallbackMessage_NoModule = "Have no this Module，please check！";


let CKJSKeyNoti_DrawbackSuccess = "CKJSKeyNoti_DrawbackSuccess";

let CKJSKeyNoti_UserSendGetParkAction = "CKJSKeyNoti_UserSendGetParkAction";

let CKJSKeyNoti_TurnToPreferentialGuide = "CKJSKeyNoti_TurnToPreferentialGuide";



let jsConfigureName = "fenglin"


//MARK :
enum CKJSBridgerType : Int {
    case NoFunction = -2  // 没有此方法
    case NoModule = -1 // 没有此模块
    case OK = 0         // 成功
    case Failed = 1    //  失败
    case SaveDataFailed = 2 // 保存数据成功
    case GetDataFailed = 3  //  保存数据失败
}


class WebViewMediator : NSObject , WebViewMediatorDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{
    
    let _url : String?
    let _viewController : UIViewController?
    var _web: WKWebView!
    init(url : String, viewController : UIViewController) {
        _url = url;
        _viewController = viewController;
    }
    
    func loadWebView() {
        
        let configure = WKWebViewConfiguration();
        configure.userContentController.addScriptMessageHandler(self, name: jsConfigureName);
        
        self._web = WKWebView(frame: _viewController!.view.bounds, configuration: configure);
        self._web?.navigationDelegate = self;
        self._web?.UIDelegate = self;
        //        let carkeyHtml = NSBundle.mainBundle().pathForResource("carkey", ofType: "html");
        //        let content = try! String(contentsOfFile: carkeyHtml!);
        //        self.web?.loadHTMLString(content, baseURL: nil);
        self._web?.loadRequest(NSURLRequest(URL: NSURL(string: "http://127.0.0.1:8020/HelloHBuilder/3.html")!));
        _viewController!.view.addSubview(self._web!);
    }
    
    func callbackJS(code: CKJSBridgerType,callbackId:Int,message:String?) {
        let values = message == nil ?  [CKJSKey_Code : code.rawValue, CKJSKey_CallbackId : callbackId] :
           [CKJSKey_Code : code.rawValue, CKJSKey_CallbackId : callbackId, CKJSKey_CallbackMessage : message!]
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(values , options: NSJSONWritingOptions());
        var jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String;
        jsonString = "\(CKJSKey_Callback)(\(jsonString))"
        self._web.evaluateJavaScript(jsonString, completionHandler: nil);
    }
    
    func nativeCallJS(params: NSDictionary?) {
        var jsonString : String?
        if params != nil {
            do{
                let jsonData =  try NSJSONSerialization.dataWithJSONObject(params! , options: NSJSONWritingOptions())
                jsonString =  NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String;
                jsonString = "\(CKJSKey_CallJSMethodName)(\(jsonString!))"
            }catch let error as NSError{
                print(error.description);
            }
        }else{
           jsonString = "\(CKJSKey_CallJSMethodName)()"
        }
        
        self._web.evaluateJavaScript(jsonString!, completionHandler: nil);
    }
}


protocol WebViewMediatorDelegate {
    
    func loadWebView();
    
    // 我们直接调用JS， param eg : [ "1" : 2] key 不能为基本类型，否则会报错。
    func nativeCallJS(params: NSDictionary?);
    
    //用于回调JS.
    func callbackJS(code: CKJSBridgerType,callbackId:Int,message:String?);
}


// SystemUtil //与业务无关,手机系统相关的调用，如打电话、选择照片、保存照片等
@objc protocol JSNativeResponseDelegate {
    optional func js_call(param : NSDictionary?);
    optional func js_setPageTitle(param : NSDictionary?);
    optional func js_jumpTo(param : NSDictionary?);
    
    optional func js_goBack(param : NSDictionary?);
    optional func js_alertMessage(param : NSDictionary?);
    optional func js_toastMessage(param : NSDictionary?);
    
    optional func js_showLoadingView();
    optional func js_hideLoadingView();
    optional func js_goSetting(param : NSDictionary?);
}






/*! A class conforming to the WKScriptMessageHandler protocol provides a
 method for receiving messages from JavaScript running in a webpage.
 */
extension WebViewMediator{
    // MARK: JS 调用 swift 后得到传过来的消息。  只能够执行同步方法。
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("\(message.name)  +  \(message.body)");
        
        if message.name == jsConfigureName {
            
            if let res = message.body as? NSDictionary,
               let className = res[CKJSClassNameKey]?.description,
               var functionName = res[CKJSMethodKey]?.description,
               let tempTaskId = res[CKJSTaskIdKey]?.integerValue
            {
                functionName = "js_" + functionName;
                let params = res[CKJSParamsKey];
                let functionSelector = Selector(functionName);
                if functionName.isEmpty{
                    return
                }
                let conform = self._viewController!.conformsToProtocol(JSNativeResponseDelegate);
                if let cls = NSClassFromString((NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description)! + "." + className) as? JSPlugin.Type {
                    let obj = cls.init();
                    obj._web = self._web;
                    if params != nil {
                        obj._data =  params as? NSDictionary;
                    }
                    obj._taskId = tempTaskId;
                    
                    if obj.respondsToSelector(functionSelector){
                        obj.performSelector(functionSelector, withObject: params);
//                        obj.callback(["taskId" : tempTaskId ] as NSDictionary, compeletion: nil);
                        // 执行完这个方法，回调过去。
                        callbackJS(.OK, callbackId:tempTaskId, message: nil);
                    }else{
//                        obj.errorCallback("这个方法没有找到");
                        callbackJS(CKJSBridgerType.NoFunction, callbackId:tempTaskId, message: nil);
                        print("这个方法没有找到");
                    }
                }else{
                    
                    if conform {
                        if self._viewController!.respondsToSelector(functionSelector) {
                            self._viewController?.performSelector(functionSelector, withObject: params);
                            // 执行完这个方法，回调过去。
                            callbackJS(.OK, callbackId:tempTaskId, message: nil);
                        }else{
                            // 没有找到这个方法。
                            callbackJS(.NoFunction, callbackId:tempTaskId, message: nil);
                        }
                        
                    }else{
                        print("这个类没有找到");
                        callbackJS(CKJSBridgerType.NoModule, callbackId:tempTaskId, message: nil);
                    }
                }
            }else{
                print("调用失败");
            }
            
        }else{
            print("\(message.name) is wrong ");
        }
    }
}



extension WebViewMediator{
    // 处理加载失败事件
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription);
    }
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription);
    }
}


extension WebViewMediator{
    // 处理 alert() 事件
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action : UIAlertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil);
        }))
        self._viewController!.presentViewController(alert, animated: true, completion: nil);
        
        // 必须回调，否则会报错。。。
        completionHandler();
    }
}











