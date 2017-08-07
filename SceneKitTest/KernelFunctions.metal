//
//  KernelFunctions.metal
//  SceneKitTest
//
//  Created by Saburo Okita on 04.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//


// Based on https://www.invasivecode.com/weblog/metal-image-processing?doing_wp_cron=1502088541.7522580623626708984375

#include <metal_stdlib>
using namespace metal;


kernel void pixelate( texture2d<float, access::read>  in_texture  [[texture(0)]],
                      texture2d<float, access::write> out_texture [[texture(1)]],
                      device unsigned int *           pixel_size  [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]] ){
    
    const uint2 pixelate_grid = uint2((gid.x / pixel_size[0]) * pixel_size[0],
                                      (gid.y / pixel_size[1]) * pixel_size[1]);
    const float4 color_at_pixel = in_texture.read( pixelate_grid );
    out_texture.write( color_at_pixel, gid );
}
