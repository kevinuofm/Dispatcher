//
//  PassengerView.swift
//  DispatchDash
//
//  Created by Ariel Liu on 3/16/16.
//  Copyright © 2016 Ariel & Kevin. All rights reserved.
//

import UIKit
import MapKit

class PassengerView: MKAnnotationView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func drawRect(rect: CGRect) {
        let passengerAnnotation = self.annotation as! Passenger
        
        let endAngle = Double(passengerAnnotation.waitMax - passengerAnnotation.waitTime) * M_PI * 2 / Double(passengerAnnotation.waitMax)
        
        let radius = rect.width / 2
        let lineWidth = CGFloat(1 * radius / 2)
        
        let center = CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius)
        
        let circlePath = UIBezierPath(
            arcCenter: center,
            radius: radius - (lineWidth),
            startAngle: CGFloat(0),
            endAngle: CGFloat(endAngle),
            clockwise: true)
        
        
        UIColor.whiteColor().setFill()
        UIColor.redColor().setStroke()
        circlePath.lineWidth = lineWidth
    
        circlePath.fill()
        circlePath.stroke()
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.blueColor().CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.redColor().CGColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        
        super.drawRect(rect)
    }
}
