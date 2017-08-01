//
//  Face.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 01.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//

import Foundation
import SceneKit

/**
 * @brief A temporary polygon face data-structure
 */
struct Face {
    var a: SCNVector3
    var b: SCNVector3
    var c: SCNVector3
    
    var description: String {
        return "{\n" +
            "    a: \(a.x) \(a.y) \(a.z)\n" +
            "    b: \(b.x) \(b.y) \(b.z)\n" +
            "    c: \(c.x) \(c.y) \(c.z)\n" +
        "}\n"
    }
    
    func calculateNormal() -> SCNVector3 {
        return (b-a).cross(vec: (c-a)).normalized()
    }
}
    
