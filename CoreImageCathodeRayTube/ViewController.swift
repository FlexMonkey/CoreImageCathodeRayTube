//
//  ViewController.swift
//  CoreImageCathodeRayTube
//
//  Created by Simon Gladman on 05/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CameraCaptureHelperDelegate
{
    let imageView = ImageView()
    
    let cameraCaptureHelper = CameraCaptureHelper(cameraPosition: .Back)
    
    let crtFilter = CRTFilter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        
        cameraCaptureHelper.delegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        imageView.frame = view.bounds
    }
    
    
    func newCameraImage(cameraCaptureHelper: CameraCaptureHelper, image: CIImage)
    {
        crtFilter.inputImage = image
        
        imageView.image = crtFilter.outputImage
    }
}
