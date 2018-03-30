//
//  EntityModel.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 17/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Entity {
    let id: String
    var state: String?
    let name: String
    let domain: String
    var button: UIButton?
    let friendlyName: String?
    
    init?(JSONData data:[String:Any]) {
        guard let id = data["entity_id"] as? String else { return nil }
        self.id = id
        self.state = data["state"] as? String
        let stringArray = id.components(separatedBy: ".")
        domain = stringArray[0]
        name = stringArray[1]
        if let attributes = data["attributes"] as? [String:Any] {
            friendlyName = attributes["friendly_name"] as? String
        } else {
            friendlyName = ""
        }
        
    }
    
    init?(JSON data:JSON) {
        guard let id = data["entity_id"].string else { return nil }
        self.id = id
        self.state = data["state"].string
        let stringArray = id.components(separatedBy: ".")
        domain = stringArray[0]
        name = stringArray[1]
        friendlyName = data["attributes"]["friendly_name"].string
    }
}
