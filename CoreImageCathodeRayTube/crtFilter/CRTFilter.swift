//
//  CRTFilter.swift
//  CoreImageCathodeRayTube
//
//  Created by Simon Gladman on 09/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

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
    
    var pixelWidth: CGFloat = 8.0
    var pixelHeight: CGFloat = 12.0
    
    let crtColorKernel = CIColorKernel(string:
        "kernel vec4 crtColor(__sample image, float pixelWidth, float pixelHeight) \n" +
        "{ \n" +
        
        "   int columnIndex = int(mod(samplerCoord(image).x / pixelWidth, 3.0)); \n" +
        "   int rowIndex = int(mod(samplerCoord(image).y, pixelHeight)); \n" +
        
        "   float scanlineMultiplier = (rowIndex == 0 || rowIndex == 1) ? 0.3 : 1.0;" +
        
        "   float red = (columnIndex == 0) ? image.r : image.r * 0.1; " +
        "   float green = (columnIndex == 1) ? image.g : image.g * 0.1; " +
        "   float blue = (columnIndex == 2) ? image.b : image.b * 0.1; " +
        
        "   return vec4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0); \n" +
        "}"
    )
    
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage,
            crtColorKernel = crtColorKernel
        {
            let dod = inputImage.extent
            let args = [inputImage, pixelWidth, pixelHeight]
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
            
            "   coord.x *= 1.0 + pow((abs(coord.y) / 3.2), 2.0);" +
            "   coord.y *= 1.0 + pow((abs(coord.x) / 3.2), 2.0);" +
            
            "   coord  = ((coord / 2.0) + 0.5) * extent;" +
            
            "   return coord;" +
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
