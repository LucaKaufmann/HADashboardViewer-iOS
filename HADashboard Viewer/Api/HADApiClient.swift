//
//  HADApiClient.swift
//  HADashboard Viewer
//
//  Created by Luca Kaufmann on 17/03/2018.
//  Copyright © 2018 Luca Kaufmann. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HADApiClient: NSObject {

    let baseUrl = Secrets.homeassistantUrl
    let headers: HTTPHeaders = [
        "x-ha-access": "\(Secrets.apiPassword)",
        "Content-Type": "application/json"
    ]
    
    func getState(completion: @escaping (Array<Dictionary<String,Any>>?) -> Void) {
        Alamofire.request("\(baseUrl)/api/states", headers:headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let jsonArray = response.result.value as? Array<Dictionary<String,Any>> {
                completion(jsonArray)
            } else {
                completion(nil)
            }
        }
    }
    
    func toggleEntity(name: String, domain: String, completion: @escaping () -> Void) {
        let homeassistantEntity = ["entity_id": domain+"."+name]
        Alamofire.request("\(baseUrl)/api/services/\(domain)/toggle", method: .post, parameters: homeassistantEntity, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            completion()
        })
    }
    
    func lightsOff(completion: @escaping () -> Void) {
        Alamofire.request("\(baseUrl)/api/services/light/turn_off", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            completion()
        })
    }
    
    func checkStateOf(name: String, domain: String, completion: @escaping (Bool) -> Void){
        
    }
    
}
