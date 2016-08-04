# Hybird

# Hybird

测试JS 调用 swift 通过WkWebview


	JS统一通过
	“window.webkit.messageHandlers.fenglin.postMessage()
	调用iOS代码”

	定义的协议：参数类型
	{ 
	 "classMap":"类名",
	 "method":"方法名",
	 "params": "参数，一般为map",
	 "callbackId": "回调ID"	
	 }


	 1:可以通过 继承JSPlugin, 实现JS调用native。


 	2:可以通过 实现 JSNativeResponseDelegate接口。实现JS调用native


 	3:可以通过 对html5显示系统自带的alert窗口，也可以自定义。

 	4.实现了JS调用console.log(), 在xcode窗口显示其打印日志，此插件在“Console.js”中，可以运行JS后注入进去。可以监听到JS的所有log。
