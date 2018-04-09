//
//  RouteMapViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/9/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import MapKit

class RouteMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var map: MKMapView!
    
    @IBAction func showSouthorEast(_ sender: UIButton) {
        self.direction = 1
        self.annotations = [MapAnnotation]()
        self.addAllStops()
        self.configureMap()
        self.tableView.reloadData()
        self.disableSE()
    }
    
    @IBAction func showNorthorWest(_ sender: UIButton) {
        self.direction = 0
        self.annotations = [MapAnnotation]()
        self.addAllStops()
        self.configureMap()
        self.tableView.reloadData()
        self.disableNW()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonView: UIView!
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var directions = [String]()
    var direction = 0
    let cellIdentifier = "StopMapCell"
    var currentStop: MapAnnotation?
    var annotations = [MapAnnotation]()
    var stops = [[Stop]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        map.showsCompass = true
        map.showsScale = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verify we are using the correct segue
        if segue.identifier == "addStop" {
            // Get the index for the selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print("Jumping to RouteMapStopViewController")
                // Retrieve the object from the data array
                let object = RouteStops(route: self.detailItem as! Route, dir: self.directions[self.direction], stops: self.stops[self.direction], favoriteStop: self.stops[direction][indexPath.row])
                
                // Navigate the hierarchy to find the detail view controller
                let controller = segue.destination as! RouteMapStopViewController
                
                // Set the detail view controller's detailItem property
                controller.detailItem = object as AnyObject?
            }else {
                print("Can not get indexPath")
            }
        }
    }
    
    /// - Configure the view
    func configureView() {
        print("Executing configureView")
        let route = detailItem as! Route
        self.startActivity()
        Networking.sharedInstance.getDirections(rt: route.rt) { (ctaResponse) in
            if let ctaResponse = ctaResponse {
                if let busTracker = ctaResponse.bustime_response {
                    if let directions = busTracker.directions {
                        for dir in directions {
                            print("Direction: \(dir.dir)")
                            self.directions.append(dir.dir)
                        }
                    }
                }
            }else {
                print("Can not get CTA information.")
            }
            if self.directions.count == 0 {
                print("There is no direction information.")
            }else {
                for i in 0..<self.directions.count {
                    Networking.sharedInstance.getStops(rt: route.rt, dir: self.directions[i]) { (ctaResponse) in
                        if let ctaResponse = ctaResponse {
                            if let busTracker = ctaResponse.bustime_response {
                                if let stops = busTracker.stops {
                                    for stop in stops {
                                        if self.stops.count <= i {
                                            var value = [Stop]()
                                            value.append(stop)
                                            self.stops.append(value)
                                        }else {
                                            self.stops[i].append(stop)
                                        }
                                    }
                                }
                            }
                        }else {
                            print("Can not get CTA information")
                        }
                        DispatchQueue.main.async {
                            // Anything in here is execute on the main thread
                            self.stopActivity()
                            self.addAllStops()
                            self.disableNW()
                            self.tableView.reloadData()
                            
                        }
                    }
                }
            }
        }
        
    }
    
    /// - add all stops information to map
    func addAllStops() {
        if self.stops.count > self.direction {
            let stops = self.stops[self.direction]
            let route = detailItem as! Route
            for stop in stops {
                let iscurrentStop = false
                
                let coordinates = CLLocationCoordinate2DMake(stop.lat, stop.lon)
                let annotation = MapAnnotation(currentStop: iscurrentStop, title: stop.stpnm,
                    subtitle: "Route \(route.rt) \(route.rtnm)", coordinate: coordinates)
                self.annotations.append(annotation)
                self.map.addAnnotation(annotation)
            }
        }else {
            print("Add stops failed")
        }
    }
    
    /// - show all stops on the map.
    func showAllPoints() {
        map.showAnnotations(self.annotations, animated: true)
    }
    
    /// - configure the map
    func configureMap() {
        let miles: Double = 50 * 50
        // Set a center point
        let zoomLocation = CLLocationCoordinate2DMake(41.7897, -87.5997)
        
        // Creat the region we want to see
        let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, miles, miles)
        
        // Set the initial region on the map
        map.setRegion(viewRegion, animated: true)
        // Do any additional setup after loading the view.
        
        print(self.stops.count)
        showAllPoints()
    }
    
    /// - disable left button
    func disableNW() {
        let northwest = self.buttonView.viewWithTag(1) as! UIButton
        let southeast = self.buttonView.viewWithTag(2) as! UIButton
        northwest.backgroundColor = UIColor.darkGray
        southeast.backgroundColor = UIColor.lightGray
        southeast.isEnabled = true
        northwest.isEnabled = false
        self.title = "Route \((self.detailItem as! Route).rt) \(self.directions[self.direction])"
    }
    
    /// - disable right button
    func disableSE() {
        let northwest = self.buttonView.viewWithTag(1) as! UIButton
        let southeast = self.buttonView.viewWithTag(2) as! UIButton
        southeast.backgroundColor = UIColor.darkGray
        northwest.backgroundColor = UIColor.lightGray
        southeast.isEnabled = false
        northwest.isEnabled = true
        self.title = "Route \((self.detailItem as! Route).rt) \(self.directions[self.direction])"
    }
    
    /// - show activityindicator
    func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// - hide activityindicator
    func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.stops.count == 0 || self.stops.count <= self.direction{
            return 0
        }else {
            if self.directions.count == 1 {
                let button1 = self.buttonView.viewWithTag(1) as! UIButton
                let button2 = self.buttonView.viewWithTag(2) as! UIButton
                button1.setTitle(self.directions[0], for: UIControlState.normal)
                button2.setTitle("None", for: UIControlState.normal)
                button1.isEnabled = false
                button2.isEnabled = false
                button1.backgroundColor = UIColor.darkGray
                button2.backgroundColor = UIColor.darkGray
            }else {
                let button1 = self.buttonView.viewWithTag(1) as! UIButton
                let button2 = self.buttonView.viewWithTag(2) as! UIButton
                button1.setTitle(self.directions[0], for: UIControlState.normal)
                button2.setTitle(self.directions[1], for: UIControlState.normal)
            }
            self.configureMap()
            return self.stops[self.direction].count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StopMapTableViewCell
        let stop = self.stops[self.direction][indexPath.row]
        let route = self.detailItem as! Route
        cell.routeNumber.text = route.rt
        cell.stopName.text = stop.stpnm
        if Setting.sharedInstance.isNightMode() {
            cell.backgroundColor = UIColor.black
            cell.stopName.textColor = UIColor.white
            cell.routeNumber.textColor = UIColor.white
        }else {
            cell.backgroundColor = UIColor.white
            cell.stopName.textColor = UIColor.black
            cell.routeNumber.textColor = UIColor.black
        }
        
        return cell
    }

}

///
/// MKMapView Delegate
///
extension RouteMapViewController: MKMapViewDelegate {
    
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
