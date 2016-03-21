//
//  ViewController.swift
//  DispatchDash
//
//  Created by Kevin Zhu on 3/7/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GameViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    var myRoute : MKRoute?
    
    var gameTimer: NSTimer!
    var isPaused = true
    var passengerViews = [Passenger:PassengerView]()
    var carViews = [Car:MKAnnotationView]()
    var currentSelectedView: MKAnnotationView!
    var currentSelectedOverlays = [Passenger:MKRoute]()
    let mapCenter = CLLocationCoordinate2DMake(37.773692,-122.4297367)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.centerCoordinate = mapCenter
        myMap.delegate = self
        
        let car = Car(
            title: "test",
            coordinate: CLLocationCoordinate2DMake(37.7636844,-122.4216257))
        
        myMap.addAnnotation(car)
        
        addRandomPassenger()
        
        //Span of the map
        myMap.setRegion(MKCoordinateRegionMake(mapCenter, MKCoordinateSpanMake(0.1,0.1)), animated: true)
        
        
        onPauseResume(pauseResumeButton)
    }
    
    func onTick(timer: NSTimer) {
        
        for (p, pv) in passengerViews {
            p.onTick(timer)
            if p.isPaxLapsed || p.pickedUpBy != nil {
                myMap.removeAnnotation(p)
                if (p.pickedUpBy == nil) {
                    passengerViews.removeValueForKey(p)
                    myMap.removeOverlay(p.mapRoute.polyline)
                }
            } else {
                pv.setNeedsDisplay()
            }
        }
        
        for (car, carView) in carViews {
            car.onTick(timer)
//            carView.setNeedsDisplay()
        }
        
    }
    
    func addRandomPassenger() -> Passenger {
        let pickupLocation = CLLocationCoordinate2DMake(37.773692,-122.4297367)
        let dropoffLocation = CLLocationCoordinate2DMake(37.7585679,-122.4125813)
        
        let pax = Passenger(
            title: "pax",
            coordinate: pickupLocation,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocation)
    
        
        pax.directions.calculateDirectionsWithCompletionHandler {
            (response:MKDirectionsResponse?, error:NSError?) -> Void in
            if error == nil {
                pax.mapRoute = response!.routes[0]
                self.myMap.addOverlay(pax.mapRoute.polyline)
            }
        }
        
        myMap.addAnnotation(pax)
        passengerViews[pax] = nil
        
        return pax
    }
    
    
    @IBAction func onPauseResume(sender: UIButton) {
        if self.isPaused {
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onTick:", userInfo: nil, repeats: true)
            
            sender.setTitle("Pause", forState: .Normal)
            isPaused = false
        } else {
            gameTimer.invalidate()
            sender.setTitle("Resume", forState: .Normal)
            isPaused = true
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        myLineRenderer.strokeColor = UIColor.grayColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Car {
            let identifier = "car"
            var view: MKAnnotationView
            
//            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
//                as? MKAnnotationView { // 2
//                    dequeuedView.annotation = annotation
//                    view = dequeuedView
//            } else {
                // 3
            
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named: "car.png")
                view.frame.size.height = 30
                view.frame.size.width = 30
                view.contentMode = UIViewContentMode.ScaleAspectFit
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            
//            }
            print(identifier)
            carViews[annotation] = view
            return view
        } else if let annotation = annotation as? Passenger {
            let identifier = "passenger"
            
            let view = PassengerView(annotation: annotation, reuseIdentifier: identifier)
            
            view.frame.size.width = 30
            view.frame.size.height = 30
            view.backgroundColor = UIColor.clearColor()
            
            passengerViews[annotation] = view
            
//            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.image = UIImage(named: "car.png")
//            view.frame.size.height = 30
//            view.frame.size.width = 30
//            view.contentMode = UIViewContentMode.ScaleAspectFit
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView

            return view
            
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("did select annotation view")
        print(mapView.selectedAnnotations)
        
        if let car = view.annotation as? Car {
            return selectCar(car, viewForCar: view, mapView: mapView)
            
        } else if let passenger = view.annotation as? Passenger {
            if let passengerView = view as? PassengerView {
                return selectPassenger(passenger, viewForPassenger: passengerView, mapView: mapView)
            }
            
        }
    }
    func resetCarToPassengerOverlays() {
        for (_,route) in currentSelectedOverlays {
            self.myMap.removeOverlay(route.polyline)
        }
    }
    
    func selectCar(car: Car, viewForCar: MKAnnotationView, mapView: MKMapView) {
        if currentSelectedView == nil {
            currentSelectedView = viewForCar
            viewForCar.layer.borderColor = UIColor.blueColor().CGColor
            viewForCar.layer.borderWidth = 5
            
            // view routes to each passenger
            resetCarToPassengerOverlays()
            let carPlacemark = MKPlacemark(coordinate: car.coordinate, addressDictionary: nil)
            for (p, _) in passengerViews {
                let directionsRequest = MKDirectionsRequest()
                let pickup = MKPlacemark(coordinate: p.coordinate, addressDictionary: nil)
                
                directionsRequest.source = MKMapItem(placemark: carPlacemark)
                directionsRequest.destination = MKMapItem(placemark: pickup)
                directionsRequest.transportType = MKDirectionsTransportType.Automobile
                let directions = MKDirections(request: directionsRequest)
                
                directions.calculateDirectionsWithCompletionHandler {
                    (response:MKDirectionsResponse?, error:NSError?) -> Void in
                    if error == nil {
                        let route = response!.routes[0]
                        self.currentSelectedOverlays[p] = route
                        
                        self.myMap.addOverlay(route.polyline)
                    }
                }
            }
            
            
        } else {
            currentSelectedView = nil
            resetCarToPassengerOverlays()
            mapView.deselectAnnotation(car, animated: true)
            viewForCar.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    func selectPassenger(passenger: Passenger, viewForPassenger: PassengerView, mapView: MKMapView) {
        if let car = currentSelectedView.annotation as? Car {
            car.passengers.append(passenger)
            if let carToPassengerOverlay = currentSelectedOverlays[passenger] {
                car.addRouteToPassenger(passenger, route: carToPassengerOverlay)
            }
            resetCarToPassengerOverlays()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
