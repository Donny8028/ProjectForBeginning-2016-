//
//  MKGPX.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/3/27.
//  Copyright © 2016年 Donny. All rights reserved.
//

import MapKit 

extension GPX.Waypoint:MKAnnotation {
    var coordinate:CLLocationCoordinate2D {
        get {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var title:String? {
        return name
    }
    var subtitle:String? {
        return info
    }
    
    var thumbnail:NSURL? {
        return imageURL
    }
    var imageURL:NSURL? {
        return links.first?.url
    }
}