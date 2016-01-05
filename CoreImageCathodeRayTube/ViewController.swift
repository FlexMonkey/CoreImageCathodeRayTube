//
//  ViewController.swift
//  CoreImageCathodeRayTube
//
//  Created by Simon Gladman on 05/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let sunflower = CIImage(image: UIImage(named: "DSCF1145.jpg")!)!
    
    let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 1024, height: 683))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(imageView)
        
        let crtWarpFilter = CRTWarpFilter()
        crtWarpFilter.inputImage = sunflower
        
        imageView.image = UIImage(CIImage: crtWarpFilter.outputImage!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


class CRTWarpFilter: CIFilter
{
    var inputImage : CIImage?
   
    let crtWarpKernel = CIWarpKernel(string:
        "kernel vec2 crtWarp(vec2 extent)" +
        "{" +
        "   vec2 coord = ((destCoord() / extent) - 0.5) * 2.0;" +

        "   coord *= 1.1;" +

        "   coord.x *= 1.0 + pow((abs(coord.y) / 3.2), 2.0);" +
        "   coord.y *= 1.0 + pow((abs(coord.x) / 3.2), 2.0);" +
    
        "   coord  = (coord / 2.0) + 0.5;" +
        
        "   return coord * extent;" +
        "}"
    )
    
    override var outputImage : CIImage!
        {
            if let inputImage = inputImage,
                crtWarpKernel = crtWarpKernel
            {
                let arguments = [CIVector(x: inputImage.extent.size.width, y: inputImage.extent.size.height)]
                let extent = inputImage.extent.insetBy(dx: -1, dy: -1)
           
                return crtWarpKernel.applyWithExtent(extent,
                    roiCallback:
                    {
                        (index, rect) in
                        return rect
                    },
                    inputImage: inputImage,
                    arguments: arguments)
            }
            return nil
    }
}