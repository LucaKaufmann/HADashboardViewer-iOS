//
//  HADEntityManager.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 30/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import Foundation
import UIKit

protocol HAEntityManagerDelegate: AnyObject {
    func presenceChanged(shouldScreenBeOn: Bool)
    func entityUpdated(entity: Entity)
    func refreshUI()
}

class HADEntityManager: NSObject, HAWebSocketDelegate {
    
    
    static let instance = HADEntityManager()
    let webSocketClient = HADWebsocketClient()
    
    let delegates = MulticastDelegate<HAEntityManagerDelegate>()
    
    let interestingEntities = ["fan.xiaomi_air_purifier", "light.paperlight", "light.big_light", "light.hallway", "light.kitchen", "light.desk", "light.yellow_light", "light.hallway_upstairs", "group.tracked_devices", "input_boolean.sleeping", "device_tracker.tiiaphone", "device_tracker.sevenplus", "input_boolean.follow_music", "switch.start_vacuum", "switch.clean_kitchen", "input_boolean.schedule_cleaning", "input_boolean.schedule_kitchen_cleaning", "input_boolean.cleaning_doublepass", "vacuum.eve"]
    let presenceEntities = ["group.tracked_devices", "input_boolean.sleeping"]

    var entities = [String:Entity]()
    
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.connect),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.disconnect),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        webSocketClient.delegate = self
    }
    
    func add(delegate: HAEntityManagerDelegate) {
        delegates.addDelegate(delegate: delegate)
    }
    
    func remove(delegate: HAEntityManagerDelegate) {
        delegates.removeDelegate(delegate: delegate)
    }
    
    @objc func connect() {
        webSocketClient.connect()
    }
    
    @objc func disconnect() {
        webSocketClient.disconnect()
    }
    
    func authenticated() {
        webSocketClient.getStates()
        webSocketClient.subscribeToEvent(event: .stateChange)
    }
    
    func receivedResult(result: [[String:Any]]) {
        for jsonEntity in result {
            if let entity = Entity.init(JSONData: jsonEntity) {
                var newEntity = entity
                if self.interestingEntities.contains(entity.id) {
                    self.entities[newEntity.id] = newEntity
                }
            }
        }
        checkPresence()
        delegates.invoke(invocation: { $0.refreshUI() })
    }
    
    func receivedEvent(event: [String:Any]) {
        if let data = event["data"] as? [String:AnyObject]{
            if let entity = data["new_state"] as? [String:AnyObject] {
                if let entityId = entity["entity_id"] as? String {
                    if self.interestingEntities.contains(entityId) {
                        guard var updatedEntity = self.entities[entityId] else {
                            return
                        }
                        updatedEntity.state = entity["state"] as? String
                        self.entities[entityId] = updatedEntity
                        delegates.invoke(invocation: { $0.entityUpdated(entity: updatedEntity) })
                        
                    }
                    if self.presenceEntities.contains(entityId) {
                        checkPresence()
                    }
                }
            }
        }
    }
    
    func checkPresence() {
        var screenOn = false
        if let presenceEntity = entities["group.tracked_devices"] {
            if presenceEntity.state == "home" {
                screenOn = true
            } else {
                screenOn = false
            }
        }
        
        
        if let sleepingEntity = entities["input_boolean.sleeping"] {
            if sleepingEntity.state == "on" {
                screenOn = false
            } 
        }
        
        delegates.invoke(invocation: { $0.presenceChanged(shouldScreenBeOn: screenOn) })
    }
    
    func toggleEntity(entityId: String) {
        if let entity = entities[entityId] {
            webSocketClient.toggle(entity: entity)
        }
    }
    
    func allLightsOff() {
        webSocketClient.lightsOff()
    }
    
}
