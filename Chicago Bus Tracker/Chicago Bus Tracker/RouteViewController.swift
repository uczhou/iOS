//
//  SearchViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/9/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

/// - RouteViewController: show all routes under operation
class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "RouteCell"
    var nightMode = false
    var routes = [Route]()
    var ctaResponse: CTAResponse?
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Testing")
        tableView.delegate = self
        tableView.dataSource = self
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .blue
        refresher.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        initialRoute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Networking.sharedInstance.isConnectionAvailabel() == false {
            showAlert()
        }
    }
    
    /// - Refresh table
    @objc func refreshTable() {
        if Networking.sharedInstance.isConnectionAvailabel() == true {
            self.loadRouteData()
        }
        refresher.endRefreshing()
    }
    
    /// - Initial route information
    func initialRoute() {
        if Networking.sharedInstance.isConnectionAvailabel() {
            loadRouteData()
        }else {
            showAlert()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verify we are using the correct segue
        if segue.identifier == "showMap" {
            // Get the index for the selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print("Jumping to RouteMapViewController")
                // Retrieve the object from the data array
                let object = self.routes[indexPath.row]
                
                // Navigate the hierarchy to find the detail view controller
                let controller = segue.destination as! RouteMapViewController
                
                // Set the detail view controller's detailItem property
                controller.detailItem = object as AnyObject?
                
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routes.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? RouteTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AppleTableViewCell.")
        }
        
        let route = self.routes[indexPath.row]
        cell.routeNumber.text = route.rt
        cell.routeName.text = route.rtnm
        if nightMode {
            cell.backgroundColor = UIColor.black
            cell.routeNumber.textColor = UIColor.white
            cell.routeName.textColor = UIColor.white
            
        }else {
            cell.backgroundColor = UIColor(route.rtclr)
        }
        
        return cell
    }
    
    /// - show activityindicator
    func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// - hide activityindicator
    func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    /// - retrieve route data from CTA server
    func loadRouteData() {
        if self.routes.count == 0 {
            self.startActivity()
            Networking.sharedInstance.getRoutes() {(ctaResponse) in
                self.ctaResponse = ctaResponse
                if let ctaResponse = ctaResponse {
                    if let busTracker = ctaResponse.bustime_response {
                        if let routes = busTracker.routes {
                            for route in routes {
                                self.routes.append(route)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    // Anything in here is execute on the main thread
                    self.stopActivity()
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    /// - show alert when network is not available
    func showAlert() {
        var message = ""
        if Setting.sharedInstance.isWifiOnly() {
            message = "This app will only work with internet connection. Current is in Wifi Only mode. Please turn off the wifi only mode and retry."
        }else {
            message = "This app will only work with internet connection. Please make sure you have access to internet."
        }
        let alertController = UIAlertController(title: "Network not available", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
