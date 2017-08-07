//
//  NSImage+Extension.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 04.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//

import Foundation
import Accelerate
import Metal
import MetalKit

extension NSImage {
    
    func toMTLTexture(_ metal_device: MTLDevice!) -> MTLTexture {
        guard let cg_image = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError( "Unable to open cgImage" )
        }
        
        
        
        let texture_loader = MTKTextureLoader(device: metal_device )
        do {
            return try texture_loader.newTexture(with: cg_image, options: [:])
        }
        catch let error {
            fatalError("Unable to load image as texture \(error)")
        }
    }
}
