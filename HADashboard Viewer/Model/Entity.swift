//
//  EntityModel.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 17/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit

struct Entity {
    let id: String
    let state: String?
    let name: String
    let domain: String
    var button: UIButton?
    
    init?(JSONData data:[String:Any]) {
        guard let id = data["entity_id"] as? String else { return nil }
        self.id = id
        self.state = data["state"] as? String
        let stringArray = id.components(separatedBy: ".")
        domain = stringArray[0]
        name = stringArray[1]
    }
}
