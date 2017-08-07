//
//  MTLTexture+Extensions.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 04.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//

import Foundation
import Accelerate
import Metal
import MetalKit

extension MTLTexture {
    func toNSImage() -> NSImage! {
        // FIXME:
        precondition( self.pixelFormat == .bgra8Unorm )
        
        let total_byte_count = self.width * self.height * 4
        let bytes_per_row = self.width * 4
        
        var source = [UInt8](repeating: 0, count: total_byte_count)
        var source_buffer = vImage_Buffer(data      : &source,
                                          height    : vImagePixelCount(self.height),
                                          width     : vImagePixelCount(self.width),
                                          rowBytes  : bytes_per_row)
        
        let region = MTLRegionMake2D(0, 0, self.width, self.height)
        self.getBytes(&source, bytesPerRow: bytes_per_row, from: region, mipmapLevel: 0)
        
        // Convert from BGRA 8 Unsigned image to to RGBA 8 Unsigned
        var permute_map: [UInt8] = [2, 1, 0, 3]
        var target        = [UInt8](repeating: 0, count: total_byte_count)
        var target_buffer = vImage_Buffer(data      : &target,
                                          height    : vImagePixelCount(self.height),
                                          width     : vImagePixelCount(self.width),
                                          rowBytes  : bytes_per_row)
        
        vImagePermuteChannels_ARGB8888(&source_buffer, &target_buffer, &permute_map, 0 )
        
        
        let bitmap_info = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        let color_space = CGColorSpaceCreateDeviceRGB()
        let bits_per_component = 8
        
        let context = CGContext(data            : &target,
                                width           : self.width,
                                height          : self.height,
                                bitsPerComponent: bits_per_component,
                                bytesPerRow     : bytes_per_row,
                                space           : color_space,
                                bitmapInfo      : bitmap_info.rawValue)
        
        
        let result = context?.makeImage()
        return NSImage(cgImage: result!, size: NSSize(width: self.width, height: self.height))
    }
}

