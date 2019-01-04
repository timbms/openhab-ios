//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABNotification.swift
//  openHAB
//
//  Created by Victor Belov on 25/05/16.
//  Copyright © 2016 Victor Belov. All rights reserved.
//

import Foundation

class OpenHABNotification: NSObject {
    var message = ""
    var created: Date?
    var icon = ""
    var severity = ""

    init(dictionary: [AnyHashable : Any]) {
        super.init()
        let keyArray = dictionary.keys as? [Any]
        for key: String? in keyArray as? [String?] ?? [] {
            if (key == "created") {
                let dateFormatter = DateFormatter()
                // 2015-09-15T13:39:19.938Z
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S'Z'"
                created = dateFormatter.date(from: dictionary[key] as? String ?? "")
            } else if allPropertyNames().contains(key ?? "") {
                setValue(dictionary[key], forKey: key ?? "")
            }
        }
    }
}