//
//  SearchDetailTableViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/10/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

/// - SearchViewController: let user search the route
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "SearchStopCell"
    var routes = [Route]()
    var showRoutes = [Route]()
    var ctaResponse: CTAResponse?
    var nightMode = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Networking.sharedInstance.isConnectionAvailabel() == false {
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
        if segue.identifier == "addSearchStop" {
            
            // Get the index for the selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print("Jumping to RouteMapViewController from SearchViewController")
                // Retrieve the object from the data array
                let object = self.showRoutes[indexPath.row]
                
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
        return self.showRoutes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? StopTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AppleTableViewCell.")
        }
        
        let route = self.showRoutes[indexPath.row]
        cell.routeNumber.text = route.rt
        //Bug here, to be implemented 
        cell.stopName.text = route.rtnm
        cell.backgroundColor = UIColor(route.rtclr)
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
    
    /// - show alert
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

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
        if Networking.sharedInstance.isConnectionAvailabel() == true {
            searchHelper(searchText: searchBar.text!, clicked: true)
        }
        
        
    }
    
    /// Access the text of the search bar as it is being typed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 && Networking.sharedInstance.isConnectionAvailabel() == true{
            searchHelper(searchText: searchText, clicked: false)
        }
        
    }
    
    /// - SearchHelper
    func searchHelper(searchText: String, clicked: Bool) {
        self.showRoutes = [Route]()
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
                    for route in self.routes {
                        if clicked == false {
                            if (route.rt.uppercased().range(of: searchText.uppercased()) != nil) {
                                self.showRoutes.append(route)
                            }
                        }else {
                            if route.rt.uppercased() == searchText.uppercased() {
                                self.showRoutes.append(route)
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                }
                
            }
        }else {
            // Search the context
            self.showRoutes = [Route]()
            for route in self.routes {
                if clicked == false {
                    if (route.rt.uppercased().range(of: searchText.uppercased()) != nil) {
                        self.showRoutes.append(route)
                    }
                }else {
                    if route.rt.uppercased() == searchText.uppercased() {
                        self.showRoutes.append(route)
                    }
                }
                
            }
            self.tableView.reloadData()
        }
    }
}
