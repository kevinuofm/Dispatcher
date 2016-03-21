//
//  Car.swift
//  DispatchDash
//
//  Created by Ariel Liu on 3/16/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit

enum RouteEventType {
    case Pickup
    case Dropoff
}

class Car: MKPointAnnotation {
    var passengers: [Passenger] = []
    var journeyLegs: [[CLLocationCoordinate2D]] = [[]]
    var counter = 0
    
    init(title: String, coordinate:CLLocationCoordinate2D) {
        super.init()
        
        self.coordinate = coordinate
        self.title = title
    }
    
    func getCoordWaypoints(route:MKRoute) -> [CLLocationCoordinate2D] {
        
        let waypointCount = route.polyline.pointCount
        let range = NSMakeRange(0, waypointCount)
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(waypointCount)
        
        route.polyline.getCoordinates(coordsPointer, range: range)
        
        var coordWaypoints: [CLLocationCoordinate2D] = []
        for i in 0..<waypointCount {
            coordWaypoints.append(coordsPointer[i])
        }
        
        return coordWaypoints
    }
    
    func addRouteToPassenger(passenger: Passenger, route: MKRoute) {
        passengers.append(passenger)
        
        let waypointsToPickup = getCoordWaypoints(route)
        journeyLegs.append(waypointsToPickup)
        
        let waypointsToDropoff = getCoordWaypoints(passenger.mapRoute)
        journeyLegs.append(waypointsToDropoff)
        
    }
    
    func onTick(timer: NSTimer) {
        var allLegs: [CLLocationCoordinate2D] = []
        for leg in journeyLegs {
            allLegs += leg
        }
        
        if (counter < allLegs.count) {
            let coordinate = allLegs[counter]
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.coordinate = coordinate
            })
            print (self.coordinate)
            counter++
            
            for p in passengers {
                let carLocation = CLLocation.init(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
                let paxPickup = CLLocation.init(latitude: p.pickupLocation.latitude, longitude: p.pickupLocation.longitude)
                let paxDropoff = CLLocation.init(latitude: p.dropoffLocation.latitude, longitude: p.dropoffLocation.longitude)
                let distance = carLocation.distanceFromLocation(paxPickup)
                if (distance < 100) {
                    p.pickedUpBy = self
                }
                
            }
        }
        
    }
    
}
