//
//  HADWebSocketViewController.swift
//  HADashboard Viewer
//
//  Created by Luca on 24/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import SwiftyJSON

class HADWebSocketViewController: UIViewController, HAWebSocketDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    enum TableSection: Int {
        case lights = 0, mediaPlayers, fans, groups, inputBoolean, deviceTracker, total
    }
    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 25
    
    // Data variable to track our sorted data.
    var data = [TableSection: [Entity]]()

    let webSocketClient = HADWebsocketClient()
    //var entities = [String:Entity]()
    var entities = [Entity]()
    let interestingEntities = ["fan.xiaomi_air_purifier", "light.living_room", "media_player.living_room_tv", "media_player.living_room", "media_player.speaker", "vacuum.eve", "device_tracker.sevenplus", "device_tracker.tiias_iphone", "input_boolean.cleaning_doublepass", "input_boolean.schedule_cleaning"]
    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webSocketClient.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.connect),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.disconnect),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        // Do any additional setup after loading the view.
    }

    @objc func connect() {
        webSocketClient.connect()
    }
    
    @objc func disconnect() {
        webSocketClient.disconnect()
    }
    
    func sortData() {
        data[.lights] = entities.filter({ $0.domain == "light" })
        data[.mediaPlayers] = entities.filter({ $0.domain == "media_player" })
        data[.fans] = entities.filter({ $0.domain == "fan" })
        data[.groups] = entities.filter({ $0.domain == "group" })
        data[.inputBoolean] = entities.filter({ $0.domain == "input_boolean" })
        data[.deviceTracker] = entities.filter({ $0.domain == "device_tracker" })
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Websocket Delegate
    func authenticated() {
        data = [TableSection: [Entity]]()
        entities = [Entity]()
        webSocketClient.getStates()
        webSocketClient.subscribeToEvent(event: .stateChange)
    }
    
    func receivedResult(result: [[String:Any]]) {
        for jsonEntity in result {
            guard let id = jsonEntity["entity_id"] as? String else { continue }
            if !self.interestingEntities.contains(id) {
                continue
            }
            if let entity = Entity.init(JSONData: jsonEntity) {
                //self.entities[newEntity.id] = newEntity
                self.entities.append(entity)
            }
        }
        sortData()
    }
    
    func receivedEvent(event: [String:Any]) {
        
        if let data = event["data"] as? [String:AnyObject]{
            if let entity = data["new_state"] as? [String:AnyObject] {
                if let entityId = entity["entity_id"] as? String {
                    if self.interestingEntities.contains(entityId) {
                        if let indexToChange = self.entities.index(where: {$0.id == entityId}) {
                            self.entities[indexToChange].state = entity["state"] as? String
                            sortData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section), let entitiesData = data[tableSection] {
            return entitiesData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .lights:
                label.text = "Lights"
            case .mediaPlayers:
                label.text = "Media Players"
            case .fans:
                label.text = "Fans"
            case .groups:
                label.text = "Groups"
            case .inputBoolean:
                label.text = "Options"
            case .deviceTracker:
                label.text = "Presence"
            default:
                label.text = ""
            }
        }
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entityCell", for: indexPath)
        if let tableSection = TableSection(rawValue: indexPath.section), let entity = data[tableSection]?[indexPath.row] {
            cell.textLabel?.text = entity.friendlyName
            cell.detailTextLabel?.text = entity.state
            
            if tableSection == .deviceTracker {
                cell.isUserInteractionEnabled = false
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableSection = TableSection(rawValue: indexPath.section), let entity = data[tableSection]?[indexPath.row] {
            webSocketClient.toggle(entity: entity)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
