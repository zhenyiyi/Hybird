var console = {
    log : function(message){
        window.webkit.messageHandlers.fenglin.postMessage({
                                                          "classMap":"Conlose",
                                                          "method":"log",
                                                          "params":message,
                                                          "callbackId":1
                                                          }
        )
    }
}