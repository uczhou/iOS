//
//  RouteMapStopViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/11/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import MapKit
import Disk
import Foundation
import UserNotifications
import NotificationBannerSwift

/// - RouteMapStopViewController: Show detailed bus arriving time
class RouteMapStopViewController: UIViewController {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var routeNumber: UILabel!
    @IBOutlet weak var stopName: UILabel!
    @IBOutlet weak var arrivingTime: UILabel!
    @IBOutlet weak var arrivingTime2: UILabel!
    @IBOutlet weak var viewRef: UIView!
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        print("From RouteMapStopViewController: refresh button clicked")
        self.nextBus()
    }
    
    @IBAction func startCount(_ sender: UIButton) {
        print("From RouteMapStopViewController: select button clicked")
        // Save the data into local disk
        let button = self.view.viewWithTag(1) as! UIButton
        button.backgroundColor = UIColor.lightGray
        button.isEnabled = false
        self.update()
        
        do {
            try Disk.save(self.routeStops!, to: .caches, as: "RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid).json")
            print("Save flie to cache: RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid).json")
        }catch {
            //Delete the data if failed.
            print("From RouteMapStopViewController: unable to save the information to cache")
        }
        
        do {
            // Save route number stop name
            try Disk.save(self.routeStops!, to: .caches, as: "Recent/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid).json")
            print("Save file to cache: Recent/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid).json")
            let fileMetaData = FileMetaData(filename: "route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid).json")
            try Disk.append(fileMetaData, to: "FileMeta/recentroutestop.json", in:. caches)
            print("Append data to file in cache: FileMeta/recentroutestop.json")
            
        }catch {
            print("From RouteMapStopViewController: unable to save the information to cache")
        }
        
        // Save route number stop name and arriving time in cache.
        do {
            let routePrediction = RoutePrediction(rtstp: self.routeStops!, timestamp: self.bustime!)
            try Disk.save(routePrediction, to: .caches, as: "RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
            print("Save file to cache: RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
        }catch {
            print("Save file to cache failed: RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    
        if self.remainingTime! > 5.0 {
            self.showNotification(time: 5, interval: (self.remainingTime! - 5) * 60, routeNumber: self.routeStops!.route.rt)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        print("From RouteMapStopViewController: cancel button clicked")
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        // Cancel counting down
        let button = self.view.viewWithTag(1) as! UIButton
        button.backgroundColor = UIColor.blue
        button.isEnabled = true
        self.hasNotified = false
        
        // Save route number stop name in route in formation.
        do {
            let routePrediction = RoutePrediction(rtstp: self.routeStops!, timestamp: "NA")
            try Disk.save(routePrediction, to: .caches, as: "RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
            print("Save file to cache: RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
        }catch {
            print("Save file to cache failed: RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json")
        }
        
    }
    
    var currentStop: MapAnnotation?
    var routeStops: RouteStops?
    
    var annotations = [MapAnnotation]()
    var predictions = [Prediction]()
    var hasNotified = false
    var timer: Timer?
    var remainingTime: Double?
    var bustime: String?
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.routeStops = detailItem as? RouteStops
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet { mapView.delegate = self }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.routeNumber.text = self.routeStops!.route.rt
        self.stopName.text = self.routeStops!.favoriteStop.stpnm
        
        let miles: Double = 80 * 80
        // Set a center point
        let zoomLocation = CLLocationCoordinate2DMake(self.routeStops!.favoriteStop.lat,self.routeStops!.favoriteStop.lon)
        
        // Creat the region we want to see
        let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, miles, miles)
        
        // Set the initial region on the map
        mapView.setRegion(viewRegion, animated: true)
        // Do any additional setup after loading the view.
        
        mapView.showsCompass = true
        mapView.showsScale = true
        
        let options: UNAuthorizationOptions = [.alert, .sound];
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("User diabled notification")
            }
        }
        self.nextBus()
        addCurrentStop()
        showCurrentPoint()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Setting.sharedInstance.isNightMode() {
            self.setNightMode()
        }else {
            self.setDayMode()
        }
        
        // Read route prediction information from cache
        do {
            let retrievedData = try Disk.retrieve("RouteStops/route\(self.routeStops!.route.rt)stop\(self.routeStops!.favoriteStop.stpid)visited.json", from: .caches, as: RoutePrediction.self)
            print("Retrieving data from cache: FileMeta/recentroutestop.json")
            // Compare with current time
            if retrievedData.timestamp != "NA" {
                let timestamp = self.string2Date(string: retrievedData.timestamp)
                if timestamp.timeIntervalSince(Date()) >= 0 {
                    // Update
                    // Cancel counting down
                    let button = self.view.viewWithTag(1) as! UIButton
                    button.backgroundColor = UIColor.lightGray
                    button.isEnabled = false
                }
            }
        }catch {
            print("-------User has not added stops or user has already deleted the cache---------")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// - show notification
    func showNotification(time: Double, interval: Double, routeNumber: String) {
        let content = UNMutableNotificationContent()
        content.title = "Next bus in \(time) minutes!"
        content.body = "Route \(routeNumber) is arriving in \(time) minutes."
        content.sound = UNNotificationSound.default()
       
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval,
                                                        repeats: false)
        
        // Add a notification
        let identifier = "Time Notification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                // Something went wrong
                print("---------Error---------")
            }
        })
        print("----------show notifications----------")
        listNotification()
    }
    
    /// - list notifications in notification center
    func listNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            print(requests)
        }
    }
    
    /// - set night mode based on user preference
    func setNightMode() {
        self.routeLabel.textColor = UIColor.white
        self.stopLabel.textColor = UIColor.white
        self.routeNumber.textColor = UIColor.white
        self.stopName.textColor = UIColor.white
        self.arrivingTime2.textColor = UIColor.white
        self.arrivingTime.textColor = UIColor.green
        self.viewRef.backgroundColor = UIColor.black
    }
    
    /// - set day mode based on user preference
    func setDayMode() {
        self.routeLabel.textColor = UIColor.black
        self.stopLabel.textColor = UIColor.black
        self.routeNumber.textColor = UIColor.black
        self.stopName.textColor = UIColor.black
        self.arrivingTime2.textColor = UIColor.black
        self.arrivingTime.textColor = UIColor.red
        self.viewRef.backgroundColor = UIColor.white
    }
    
    /// - update bus arriving time
    @objc func update() {
        // Update information
        self.nextBus()
        if self.remainingTime == nil {
            print("---------Bus is not in schedule---------")
        }else {
            if self.remainingTime! <= 5.0 && self.remainingTime! > 2.0 && self.hasNotified == false{
                // Notification
                let banner = NotificationBanner(title: "Next bus in \(self.remainingTime!) minutes!", subtitle: "Route \(self.routeStops!.route.rt) is arriving in \(self.remainingTime!) minutes.", style: .info)
                banner.show()
                self.hasNotified = true
                self.showNotification(time: 5, interval: 5, routeNumber: self.routeStops!.route.rt)
            }else if self.remainingTime! <= 2.0 {
                // Notification and cancel the timer
                let banner = NotificationBanner(title: "Next bus in \(self.remainingTime!) minutes!", subtitle: "Route \(self.routeStops!.route.rt) is arriving in \(self.remainingTime!) minutes.", style: .info)
                banner.show()
                self.showNotification(time: 2, interval: 5, routeNumber: self.routeStops!.route.rt)
                if self.timer != nil {
                    self.timer!.invalidate()
                    self.timer = nil
                }
                let button = self.view.viewWithTag(1) as! UIButton
                button.backgroundColor = UIColor.blue
                button.isEnabled = true
            }
        }
    }

    func nextBus() {
        self.predictions = [Prediction]()
        self.startActivity()
        Networking.sharedInstance.getPredictionsByStpidRt(rt: self.routeStops!.route.rt, stpid: self.routeStops!.favoriteStop.stpid) { (ctaResponse) in
            if let ctaResponse = ctaResponse {
                if let busTracker = ctaResponse.bustime_response {
                    if let predictions = busTracker.prd {
                        for prediction in predictions {
                            self.predictions.append(prediction)
                        }
                    }
                }
            }else {
                print("Unable to get CTA information")
            }
           
            DispatchQueue.main.async {
                // Anything in here is execute on the main thread
                self.stopActivity()
                if self.predictions.count == 0 {
                    self.arrivingTime.text = "Sorry, no scheduled information now."
                    self.remainingTime = 10000.0
                    self.bustime = "NA"
                }else {
                    //self.string2Date(string: self.predictions[0].prdtm)
                    let estimated = self.string2Date(string: self.predictions[0].prdtm)
                    self.bustime = self.predictions[0].prdtm
                    let timeInterval = (estimated.timeIntervalSince(Date()) / 60).rounded(.up)
                    self.remainingTime = timeInterval
                    print("Next bus: in \(timeInterval)")
                    self.arrivingTime.text = "Next bus: in \(timeInterval) minutes."
                    self.arrivingTime2.text = "Time: \(self.string2UTCDate(string: self.predictions[0].prdtm))"
                }
                
            }
        }
    }
    
    /// - add stops information to map
    func addAllStops() {
        //let routeStops = self.detailItem as! RouteStops
        print(self.routeStops!.stops.count)
        for stop in self.routeStops!.stops {
            var iscurrentStop = false
            if stop.stpid == self.routeStops!.favoriteStop.stpid {
                iscurrentStop = true
            }
            let coordinates = CLLocationCoordinate2DMake(stop.lat, stop.lon)
            let annotation = MapAnnotation(currentStop: iscurrentStop, title: "Route \(self.routeStops!.route.rt) \(self.routeStops!.route.rtnm)",
                subtitle: "Stop: \(stop.stpnm)", coordinate: coordinates)
            self.annotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    /// - add current stop information to cache
    func addCurrentStop() {
        //let routeStops = self.detailItem as! RouteStops
        let stop = self.routeStops!.favoriteStop
        let coordinates = CLLocationCoordinate2DMake(stop.lat, stop.lon)
        self.currentStop = MapAnnotation(currentStop: true, title: "Route \(self.routeStops!.route.rt) \(self.routeStops!.route.rtnm)",
            subtitle: stop.stpnm, coordinate: coordinates)
        self.mapView.addAnnotation(self.currentStop!)
    }

    /// - show stops on map
    func showAllPoints() {
        
        mapView.showAnnotations(self.annotations, animated: true)
    }
    
    /// - show current stop on map
    func showCurrentPoint() {
        mapView.showAnnotations([self.currentStop!], animated: true)
    }
    
    /// - show activityindicator
    func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// - hide activityindicator
    func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    /// - convert string to date
    func string2Date(string: String) ->Date {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyyMMdd HH:mm"
        //dateFmt.timeZone = TimeZone(identifier: "UTC")
        let date = dateFmt.date(from: string)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let finalDate = calendar.date(from:components)!
        
        print(finalDate)
        return finalDate
    }
    
    /// - convert string to string
    func string2UTCDate(string: String) -> String{
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyyMMdd HH:mm"
        let date = dateFmt.date(from: string)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let finalDate = calendar.date(from:components)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        //dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: finalDate)
    }

}

///
/// MKMapView Delegate
///
extension RouteMapStopViewController: MKMapViewDelegate {
    
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
                view.markerTintColor = UIColor.blue
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
