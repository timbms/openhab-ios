//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABWidgetMapping.swift
//  openHAB
//
//  Created by Victor Belov on 17/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

import Foundation

class OpenHABWidgetMapping: NSObject {
    var command = ""
    var label = ""

    init(xml xmlElement: GDataXMLElement?) {
        super.init()
        for child: GDataXMLElement? in (xmlElement?.children())! {
            if let name = child?.name() {
                if allPropertyNames().contains(name) {
                    setValue("\(child ?? "")", forKey: child?.name() ?? "")
                }
            }
        }
    }

    init(dictionary: [AnyHashable : Any]) {
        super.init()
        for key: String? in dictionary.keys {
            if allPropertyNames().contains(key ?? "") {
                setValue(dictionary[key], forKey: key ?? "")
            }
        }
    }
}