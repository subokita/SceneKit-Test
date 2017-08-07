//
//  MetalManager.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 04.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//

import Foundation
import Accelerate
import Metal
import MetalKit

/**
 * @brief   handles the setup of Metal Compute.
 *          PS: MetalManager is a horrible name
 */
class MetalManager {
    static let sharedInstance = MetalManager()
    
    var device               : MTLDevice!
    var commandQueue         : MTLCommandQueue!
    var defaultLibrary       : MTLLibrary!
    var commandBuffer        : MTLCommandBuffer!
    var computeCommandEncoder: MTLComputeCommandEncoder!
    var threadGroupCount     : MTLSize! = MTLSizeMake(16, 16, 1)
    
    init() {
        device                = MTLCreateSystemDefaultDevice()
        commandQueue          = device.makeCommandQueue()
        defaultLibrary        = device.newDefaultLibrary()
        commandBuffer         = commandQueue.makeCommandBuffer()
        computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
    }
    
    /**
     * @brief   Sets the kernel function to be used, currently only 'pixelate'
     */
    func setMetalShader(withName name: String ){
        let kernel_function: MTLFunction! = defaultLibrary.makeFunction(name: name)
        let pipeline_state : MTLComputePipelineState?
        do {
            pipeline_state = try device.makeComputePipelineState(function: kernel_function )
        }
        catch let error {
            fatalError( "Unable to create compute pipeline state \(error)" )
        }
        
        computeCommandEncoder.setComputePipelineState(pipeline_state!)
    }
    
    /**
     * @brief   Apply pixelation compute shader
     */
    func apply(with image: NSImage!, andPixelSize pixel_size: [UInt32]! = [16, 16] ) -> NSImage! {
        let in_texture = image.toMTLTexture(self.device)
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat   : MTLPixelFormat.bgra8Unorm,
                                                                  width         : in_texture.width,
                                                                  height        : in_texture.height,
                                                                  mipmapped     : false)

        descriptor.usage = MTLTextureUsage.shaderWrite
        
        let out_texture = self.device.makeTexture(descriptor: descriptor)
        
        computeCommandEncoder.setTexture(in_texture,  at: 0)
        computeCommandEncoder.setTexture(out_texture, at: 1)
        
        let buffer = device.makeBuffer(bytes    : pixel_size,
                                       length   : MemoryLayout<UInt32>.size * pixel_size.count,
                                       options  : MTLResourceOptions.storageModeShared)
        
        computeCommandEncoder.setBuffer(buffer, offset: 0, at: 0)
        
        let thread_groups = MTLSizeMake( in_texture.width / threadGroupCount.width, in_texture.height / threadGroupCount.height, 1)
        computeCommandEncoder.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: threadGroupCount)
        computeCommandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return out_texture.toNSImage()
    }
}
