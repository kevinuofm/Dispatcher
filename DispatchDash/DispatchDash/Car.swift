//
//  Car.swift
//  DispatchDash
//
//  Created by Ariel Liu on 3/16/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit

class Car: MKPointAnnotation {
    var passengers: [Passenger]
    var coordWaypoints: [CLLocationCoordinate2D] = []
    var counter = 0
    
    init(title: String, coordinate:CLLocationCoordinate2D, passengers: [Passenger]) {
        self.passengers = passengers
        super.init()
        
        self.coordinate = coordinate
        self.title = title
    }
    
    func addRouteToPassenger(passenger: Passenger, route: MKRoute) {
        passengers.append(passenger)
        
        let waypointCount = route.polyline.pointCount
        let range = NSMakeRange(0, waypointCount)
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(waypointCount)

        route.polyline.getCoordinates(coordsPointer, range: range)
        
        for i in 0..<waypointCount {
            coordWaypoints.append(coordsPointer[i])
        }
        
    }
    
    func onTick(timer: NSTimer) {
        if (counter < coordWaypoints.count) {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.coordinate = self.coordWaypoints[self.counter]
            })
            print (self.coordinate)
            counter++
        } else {
            for p in passengers {
                
            }
        }
        
    }
    
}
