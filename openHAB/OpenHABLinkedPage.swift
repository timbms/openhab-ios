//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABLinkedPage.swift
//  HelloRestKit
//
//  Created by Victor Belov on 10/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

import Foundation

class OpenHABLinkedPage: NSObject {
    var pageId = ""
    var title = ""
    var icon = ""
    var link = ""

    init(xml xmlElement: GDataXMLElement?) {
        super.init()
        for child: GDataXMLElement? in (xmlElement?.children() as? [GDataXMLElement?])! {
            if !(child?.name() == "id") {
                if let name = child?.name() {
                    if allPropertyNames().contains(where: name) {
                        setValue("\(child ?? "")", forKey: child?.name() ?? "")
                    }
                }
            } else {
                pageId = "\(child ?? "")"
            }
        }
    }

    init(dictionary: [AnyHashable : Any]) {
        super.init()
        for key: String? in dictionary.keys {
            if !(key == "id") {
                if allPropertyNames().contains(key ?? "") {
                    setValue(dictionary[key], forKey: key ?? "")
                }
            } else {
                pageId = dictionary[key] as? String ?? ""
            }
        }
    }
}
