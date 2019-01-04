//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABSitemap.swift
//  HelloRestKit
//
//  Created by Victor Belov on 10/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

//
//  OpenHABSitemap.swift
//  HelloRestKit
//
//  Created by Victor Belov on 10/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//
//  This class parses and holds data for a sitemap list entry
//  REST: /sitemaps
//

import Foundation

class OpenHABSitemap: NSObject {
    var name = ""
    var icon = ""
    var label = ""
    var link = ""
    var leaf = ""
    var homepageLink = ""

    init(xml xmlElement: GDataXMLElement?) {
        super.init()
        for child: GDataXMLElement? in (xmlElement?.children())! {
            if child?.name() == "homepage" {
                for childChild: GDataXMLElement? in (child?.children())! {
                    if childChild?.name() == "link" {
                        homepageLink = "\(childChild ?? "")"
                    }
                    if childChild?.name() == "leaf" {
                        leaf = "\(childChild ?? "")"
                    }
                }
            } else if let name = child?.name() {
                if allPropertyNames().contains(name) {
                    setValue("\(child ?? "")", forKey: child?.name() ?? "")
                }
            }
        }
    }

    init(dictionaty dictionary: [AnyHashable : Any]?) {
        super.init()
        let keyArray = dictionary?.keys as? [Any]
        for key: String? in keyArray as? [String?] ?? [] {
            if (key == "homepage") {
                let homepageDictionary = dictionary?[key] as? [AnyHashable : Any]
                let homepageKeyArray = homepageDictionary?.keys as? [Any]
                for homepageKey: String? in homepageKeyArray as? [String?] ?? [] {
                    if (homepageKey == "link") {
                        homepageLink = homepageDictionary?[homepageKey] as? String ?? ""
                    }
                    if (homepageKey == "leaf") {
                        leaf = homepageDictionary?[homepageKey] as? String ?? ""
                    }
                }
            } else if allPropertyNames().contains(key ?? "") {
                setValue(dictionary?[key], forKey: key ?? "")
            }
        }
    }
}