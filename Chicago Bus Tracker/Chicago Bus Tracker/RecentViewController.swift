//
//  RecentTableViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/10/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import Disk
import MapKit
import SwiftyUserDefaults

/// - RecentViewController: show recent viewed stops
class RecentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var map: MKMapView!
    
    var annotations = [MapAnnotation]()
    var routeStops = [RouteStops]()
    let cellIdentifier = "RecentCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recent Views"
        self.tableView.reloadData()
        
        // Show rating alert every 5 times of launching the app
        if Defaults[.launchCount] % 5 == 0 {
            self.showRatingAlert()
        }
        
        // Print initial launch time
        if Defaults[.initialLaunch] != nil {
            print("-------Fisrt launch time: \(Defaults[.initialLaunch]!)----------")
        }
        
        map.showsCompass = true
        map.showsScale = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var filenames = Set<String>()
        self.routeStops = [RouteStops]()
        self.annotations = [MapAnnotation]()
        do {
            let retrievedData = try Disk.retrieve("FileMeta/recentroutestop.json", from: .caches, as: [FileMetaData].self)
            print("Retrieving data from cache: FileMeta/recentroutestop.json")
            for fileMetaData in retrievedData {
                filenames.insert(fileMetaData.filename)
            }
        }catch {
            print("-------User has not added stops or user has already deleted the cache---------")
        }
        
        do {
            for element in filenames {
                print("From RecentViewController: recent stops \(element)")
                let retrievedData = try Disk.retrieve("Recent/\(element)", from: .caches, as: RouteStops.self)
                print("Retrieving data from cache: Recent/\(element)")
                self.routeStops.append(retrievedData)
            }
        }catch {
            print("-------User has not added stops or user has already deleted the cache---------")
        }
        
        self.addAllStops()
        self.configureMap()
        
        self.tableView.reloadData()
    }
    
    /// - remove defaults values
    func clearCache() {
        Defaults.removeAll()
    }
    
    /// - show rating alert
    func showRatingAlert() {
        let message = "Please share your opinion about our app with us, thank you."
        
        let alertController = UIAlertController(title: "Rating our app", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Show Rating Alert: User pressed OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verify we are using the correct segue
        if segue.identifier == "addRecentStop" {
            // Get the index for the selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print("Jumping to RouteMapStopViewController")
                // Retrieve the object from the data array
                //let object = self.stops[direction][indexPath.row]
                
                let object = self.routeStops[indexPath.row]
                
                // Navigate the hierarchy to find the detail view controller
                let controller = segue.destination as! RouteMapStopViewController
                
                // Set the detail view controller's detailItem property
                controller.detailItem = object as AnyObject?
        
            }else {
                print("Can not get indexPath")
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
        return self.routeStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! RecentTableViewCell

        let rs = self.routeStops[indexPath.row]
        cell.routeNumber.text = rs.route.rt
        cell.stopName.text = rs.favoriteStop.stpnm
        cell.backgroundColor = UIColor(rs.route.rtclr)
        return cell
        
    }
    
    /// - add stops information to map
    func addAllStops() {
        for stop in self.routeStops {
            let iscurrentStop = false
            let coordinates = CLLocationCoordinate2DMake(stop.favoriteStop.lat, stop.favoriteStop.lon)
            let annotation = MapAnnotation(currentStop: iscurrentStop, title: stop.favoriteStop.stpnm,
                                           subtitle: "Route \(stop.route.rt) \(stop.route.rtnm)", coordinate: coordinates)
            self.annotations.append(annotation)
            self.map.addAnnotation(annotation)
        }
    }
    
    /// - show stop information on map
    func showAllPoints() {
        map.showAnnotations(self.annotations, animated: true)
    }
    
    /// - configure map
    func configureMap() {
        let miles: Double = 50 * 50
        // Set a center point
        let zoomLocation = CLLocationCoordinate2DMake(41.7897, -87.5997)
        
        // Creat the region we want to see
        let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, miles, miles)
        
        // Set the initial region on the map
        map.setRegion(viewRegion, animated: true)
        // Do any additional setup after loading the view.
        
        showAllPoints()
    }
    
}

extension RecentViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Tapped a callout")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapAnnotation {
            let identifier = "CustomPin"
            
            // Create a new view
            var view: MKMarkerAnnotationView
            
            // Deque an annotation view or create a new one
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view.markerTintColor = UIColor.clear
                view.glyphText = "📍"
                
            }
            return view
        }
        return nil
    }
    
    // Draw the routing overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

