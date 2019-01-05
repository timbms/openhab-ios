//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  OpenHABDrawerTableViewController.swift
//  openHAB
//
//  Created by Victor Belov on 23/05/16.
//  Copyright © 2016 Victor Belov. All rights reserved.
//

import SDWebImage
import UIKit

class OpenHABDrawerTableViewController: UITableViewController {
    var sitemaps: NSMutableArray = []
    @objc var openHABRootUrl = ""
    var openHABUsername = ""
    var openHABPassword = ""
    var ignoreSSLCertificate = false
    var cellCount: Int = 0
    var drawerItems: [AnyHashable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        drawerItems = [AnyHashable]()
        sitemaps = []
        loadSettings()
        print("OpenHABDrawerTableViewController did load")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("OpenHABDrawerTableViewController viewWillAppear")
        let sitemapsUrlString = "\(openHABRootUrl)/rest/sitemaps"
        print("Sitemap URL = \(sitemapsUrlString)")
        let sitemapsUrl = URL(string: sitemapsUrlString)
        var sitemapsRequest: NSMutableURLRequest? = nil
        if let sitemapsUrl = sitemapsUrl {
            sitemapsRequest = NSMutableURLRequest(url: sitemapsUrl)
        }
        sitemapsRequest?.setAuthCredentials(openHABUsername, openHABPassword)
        var operation: AFHTTPRequestOperation? = nil
        if let sitemapsRequest = sitemapsRequest {
            operation = AFHTTPRequestOperation(request: sitemapsRequest as URLRequest)
        }
        let policy = AFRememberingSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        operation?.securityPolicy = policy
        if ignoreSSLCertificate {
            print("Warning - ignoring invalid certificates")
            operation?.securityPolicy.allowInvalidCertificates = true
        }
        if appData()?.openHABVersion == 2 {
            print("Setting setializer to JSON")
            operation?.responseSerializer = AFJSONResponseSerializer()
        }
        operation?.setCompletionBlockWithSuccess({ operation, responseObject in
            let response = responseObject as? Data
            var error: Error?
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.sitemaps = []
            print("Sitemap response")
            // If we are talking to openHAB 1.X, talk XML
            if self.appData()?.openHABVersion == 1 {
                print("openHAB 1")
                if let response = response {
                    print("\(String(data: response, encoding: .utf8) ?? "")")
                }
                var doc: GDataXMLDocument? = nil
                if let response = response {
                    doc = try? GDataXMLDocument(data: response)
                }
                if doc == nil {
                    return
                }
                if let name = doc?.rootElement().name() {
                    print("\(name)")
                }
                if doc?.rootElement().name() == "sitemaps" {
                    for element in doc?.rootElement().elements(forName: "sitemap") ?? [] {
                        if let element = element as? GDataXMLElement {
                            let sitemap = OpenHABSitemap(xml: element)
                            self.sitemaps.add(sitemap)
                        }
                    }
                } else {
                    return
                }
                // Newer versions speak JSON!
            } else {
                print("openHAB 2")
                if (responseObject is [Any]) {
                    print("Response is array")
                    for sitemapJson: Any? in responseObject as! [Any?] {
                        let sitemap = OpenHABSitemap(dictionaty: sitemapJson as? [AnyHashable : Any])
                        if (responseObject as AnyObject).count != 1 && !(sitemap?.name == "_default") {
                            print("Sitemap \(sitemap?.label)")
                            self.sitemaps.add(sitemap)
                        }
                    }
                } else {
                    // Something went wrong, we should have received an array
                    return
                }
            }

            // Sort the sitemaps alphabetically.
            self.sitemaps.sort(comparator: { obj1, obj2 in
                let a = (obj1 as? OpenHABSitemap)?.name
                let b = (obj2 as? OpenHABSitemap)?.name
                return (a?.compare(b ?? ""))!
            })
//            let sorted = (self.sitemaps as NSArray).sortedArray(comparator: { obj1, obj2 in
//                    let a = (obj1 as? OpenHABSitemap)?.name
//                    let b = (obj2 as? OpenHABSitemap)?.name
//                    return (a?.compare(b ?? ""))!
//                })
//
//            if let sorted = sorted as? [AnyHashable] {
//                self.sitemaps = sorted
//            }

            self.appData()?.sitemaps = self.sitemaps
            self.tableView.reloadData()
        }, failure: { operation, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("Error:------>\(error.localizedDescription)")
            print(String(format: "error code %ld", Int(operation.response?.statusCode ?? 0)))
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        operation?.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawerItems.removeAll()
        // check if we are using my.openHAB, add notifications menu item then
        let prefs = UserDefaults.standard
        if Int((prefs.value(forKey: "remoteUrl") as? NSString)?.range(of: "openhab.org").location ?? 0) != NSNotFound {
            let notificationsItem = OpenHABDrawerItem()
            notificationsItem.label = "Notifications"
            notificationsItem.tag = "notifications"
            notificationsItem.icon = "glyphicons-334-bell.png"
            drawerItems.append(notificationsItem)
        }
        // Settings always go last
        let settingsItem = OpenHABDrawerItem()
        settingsItem.label = "Settings"
        settingsItem.tag = "settings"
        settingsItem.icon = "glyphicons-137-cogwheel.png"
        drawerItems.append(settingsItem)
        //    self.sitemaps = [[self appData] sitemaps];
        tableView.reloadData()
        print("RightDrawerViewController viewDidAppear")
        print(String(format: "Sitemaps count: %lu", UInt(sitemaps.count)))
        print(String(format: "Menu items count: %lu", UInt(drawerItems.count)))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated) // Call the super class implementation.
        print("RightDrawerViewController viewDidDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Empty first (index 0) row + sitemaps + menu items
        return 1 + sitemaps.count + drawerItems.count
    }

    static let tableViewCellIdentifier = "DrawerCell"

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DrawerUITableViewCell?
        if indexPath.row != 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: OpenHABDrawerTableViewController.tableViewCellIdentifier) as! DrawerUITableViewCell
            //        if (cell == nil) {
            //            cell = [[DrawerUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            //        }
            // First sitemaps
            if indexPath.row <= sitemaps.count && sitemaps.count > 0 {
                cell?.customTextLabel?.text = (sitemaps[indexPath.row - 1] as? OpenHABSitemap)?.label
                var iconUrlString: String? = nil
                if appData()?.openHABVersion == 2 {
                    if let app = appData()?.openHABRootUrl, let object = (sitemaps[indexPath.row - 1] as? OpenHABSitemap)?.icon {
                        iconUrlString = "\(app)/icon/\(object).png"
                    }
                } else {
                    if let app = appData()?.openHABRootUrl, let object = (sitemaps[indexPath.row - 1] as? OpenHABSitemap)?.icon {
                        iconUrlString = "\(app)/images/\(object).png"
                    }
                }
                print("\(iconUrlString ?? "")")
                cell?.customImageView?.sd_setImage(with: URL(string: iconUrlString ?? ""), placeholderImage: UIImage(named: "icon-76x76.png"), options: [])
            } else {
                // Then menu items
                cell?.customTextLabel?.text = (drawerItems[indexPath.row - sitemaps.count - 1] as? OpenHABDrawerItem)?.label
                var iconUrlString: String? = nil
                cell?.customImageView?.sd_setImage(with: URL(string: iconUrlString ?? ""), placeholderImage: UIImage(named: (drawerItems[indexPath.row - sitemaps.count - 1] as? OpenHABDrawerItem)?.icon ?? ""), options: [])
            }
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: OpenHABDrawerTableViewController.tableViewCellIdentifier) as! DrawerUITableViewCell
//            if cell == nil {
//                cell = DrawerUITableViewCell(style: .default, reuseIdentifier: OpenHABDrawerTableViewController.tableViewCellIdentifier)
//            }
        }
        if cell?.responds(to: #selector(setter: DrawerUITableViewCell.preservesSuperviewLayoutMargins)) ?? false {
            cell?.preservesSuperviewLayoutMargins = false
        }

        // Explictly set your cell's layout margins
        if cell?.responds(to: #selector(setter: DrawerUITableViewCell.layoutMargins)) ?? false {
            cell?.layoutMargins = .zero
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 64
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // open a alert with an OK and cancel button
        print(String(format: "Clicked on drawer row #%ld", indexPath.row))
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row != 0 {
            // First sitemaps
            if indexPath.row <= sitemaps.count && sitemaps.count > 0 {
                let sitemap = sitemaps[indexPath.row - 1] as? OpenHABSitemap
                var prefs = UserDefaults.standard
                prefs.setValue(sitemap?.name, forKey: "defaultSitemap")
                appData()?.rootViewController?.pageUrl = nil
                let nav = mm_drawerController.centerViewController as? UINavigationController
                let dummyViewController: UIViewController? = storyboard?.instantiateViewController(withIdentifier: "DummyViewController")
                if let dummyViewController = dummyViewController {
                    nav?.pushViewController(dummyViewController, animated: false)
                }
                nav?.popToRootViewController(animated: true)
            } else {
                // Then menu items
                if (((drawerItems[indexPath.row - sitemaps.count - 1] as? OpenHABDrawerItem)?.tag) == "settings") {
                    let nav = mm_drawerController.centerViewController as? UINavigationController
                    let newViewController = storyboard?.instantiateViewController(withIdentifier: "OpenHABSettingsViewController") as? OpenHABSettingsViewController
                    if let newViewController = newViewController {
                        nav?.pushViewController(newViewController, animated: true)
                    }
                }
                if (((drawerItems[indexPath.row - sitemaps.count - 1] as? OpenHABDrawerItem)?.tag) == "notifications") {
                    let nav = mm_drawerController.centerViewController as? UINavigationController
                    if (nav?.visibleViewController is OpenHABNotificationsViewControllerTableViewController) {
                        print("Notifications are already open")
                    } else {
                        let newViewController = storyboard?.instantiateViewController(withIdentifier: "OpenHABNotificationsViewController") as? OpenHABNotificationsViewControllerTableViewController
                        if let newViewController = newViewController {
                            nav?.pushViewController(newViewController, animated: true)
                        }
                    }
                }
            }
        }
        mm_drawerController.closeDrawer(animated: true, completion: nil)
    }

    /*
    #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    func loadSettings() {
        let prefs = UserDefaults.standard
        openHABUsername = prefs.value(forKey: "username") as? String ?? ""
        openHABPassword = prefs.value(forKey: "password") as? String ?? ""
        ignoreSSLCertificate = prefs.bool(forKey: "ignoreSSL")
    }

    // App wide data access
    func appData() -> OpenHABDataObject? {
        let theDelegate = UIApplication.shared.delegate as? OpenHABAppDataDelegate?
        return theDelegate??.appData()
    }
}

//#import "OpenHABSettingsViewController.h"