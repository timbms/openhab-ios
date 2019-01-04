//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABDataObject.swift
//  openHAB
//
//  Created by Victor Belov on 14/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

import Foundation

class OpenHABDataObject: NSObject {
    var openHABRootUrl = ""
    var sitemaps: [AnyHashable] = []
    var openHABUsername = ""
    var openHABPassword = ""
    var rootViewController: OpenHABViewController?
    var openHABVersion: Int = 0
}