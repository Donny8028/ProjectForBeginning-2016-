//
//  ViewController.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/3/23.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL:NSURL? {
        didSet {
                clearWaypoints()
                if let url = gpxURL {
                GPX.parse(url) { gpx in
                    if let GPX = gpx {
                        self.handleWaypoints(GPX.waypoints)
                    }
                }
            }
        }
    }
    
    
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = GPX.Waypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
        
    }
    

    
    // MARK: - Configuring callout accessories
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == .DetailDisclosure {  // set the UIControl to the accessory you set
            performSegueWithIdentifier(Constants.EditWayPointSegueIdentifier, sender: view) //this sender is the view do this segue, in this case is annotationView
            mapView.deselectAnnotation(view.annotation, animated: true)
        }else if (view.leftCalloutAccessoryView as? UIButton) != nil {
            performSegueWithIdentifier(Constants.ImageSegueIdentifier, sender: view)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.EditWayPointSegueIdentifier {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint{
                if let ewvc = segue.destinationViewController.contentViewController as? EditableViewController {
                    if let pop = ewvc.popoverPresentationController{
                        let coordinate = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
                        pop.sourceRect = (sender as! MKAnnotationView).popoverSourceRect(coordinate) // has checked above sender as annotationView
                        let minimunSize = ewvc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        ewvc.preferredContentSize = CGSize(width: 320, height: minimunSize.height)
                        pop.delegate = self
                    }
                    ewvc.waypoint = waypoint
                }
            }
        } else if segue.identifier == Constants.ImageSegueIdentifier {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let cmvc = segue.destinationViewController as? ContainedMapViewController{
                    cmvc.waypoint = waypoint
                }else if let imvc = segue.destinationViewController as? ImageViewController {
                    imvc.imageURL = waypoint.imageURL
                    imvc.title = waypoint.name
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let nvc = UINavigationController(rootViewController: controller.presentedViewController) //needs to specify the root VC, otherwise, it will return a new navigationVC
        let visualBackground = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualBackground.frame = nvc.view.frame
        nvc.view.insertSubview(visualBackground, atIndex: 0)
        return nvc
    }

    // MARK: - Constants
    struct Constants {
        static let ReusableAnnotation = "waypoint"
        static let EditWayPointSegueIdentifier = "Edit Waypoint"
        static let ImageFrame = CGRect(x: 0, y: 0, width: 59, height: 59) // (0,0) is the callout upper left
        static let ImageURL = NSURL(string: "http://i.imgur.com/fr9oHsA.jpg")
        static let ImageSegueIdentifier = "Show Image"
        static let ButtonSize = CGSize(width: 59, height: 59)
    }
    
    
    
    // MARK: - AnnotationView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.ReusableAnnotation)
        if view == nil {        //there's no outlay in storyboard
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.ReusableAnnotation)
        }
        view?.annotation = annotation
        view?.canShowCallout = true
// view?.draggable = annotation is GPX.Waypoint // the demo is present " annotation is EdibleWaypoint
        view?.rightCalloutAccessoryView = nil
        view?.leftCalloutAccessoryView = nil
        if annotation is GPX.Waypoint {
            view?.draggable = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
//            view?.leftCalloutAccessoryView = UIButton(frame: Constants.ImageFrame)
//            //must specify the size in this case
            
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint{
            if let url = waypoint.thumbnail {
                if view.leftCalloutAccessoryView == nil {
                    view.leftCalloutAccessoryView = UIButton(frame: Constants.ImageFrame)
                }
            if let imageButton = view.leftCalloutAccessoryView as? UIButton {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                let queue = dispatch_get_global_queue(qos, 0)
                    dispatch_async(queue) {
                        if let imageData = NSData(contentsOfURL: url) {
                            dispatch_async(dispatch_get_main_queue()){
                                if url == waypoint.thumbnail {
                                    if let image = UIImage(data: imageData) {
                                        imageButton.setImage(image, forState: .Normal)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func clearWaypoints() {
        if mapView?.annotations != nil { //must add "?" , the system could be sent nil to it
        mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }
    
    func handleWaypoints(waypoints:[GPX.Waypoint]) { // the GPX.Waypoint is not an annotation, because it does not conform to MKAnnotation protocol to be it
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)  //show annotation automatically
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NSNotificationCenter.defaultCenter()
        let appDelegate = UIApplication.sharedApplication().delegate
        center.addObserverForName(GPXURL.NotificationName, object: appDelegate, queue: NSOperationQueue.mainQueue()) { (notification) in
            //this observer will always exist until you remove it from the center
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL { //userInfo is a optional dictionary type, so it have to mark ? before call key
                self.gpxURL = url
            }
        }
        self.gpxURL = NSURL(string:"http://cs193p.stanford.edu/Vacation.gpx")
    }
    
}
extension UIViewController {
    var contentViewController:UIViewController {
        if let viewController = self as? UINavigationController {
            let nvc = viewController.visibleViewController
            return nvc!
        }else {
            return self
        }
    }
}

extension MKAnnotationView {
    func popoverSourceRect(coordinate: CGPoint) -> CGRect {
        var popoverOrigin = coordinate
        popoverOrigin.x -= frame.width/2 - centerOffset.x - calloutOffset.x
        popoverOrigin.y -= frame.height/2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverOrigin, size: frame.size)
    }
    
    
}

//史丹佛版的demo 這裡的mapView(didSelected:) 這個function指定為 as GPX.Waypoint是因為只要在此mapView上的annotation都需要segue至大圖(EditableWaypoint 也是GPX.Waypoint的一種，之所以為兩個class是因為要編輯此annotation的title和subtitle與拍照(因此拍的照片segue至大圖適用於 as GPX.Waypoint

//所以GPX.Waypoint 對於可編輯與不可編輯的annotation都有效







