//
//  Car.swift
//  DispatchDash
//
//  Created by Ariel Liu on 3/16/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit


class Passenger: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let pickupLocation: CLLocationCoordinate2D
    let dropoffLocation: CLLocationCoordinate2D
    let title: String?
    let waitMax = 60
    let directions: MKDirections
    var mapRoute: MKRoute!
    var waitTime = 0
    var pickedUpBy: Car?
    var isPaxLapsed: Bool {
        return waitTime >= waitMax
    }
    
    init(title: String,
        coordinate:CLLocationCoordinate2D,
        pickupLocation: CLLocationCoordinate2D,
        dropoffLocation: CLLocationCoordinate2D
        ) {
        self.coordinate = coordinate
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.title = title
        
        
        let directionsRequest = MKDirectionsRequest()
        let pickup = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude), addressDictionary: nil)
        
        let dropoff = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.dropoffLocation.latitude, self.dropoffLocation.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: pickup)
        directionsRequest.destination = MKMapItem(placemark: dropoff)
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        self.directions = MKDirections(request: directionsRequest)
    
        super.init()
    }
    
    
    func onTick(timer: NSTimer) {
        if waitTime < waitMax {
            waitTime++
        }
    }
}