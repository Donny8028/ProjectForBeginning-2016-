//
//  EditableViewController.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/3/29.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditableViewController: UIViewController , UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    
    var waypoint:GPX.Waypoint? {
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet{
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var infoTextField: UITextField! {
        didSet{
            infoTextField.delegate = self
        }
    }
    

    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        //dissmiss the ViewController from the presentingViewController including presentingViewController itself.
    }
    
    //MARK: - Image
    
    @IBAction func takePicture() {
        let picker = UIImagePickerController() // kind of viewController
        if UIImagePickerController.isSourceTypeAvailable(.Camera){ // class function of UIImagePickerViewController
            picker.sourceType = .Camera
            // if needs video, check the media type, but only the image, don't check
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }

        imageView.image = image

        makeRoomForImage()
        saveImage()
        dismissViewControllerAnimated(true, completion: nil) // It is the camera's presentingViewController
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: SaveImage
    func saveImage() {
        if let image =  imageView.image {
            if let imageData = UIImageJPEGRepresentation(image, 1){ // Normally, we turn url to imagedata then image created, this case is turn an image to imagedata
                let fileManager = NSFileManager()
                if let docsDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                    let uniqueName = NSDate.timeIntervalSinceReferenceDate()
                    let url = docsDirectory.URLByAppendingPathComponent("\(uniqueName).jpg") //this is absoluteURL
                    let path = url.absoluteString // AbsoluteURL displays some symbol that we can't know, so turn it to absoulteString.
                    if imageData.writeToURL(url, atomically: true) {
                        waypoint?.links = [GPX.Link(href: path)]
                    }
                }
            }
        }
    }
    
    
    var imageView = UIImageView()
    
    @IBOutlet weak var imageViewContainer: UIView!{
        didSet{
            imageViewContainer.addSubview(imageView)
        }
    }
    
    // MARK: - Notification 
    //Users change the text
    var nObserver:NSObjectProtocol?
    var iObserver:NSObjectProtocol?
    
    func observer() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        nObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue) { notification in
            if let waypoint = self.waypoint {
                waypoint.name = self.nameTextField.text
            }
        }
        iObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue) { notification in
            if let waypoint = self.waypoint {
                waypoint.info = self.infoTextField.text
            }
        }
        //but this observer will persist, needs to be removed.  create a NSObjectProtocol to store it and remove in viewWillDisappear.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()
    }
    
    func updateUI() {
        if waypoint != nil {
        nameTextField?.text = waypoint!.name
        infoTextField?.text = waypoint!.info
        }
    }
    // MARK: - Observer
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observer()
    }
    
    override func viewWillDisappear(animated: Bool) {  //remove observer
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(nObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(iObserver!)
    }
}
extension EditableViewController {
    func makeRoomForImage () {
        var extraHeight:CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                    extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        }else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
        //super.preferredContentSize has not yet add the extraHeight when culculate the preferred size.
        //only for popover size
    }
}
extension UIImage {
    var aspectRatio:CGFloat {
        let imageWidth = size.width
        let imageHeight = size.height
        return size.height != 0 ? imageWidth / imageHeight : 0
    }
}



















