//
//  Car.swift
//  DispatchDash
//
//  Created by Ariel Liu on 3/16/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit

class Car: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let passengers: [Passenger]
    let waypoints: [NSObject]
    let title: String?
    
    init(title: String, coordinate:CLLocationCoordinate2D, passengers: [Passenger], waypoints: [NSObject]) {
        self.coordinate = coordinate
        self.passengers = passengers
        self.waypoints = waypoints
        self.title = title
        
        super.init()
    }
    
}
