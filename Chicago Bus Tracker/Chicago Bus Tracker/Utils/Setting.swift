//
//  Setting.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/13/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import Disk

/// - Setting: custom class handling user preferences.
class Setting {
    
    static let sharedInstance = Setting()
    
    private var nightMode = false
    private var wifiOnly = false
    
    /// - Initialize the app when user launch the app.
    private init() {
        print("Initializing user settings.....")
        do {
            let nightMode = try Disk.retrieve("Setting/night.json", from: .caches, as: NightMode.self)
            self.nightMode = nightMode.nightMode
        }catch {
            self.nightMode  = false
            print("--------User launch the app for first time or user has cleared the cache-------------")
        }
        
        do {
            let wifiOnly = try Disk.retrieve("Setting/wifi.json", from: .caches, as: WifiOnly.self)
            self.wifiOnly = wifiOnly.wifiOnly
        }catch {
            //
            self.self.nightMode  = false
            print("--------User launch the app for first time or user has cleared the cache-------------")
        }
    }
    
    /// - update current user preference
    func updateNightMode(nightMode: Bool) {
        self.nightMode = nightMode
    }
    
    /// - update current user preference
    func updateWifiOnly(wifiOnly: Bool) {
        self.wifiOnly = wifiOnly
    }
    
    /// - get current user preference
    func isNightMode() -> Bool {
        return self.nightMode
    }
    
    /// - get current user preference
    func isWifiOnly() -> Bool {
        return self.wifiOnly
    }
    
    
}
