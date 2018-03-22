//
//  ViewController.swift
//  DragandDrop
//
//  Created by Praveen Pendyala on 3/20/18.
//  Copyright © 2018 Praveen Pendyala. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate {
    
    @IBAction func buttonTouchUpInside(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        for view in self.view.subviews {
            if let imageView = view as? UIImageView {
                imageView.image?.draw(in: view.frame)
            }
            view.removeFromSuperview()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        self.view.addSubview(imageView)
        imageView.frame = self.view.frame
        imageView.center = self.view.center
        imageView.isUserInteractionEnabled = true
        let myPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.myPanAction))
        imageView.addGestureRecognizer(myPanGestureRecognizer)
        let myPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinch))
        imageView.addGestureRecognizer(myPinchGestureRecognizer)
        let myrotationGestureRecongnizer = UIRotationGestureRecognizer(target: self, action: #selector(self.imageRotated))
        imageView.addGestureRecognizer(myrotationGestureRecongnizer)
        let flipGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageDoubleTapped))
        flipGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(flipGestureRecognizer)
        let indexGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageBringToFront))
        imageView.addGestureRecognizer(indexGestureRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //The operation that this interaction proposes to perform.
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        //Returns true if any of the session's items could create any objects of the specified class.
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items { // (1)
            // (2)
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { object, error in
                // (3)
                guard error == nil else { return print("Failed to load our dragged item") }
                guard let draggedImage = object as? UIImage else { return } // (4)
                
                DispatchQueue.main.async { // (5)
                    let imageView = UIImageView(image: draggedImage) // (6)
                    self.view.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    
                    let centerPoint = session.location(in: self.view)
                    imageView.center = centerPoint
                    imageView.isUserInteractionEnabled = true
                    let myPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.myPanAction))
                    imageView.addGestureRecognizer(myPanGestureRecognizer)
                    let myPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinch))
                    imageView.addGestureRecognizer(myPinchGestureRecognizer)
                    let myrotationGestureRecongnizer = UIRotationGestureRecognizer(target: self, action: #selector(self.imageRotated))
                    imageView.addGestureRecognizer(myrotationGestureRecongnizer)
                    let flipGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageDoubleTapped))
                    flipGestureRecognizer.numberOfTapsRequired = 2
                    imageView.addGestureRecognizer(flipGestureRecognizer)
                    let indexGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageBringToFront))
                    imageView.addGestureRecognizer(indexGestureRecognizer)
                }
            })
        }
    }
    
    @objc func imageBringToFront(sender: UITapGestureRecognizer) {
        let index = self.view.subviews.index(of: sender.view!)!
        self.view.exchangeSubview(at: index, withSubviewAt: index+1)
    }
    
    @objc func imageDoubleTapped(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            var image = UIImage()
            if imageView.image?.imageOrientation == UIImageOrientation.upMirrored {
                image = UIImage(cgImage: (imageView.image?.cgImage)!, scale: 1, orientation: UIImageOrientation.up)
            }
            else {
                image = UIImage(cgImage: (imageView.image?.cgImage)!, scale: 1, orientation: UIImageOrientation.upMirrored)
            }
            imageView.image = image
        }
    }
    
    @objc func imageRotated(sender: UIRotationGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.rotated(by: sender.rotation))!
        sender.rotation = 0
    }
    
    @objc func didPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.view?.transform = (sender.view?.transform.scaledBy(x: scale, y: scale))!
        sender.scale = 1
    }
    
    @objc func myPanAction(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let myView = recognizer.view {
            myView.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
}

