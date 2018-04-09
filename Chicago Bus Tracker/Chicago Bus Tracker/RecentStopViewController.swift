//
//  RecentStopViewController.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/12/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import MapKit
import NotificationBannerSwift
import Foundation

class RecentStopViewController: UIViewController {

    @IBOutlet weak var routeNumber: UILabel!
    @IBOutlet weak var stopName: UILabel!
    @IBOutlet weak var arrivingTime: UILabel!
    @IBOutlet weak var arrivintTime2: UILabel!
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        self.update()
    }
    
    @IBAction func startCount(_ sender: UIButton) {
        print("Start counting")
        // Save the data into local disk
        
        // Start counting down
        // Query the api every mininute
        // Reminder the user when time is in 5 minutes
        
        
        
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        let button = self.view.viewWithTag(1) as! UIButton
        button.backgroundColor = UIColor.lightGray
        button.isEnabled = false
        
        self.update()
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        print("Cancel counting")
        if self.timer != nil {
            self.timer!.invalidate()
        }
        // Cancel counting down
        let button = self.view.viewWithTag(1) as! UIButton
        button.backgroundColor = UIColor.blue
        button.isEnabled = true
    }
    var currentStop: MapAnnotation?
    var routeStops: RouteStops?
    
    var annotations = [MapAnnotation]()
    var predictions = [Prediction]()
    var hasNotified = false
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.routeStops = detailItem as? RouteStops
            self.configureView()
            
        }
    }
    
    var timer: Timer?
    var remainingTime: Double?
    
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
        self.nextBus()
        addCurrentStop()
        showCurrentPoint()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func update() {
        // Update information
        self.nextBus()
        if self.remainingTime == nil {
            // Alert
        }else {
            if self.remainingTime! <= 5.0 && self.remainingTime! > 2.0 && self.hasNotified == false{
                // Notification
                let banner = NotificationBanner(title: "Bus is arriving in 5 minutes.", subtitle: "", style: .success)
                self.hasNotified = true
                banner.show()
            }else if self.remainingTime! <= 2.0 {
                // Notification and cancel the timer
                let banner = NotificationBanner(title: "Bus is arriving in 1 minutes.", subtitle: "", style: .success)
                banner.show()
                if self.timer != nil {
                    self.timer!.invalidate()
                }
                let button = self.view.viewWithTag(1) as! UIButton
                button.backgroundColor = UIColor.blue
                button.isEnabled = true
            }
        }
    }
    
    func configureView() {
        
    }
    
    func nextBus() {
        self.predictions = [Prediction]()
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
                //Handle the error
            }
            DispatchQueue.main.async {
                // Anything in here is execute on the main thread
                if self.predictions.count == 0 {
                    self.arrivingTime.text = "Sorry, no scheduled information now."
                    self.remainingTime = 10000.0
                }else {
                    //self.string2Date(string: self.predictions[0].prdtm)
                    let estimated = self.string2Date(string: self.predictions[0].prdtm)
                    let timeInterval = (estimated.timeIntervalSince(Date()) / 60).rounded(.up)
                    self.remainingTime = timeInterval
                    print(timeInterval)
                    self.arrivingTime.text = "Next bus: in \(timeInterval) minutes."
                    self.arrivintTime2.text = "Estimated Arriving Time: \(self.string2UTCDate(string: self.predictions[0].prdtm))"
                }
                
            }
        }
    }
    
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
    
    func addCurrentStop() {
        //let routeStops = self.detailItem as! RouteStops
        let stop = self.routeStops!.favoriteStop
        let coordinates = CLLocationCoordinate2DMake(stop.lat, stop.lon)
        self.currentStop = MapAnnotation(currentStop: true, title: "Route \(self.routeStops!.route.rt) \(self.routeStops!.route.rtnm)",
            subtitle: stop.stpnm, coordinate: coordinates)
        self.mapView.addAnnotation(self.currentStop!)
    }
    
    /// Zoom the screen automatically to enclose the two annotations
    func showAllPoints() {
        /*
         let coordinates = CLLocationCoordinate2DMake(self.stop!.lat,self.stop!.lon)
         let annotation = MapAnnotation(currentStop: false, title: self.stop!.stpnm, subtitle: "2nd Happiest Place on Earth", coordinate: coordinates)
         */
        mapView.showAnnotations(self.annotations, animated: true)
    }
    
    func showCurrentPoint() {
        mapView.showAnnotations([self.currentStop!], animated: true)
    }
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

///
/// MKMapView Delegate
///
extension RecentStopViewController: MKMapViewDelegate {
    
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
                
                /*
                 // Add an image to the callout
                 if annotation.title! == "Disney World" {
                 view.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "Mickey"))
                 } else {
                 view.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "UChicago"))
                 }
                 */
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
