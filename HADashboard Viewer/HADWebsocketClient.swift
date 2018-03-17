//
//  HADWebsocketClient.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 16/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import Starscream

class HADWebsocketClient: NSObject, WebSocketDelegate {


    var socket: WebSocket?
    
    override init() {
        super.init()
        self.socket = WebSocket(url: URL(string: Secrets.homeassistantWebsocketUrl)!)
        self.socket!.delegate = self
        self.socket!.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    
}
