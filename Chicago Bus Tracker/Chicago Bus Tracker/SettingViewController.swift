//
//  SettingViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/12/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import Disk

/// - SettingViewController: handle user preferences set
class SettingViewController: UIViewController {

    @IBOutlet weak var userManual: UIButton!
    @IBOutlet weak var manualWord: UILabel!
    @IBOutlet weak var nightModeLabel: UILabel!
    @IBOutlet weak var nightModeWord: UILabel!
    @IBOutlet weak var wifiOnlyLabel: UILabel!
    @IBOutlet weak var wifiOnlyWord: UILabel!
    @IBOutlet weak var clearDataLabel: UIButton!
    @IBOutlet weak var clearDataWord: UILabel!
    @IBOutlet weak var aboutUsLabel: UIButton!
    @IBOutlet weak var aboutUsWord: UILabel!
    
    @IBOutlet weak var nightModeSwitch: UISwitch!
    
    @IBOutlet weak var wifiOnlySwitch: UISwitch!
    
    @IBAction func nightMode(_ sender: UISwitch) {
        print("Night Mode Switch is clicked")
        if nightModeSwitch.isOn {
            do {
                let night = NightMode(nightMode: true)
                try Disk.save(night, to: .caches, as: "Setting/night.json")
                print("Save file to cache: Setting/night.json")
                Setting.sharedInstance.updateNightMode(nightMode: true)
            }catch {
                print("From SettingViewController: unable to save Setting/night.json")
            }
        }else {
            do {
                let night = NightMode(nightMode: false)
                try Disk.save(night, to: .caches, as: "Setting/night.json")
                print("Save file to cache: Setting/night.json")
                Setting.sharedInstance.updateNightMode(nightMode: false)
            }catch {
                print("From SettingViewController: unable to save Setting/night.json")
            }
        }
    }
    
    @IBAction func wifiOnlyMode(_ sender: UISwitch) {
        // Save the wifiOnlyMode
        print("Wifi Only Switch is clicked")
        if wifiOnlySwitch.isOn {
            do {
                let wifi = WifiOnly(wifiOnly: true)
                try Disk.save(wifi, to: .caches, as: "Setting/wifi.json")
                print("Save file to cache: Setting/wifi.json")
                Setting.sharedInstance.updateWifiOnly(wifiOnly: true)
            }catch {
                print("From SettingViewController: unable to save Setting/wifi.json")
            }
        }else {
            do {
                let wifi = WifiOnly(wifiOnly: false)
                try Disk.save(wifi, to: .caches, as: "Setting/wifi.json")
                print("Save file to cache: Setting/wifi.json")
                Setting.sharedInstance.updateWifiOnly(wifiOnly: false)
            }catch {
                print("From SettingViewController: unable to save Setting/wifi.json")
            }
        }
    }
    
    /// - delete cache button
    @IBAction func deleteCache(_ sender: UIButton) {
        print("Delete Cache button is clicked")
        //Clear data
        // Create the alert controller
        let alertController = UIAlertController(title: "Caution: Clear Data", message: "The data will be deleted if clicked Delete.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.clearCache()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - clear cache function to delte cache
    func clearCache() {
        do {
            try Disk.clear(.caches)
        }catch {
            print("From SettingViewController: unable to delete cache")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initialSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// - initialize the setting view controller
    func initialSetting() {
        self.nightModeSwitch.isOn = Setting.sharedInstance.isNightMode()
        self.wifiOnlySwitch.isOn = Setting.sharedInstance.isWifiOnly()
        
        if self.nightModeSwitch.isOn {
            self.aboutUsLabel.backgroundColor = UIColor.black
            self.userManual.backgroundColor = UIColor.black
            self.nightModeLabel.backgroundColor = UIColor.black
            self.wifiOnlyLabel.backgroundColor = UIColor.black
            self.clearDataLabel.backgroundColor = UIColor.black
            self.aboutUsWord.textColor = UIColor.white
            self.manualWord.textColor = UIColor.white
            self.nightModeWord.textColor = UIColor.white
            self.wifiOnlyWord.textColor = UIColor.white
            self.clearDataWord.textColor = UIColor.white
        }else {
            self.aboutUsLabel.backgroundColor = UIColor.white
            self.userManual.backgroundColor = UIColor.white
            self.nightModeLabel.backgroundColor = UIColor.white
            self.wifiOnlyLabel.backgroundColor = UIColor.white
            self.clearDataLabel.backgroundColor = UIColor.white
            self.aboutUsWord.textColor = UIColor.black
            self.manualWord.textColor = UIColor.black
            self.nightModeWord.textColor = UIColor.black
            self.wifiOnlyWord.textColor = UIColor.black
            self.clearDataWord.textColor = UIColor.black
        }
    }

}
