//
//  ContainedMapViewController.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/4/5.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class ContainedMapViewController: ImageViewController {
    
    var waypoint:GPX.Waypoint? {
        didSet{
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            updateUI()
        }
    }
    
    var smvc:SmallMapViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Map" {
            smvc = segue.destinationViewController as? SmallMapViewController
            updateUI()
        }
    }//way to set the self attributes of the mapView
    
    func updateUI() {
        if let mapView = smvc?.mapView {
            mapView.mapType = .Satellite
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(waypoint!)
            mapView.showAnnotations(mapView.annotations, animated: true)
            
        }
    
    }
    

}
