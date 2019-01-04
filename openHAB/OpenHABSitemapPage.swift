//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABSitemapPage.swift
//  HelloRestKit
//
//  Created by Victor Belov on 10/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

import Foundation

protocol OpenHABSitemapPageDelegate: NSObjectProtocol {
    func sendCommand(_ item: OpenHABItem?, commandToSend command: String?)
}

class OpenHABSitemapPage: NSObject, OpenHABWidgetDelegate {
    weak var delegate: OpenHABSitemapPageDelegate?
    var widgets: [AnyHashable] = []
    var pageId = ""
    var title = ""
    var link = ""
    var leaf = ""

    init(xml xmlElement: GDataXMLElement?) {
        super.init()
        widgets = [AnyHashable]()
        for child: GDataXMLElement? in (xmlElement?.children())! {
            if !(child?.name() == "widget") {
                if !(child?.name() == "id") {
                    if let name = child?.name() {
                        if allPropertyNames().contains(name) {
                            setValue("\(child ?? "")", forKey: child?.name() ?? "")
                        }
                    }
                } else {
                    pageId = "\(child ?? "")"
                }
            } else {
                let newWidget = OpenHABWidget(xml: child) as? OpenHABWidget
                if newWidget != nil {
                    newWidget?.delegate = self
                    if let newWidget = newWidget {
                        widgets.append(newWidget)
                    }
                }
                // If widget have child widgets, cycle through them too
                if Int(child?.elements(forName: "widget") ?? 0) > 0 {
                    for childChild: GDataXMLElement? in child?.elements(forName: "widget") ?? [] {
                        if child?.name() == "widget" {
                            let newChildWidget = OpenHABWidget(xml: childChild) as? OpenHABWidget
                            if newChildWidget != nil {
                                newChildWidget?.delegate = self
                                if let newChildWidget = newChildWidget {
                                    widgets.append(newChildWidget)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    init(dictionary: [AnyHashable : Any]) {
        super.init()
        widgets = [AnyHashable]()
        pageId = dictionary["id"] as? String ?? ""
        title = dictionary["title"] as? String ?? ""
        link = dictionary["link"] as? String ?? ""
        leaf = dictionary["leaf"] as? String ?? ""
        let widgetsArray = dictionary["widgets"] as? [Any]
        for widgetDictionary: [AnyHashable : Any]? in widgetsArray as? [[AnyHashable : Any]?] ?? [] {
            let newWidget: OpenHABWidget = widgetDictionary
            if newWidget != nil {
                newWidget.delegate = self
                widgets.append(newWidget)
            }
            if widgetDictionary?["widgets"] != nil {
                let childWidgetsArray = widgetDictionary?["widgets"] as? [Any]
                for childWidgetDictionary: [AnyHashable : Any]? in childWidgetsArray as? [[AnyHashable : Any]?] ?? [] {
                    let newChildWidget: OpenHABWidget = childWidgetDictionary
                    if newChildWidget != nil {
                        newChildWidget.delegate = self
                        widgets.append(newChildWidget)
                    }
                }
            }
        }
    }

    func sendCommand(_ item: OpenHABItem?, commandToSend command: String?) {
        if let name = item?.name {
            print("SitemapPage sending command \(command ?? "") to \(name)")
        }
        if delegate != nil {
            delegate?.sendCommand(item, commandToSend: command)
        }
    }
}