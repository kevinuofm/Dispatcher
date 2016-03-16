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

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    
    var myRoute : MKRoute?
    
    var point1 : MKPointAnnotation!
    var point2 : MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        point1 = MKPointAnnotation()
        point2 = MKPointAnnotation()
        
        
        point1.coordinate = CLLocationCoordinate2DMake(37.773692,-122.4297367)
        point1.title = "Taipei"
        point1.subtitle = "Taiwan"
        myMap.addAnnotation(point1)
        
        point2.coordinate = CLLocationCoordinate2DMake(37.7585679,-122.4125813)
        point2.title = "Chungli"
        point2.subtitle = "Taiwan"
        myMap.addAnnotation(point2)
        myMap.centerCoordinate = point2.coordinate
        myMap.delegate = self
        
        let car = Car(
            title: "test",
            coordinate: CLLocationCoordinate2DMake(37.7636844,-122.4216257),
            passengers: [],
            waypoints: [])
        
        myMap.addAnnotation(car)
        
        //Span of the map
        myMap.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.1,0.1)), animated: true)
        
        let directionsRequest = MKDirectionsRequest()
        let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
        let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: markChungli)
        directionsRequest.destination = MKMapItem(placemark: markTaipei)
        
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) -> Void in
            if error == nil {
                self.myRoute = response!.routes[0]
                self.myMap.addOverlay((self.myRoute?.polyline)!)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(polyline: (myRoute?.polyline)!)
        myLineRenderer.strokeColor = UIColor.redColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Car {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
