//
//  HADWebSocketViewController.swift
//  HADashboard Viewer
//
//  Created by Luca on 24/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import SwiftyJSON

class HADWebSocketViewController: UIViewController, HAEntityManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    enum TableSection: Int {
        case lights = 0, fans, inputBoolean, switches, total
    }
    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 25
    let entityManager = HADEntityManager.instance
    
    // Data variable to track our sorted data.
    var data = [TableSection: [Entity]]()

    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        entityManager.delegates.addDelegate(delegate: self)
        self.automaticallyAdjustsScrollViewInsets = false
        sortData()
        // Do any additional setup after loading the view.
    }
    
    func sortData() {
        
        let entities = Array(entityManager.entities.values)
        
        data[.lights] = entities.filter({ $0.domain == "light" })
        //data[.mediaPlayers] = entities.filter({ $0.domain == "media_player" })
        data[.fans] = entities.filter({ $0.domain == "fan" })
        //data[.groups] = entities.filter({ $0.domain == "group" })
        data[.inputBoolean] = entities.filter({ $0.domain == "input_boolean" })
        //data[.deviceTracker] = entities.filter({ $0.domain == "device_tracker" })
        data[.switches] = entities.filter({ $0.domain == "switch" })
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//            case .mediaPlayers:
//                label.text = "Media Players"
            case .fans:
                label.text = "Fans"
//            case .groups:
//                label.text = "Groups"
            case .inputBoolean:
                label.text = "Options"
//            case .deviceTracker:
//                label.text = "Presence"
            case .switches:
                label.text = "Switch"
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
            
            if entity.state == "on" {
                cell.backgroundColor = UIColor(rgb: 0xFFFFCC)
            } else {
                cell.backgroundColor = UIColor.clear
            }
//            if tableSection == .deviceTracker {
//                cell.isUserInteractionEnabled = false
//            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableSection = TableSection(rawValue: indexPath.section), let entity = data[tableSection]?[indexPath.row] {
            entityManager.toggleEntity(entityId: entity.id)
        }
    }
    
    func presenceChanged(shouldScreenBeOn: Bool) {
        // do nothing
    }
    
    func entityUpdated(entity: Entity) {
        sortData()
    }
    
    func refreshUI() {
        sortData()
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
