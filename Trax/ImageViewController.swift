//
//  ImageViewController.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/4/1.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate{
    
    
    
    var imageURL:NSURL? {
        didSet{
            image = nil
            if view.window != nil{
                getImage()
            }
        }
    }

    var image:UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            if newValue != nil {
                spinner.stopAnimating()
            }
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageView = UIImageView()
    // Do I need to set its frameSize? NO, just in callout accessory case needs.
    
    func getImage(){
        if let url = imageURL {  
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            let queue = dispatch_get_global_queue(qos, 0)
            dispatch_async(queue) {
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        }else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = Constants.ScrollViewMaxZoom
            scrollView.minimumZoomScale = Constants.ScorllViewMinZoom
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        spinner.startAnimating()
        if image == nil {
            getImage()
        }
    }
    
    
    
    struct Constants {
        static let ScrollViewMaxZoom:CGFloat = 2.0
        static let ScorllViewMinZoom:CGFloat = 0.03
    }
}

