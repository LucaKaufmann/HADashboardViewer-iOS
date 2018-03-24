//
//  HADWebsocketClient.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 16/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import Starscream
import SwiftyJSON

protocol HAWebSocketDelegate: AnyObject {
    func authenticated()
    func receivedResult(result: [[String:Any]])
    func receivedEvent(event: [String:Any])
}

class HADWebsocketClient: NSObject, WebSocketDelegate {

    weak var delegate: HAWebSocketDelegate?
    var sequence: Int = 0
    enum ResponseType: String {
        case authRequired = "auth_required"
        case authOk = "auth_ok"
        case result = "result"
        case event = "event"
    }

    enum RequestType: String {
        case authenticate = "auth"
        case eventSubscribe = "subscribe_events"
        case eventUnsubscrive = "unsubscribe_events"
        case getStates = "get_states"
        case callService = "call_service"
    }
    
    public enum EventTypes: String {
        case stateChange = "state_changed"
    }
    var socket: WebSocket?
    
    override init() {
        super.init()
        self.socket = WebSocket(url: URL(string: Secrets.homeassistantWebsocketUrl)!)
        self.socket!.delegate = self
        connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
        let json = JSON.init(parseJSON: text)
        if let type = json["type"].string {
            switch type {
            case ResponseType.authRequired.rawValue:
                authenticate()
            case ResponseType.authOk.rawValue:
                delegate?.authenticated()
            case ResponseType.result.rawValue:
                if let resultArray = json[ResponseType.result.rawValue].arrayObject as? [[String:Any]] {
                    delegate?.receivedResult(result: resultArray)
                }
            case ResponseType.event.rawValue:
                if let eventArray = json[ResponseType.event.rawValue].dictionaryObject {
                    delegate?.receivedEvent(event: eventArray)
                }
            default:
                break
            
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func connect() {
        sequence = 0
        socket!.connect()
    }
    
    func disconnect() {
        sequence = 0
        socket!.disconnect()
    }
    
    func send(message msg: String) {
        socket!.write(string: msg)
    }
    
    func lightsOff() {
        sequence += 1
        let dict: JSON = ["id": sequence, "type": RequestType.callService.rawValue, "domain": "light", "service": "turn_off"]
        guard let jsonString = dict.rawString() else {
            print("Lights off error")
            return
        }
        socket!.write(string: jsonString)
    }
    
    func toggle(entity: Entity) {
        sequence += 1
        let dict: JSON = ["id": sequence, "type": RequestType.callService.rawValue, "domain": entity.domain, "service": "toggle", "service_data": ["entity_id": entity.id]]
        guard let jsonString = dict.rawString() else {
            print("Call Service error")
            return
        }
        socket!.write(string: jsonString)
    }
    
    func getStates() {
        sequence += 1
        let dict: JSON = ["id": sequence, "type": RequestType.getStates.rawValue]
        guard let jsonString = dict.rawString() else {
            print("Get States error")
            return
        }
        socket!.write(string: jsonString)
    }
    
    func subscribeToEvent(event: EventTypes) {
        sequence += 1
        let dict: JSON = ["id": sequence, "type": RequestType.eventSubscribe.rawValue, "event_type": event.rawValue]
        guard let jsonString = dict.rawString() else {
            print("Subscribe event error")
            return
        }
        socket!.write(string: jsonString)
    }
    
    private func authenticate() {
        let authDictionary: JSON = ["type": "auth", "api_password": Secrets.apiPassword]
        guard let jsonString = authDictionary.rawString() else {
            print("authentication error")
            return
        }
        socket!.write(string: jsonString)
    }
    
}
