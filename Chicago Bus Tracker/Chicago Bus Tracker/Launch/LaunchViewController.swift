//
//  LaunchViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/14/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

/// - LaunchViewController shows the splash screen
class LaunchViewController: UIViewController {
    
    // Mark Properties
    @IBOutlet weak var skipLabel: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var timerIsOn = false
    var timer: Timer?
    var timeRemaining = 5
    
    /// - skip method used for users to skip the splash screen to tab bar controller
    @IBAction func skip(_ sender: UIButton) {
        print("From Launch View Controller: skip the launch view")
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.goToTabView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        let launchCount = Defaults[.launchCount]
        if launchCount == 0 {
            Defaults[.initialLaunch] = Date().description(with: .current)
        }
        Defaults[.launchCount] += 1
    }
    
    /// - goToTabView method: Redirect the view to tab bar view
    func goToTabView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
        print("Jumping to the tab bar view controller")
    }
    
    /// - update method: update the remaining time to redirect
    @objc func update() {
        if self.timeRemaining == 0 {
            self.goToTabView()
            self.timer?.invalidate()
            self.timer = nil
        }else {
            self.skipLabel.setTitle("Skip in \(self.timeRemaining)s", for: UIControlState.normal)
            self.timeRemaining = self.timeRemaining - 1
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
