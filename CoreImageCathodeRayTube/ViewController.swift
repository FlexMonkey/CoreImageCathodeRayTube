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
    
    let crtFilter = CRTFilter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(imageView)

        crtFilter.inputImage = sunflower
  
        imageView.image = UIImage(CIImage: crtFilter.outputImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class CRTFilter: CIFilter
{
    var inputImage : CIImage?
    
    let crtWarpFilter = CRTWarpFilter()
    let crtColorFilter = CRTColorFilter()
    
    let vignette = CIFilter(name: "CIVignette",
        withInputParameters: [
            kCIInputIntensityKey: 1.5,
            kCIInputRadiusKey: 2])!
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }

        crtColorFilter.inputImage = inputImage
        vignette.setValue(crtColorFilter.outputImage,
            forKey: kCIInputImageKey)
        crtWarpFilter.inputImage = vignette.outputImage!
     
        return crtWarpFilter.outputImage
    }
}

class CRTColorFilter: CIFilter
{
    var inputImage : CIImage?
    
    let crtColorKernel = CIColorKernel(string:
        "kernel vec4 crtColor(__sample image) \n" +
        "{ \n" +
            
        "   float pixelWidth = 4.0;" +
        "   float pixelHeight = 8.0;" +
            
        "   int columnIndex = int(mod(samplerCoord(image).x / pixelWidth, 3.0)); \n" +
        "   int rowIndex = int(mod(samplerCoord(image).y, pixelHeight)); \n" +
            
        "   float scanlineMultiplier = (rowIndex == 0) ? 0.3 : 1.0;" +
            
        "   float red = (columnIndex == 0) ? image.r : 0.0; " +
        "   float green = (columnIndex == 1) ? image.g : 0.0; " +
        "   float blue = (columnIndex == 2) ? image.b : 0.0; " +
            
        "   return vec4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0); \n" +
        "}"
    )
    
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage,
            crtColorKernel = crtColorKernel
        {
            let dod = inputImage.extent
            let args = [inputImage as AnyObject]
            return crtColorKernel.applyWithExtent(dod, arguments: args)
        }
        return nil
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