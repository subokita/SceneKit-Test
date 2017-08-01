//
//  DepthMapMesh.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 01.08.17.
//  Copyright © 2017 Saburo Okita. All rights reserved.
//

import Foundation
import SceneKit
import QuartzCore

class DepthMapMesh {
    enum DepthMapMeshError: Error {
        case NoDepthMapFound
    }
    
    var size        : CGSize
    var segments    : CGSize
    var depthMap    : NSImage?
    var segmentSize : CGSize
    
    fileprivate var maxGridSize     : (width: Int, height: Int)
    fileprivate var depthMultiplier : CGFloat = 6.0
    
    
    /**
     * @brief initialize the depth map mesh generator
     */
    init(planeSize size: CGSize, gridDivisions segments: CGSize, depthMap depth_map: NSImage!, depthMultiplier multiplier: CGFloat = 6.0) {
        self.size               = size
        self.segments           = segments
        self.depthMap           = depth_map
        self.depthMultiplier    = multiplier
        
        self.segmentSize = CGSize( width : 2.0 * size.width / segments.width,
                                   height: 2.0 * size.height / segments.height )
        
        self.maxGridSize = ( width: Int(segments.width)   + 1,
                             height: Int(segments.height) + 1 )
        
    }
    
    deinit {
        self.depthMap = nil
    }
    
    /**
     * @brief Create a SCNGeometry based on the given depth map and params
     */
    func createGeometry() -> SCNGeometry {
        let (vertices, uvs)     = try! calculateVerticesAndTexCoords() // FIXME: do a proper exception handling later on
        let (indices, faces)    = calculateIndicesAndFaces( vertices )
        let normals             = calculateNormals( faces )
        
        let sources: [SCNGeometrySource] = [
            SCNGeometrySource(vertices          : vertices),
            SCNGeometrySource(textureCoordinates: uvs),
            SCNGeometrySource(normals           : normals),
        ]
        
        let elements = [
            SCNGeometryElement(indices: indices, primitiveType: SCNGeometryPrimitiveType.triangles)
        ]
        
        return SCNGeometry(sources: sources, elements: elements)
    }
    
    
    /**
     * @brief Calculate vertices and UV coordinates
     */
    func calculateVerticesAndTexCoords() throws -> ([SCNVector3], [CGPoint]) {
        
        guard let depth_map = self.depthMap else {
            throw DepthMapMeshError.NoDepthMapFound
        }
        
        var vertices: [SCNVector3]  = []
        var uvs     : [CGPoint]     = []
        
        let image_rep = NSBitmapImageRep.imageReps(with: depth_map.tiffRepresentation!)[0] as! NSBitmapImageRep
        
        let x_multiplier = depth_map.size.width  / segments.width
        let y_multiplier = depth_map.size.height / segments.height
        
        for y in 0..<maxGridSize.height {
            let y_index = CGFloat( y )
            
            let y_vert  = y_index * segmentSize.height - size.height
            let y_image = DepthMapMesh.clamp(y_index * y_multiplier, min: 0.0, max: depth_map.size.height - 1.0)
            
            for x in 0..<maxGridSize.width {
                let x_index = CGFloat( x )
                
                let x_vert  = x_index * segmentSize.width - size.width
                let x_image = DepthMapMesh.clamp(x_index * x_multiplier, min: 0.0, max: depth_map.size.width - 1.0)
                
                let z_vert  = (image_rep.colorAt(x: Int(x_image), y: Int(y_image))?.cgColor.components![0])! as CGFloat
                
                vertices.append (SCNVector3Make( x_vert, -y_vert, (z_vert - 0.5) * depthMultiplier))
                uvs.append      (CGPoint( x: Double(x_index / segments.width),
                                          y: Double(y_index / segments.height)))
            }
        }
        
        return (vertices, uvs)
    }
    
    /**
     * @brief Calculate element indices and faces
     */
    func calculateIndicesAndFaces(_ vertices: [SCNVector3]) -> ([Int16], [Face]) {
        var faces  : [Face]  = []
        var indices: [Int16] = []
        
        for y_index in 0..<Int(segments.height) {
            for x_index in 0..<Int(segments.width) {
                
                let tl = (x_index    ) + (maxGridSize.width) * (y_index    );
                let bl = (x_index    ) + (maxGridSize.width) * (y_index + 1);
                let br = (x_index + 1) + (maxGridSize.width) * (y_index + 1);
                let tr = (x_index + 1) + (maxGridSize.width) * (y_index    );
                
                indices.append(Int16(tl))
                indices.append(Int16(bl))
                indices.append(Int16(br))
                
                faces.append( Face(a: vertices[tl],
                                   b: vertices[bl],
                                   c: vertices[br]))
                
                indices.append(Int16(tl))
                indices.append(Int16(br))
                indices.append(Int16(tr))
                
                faces.append( Face(a: vertices[tl],
                                   b: vertices[br],
                                   c: vertices[tr]))
            }
        }
        
        return (indices, faces)
    }
    
    /**
     * @brief   Supposed to be calculating normals,m but it ends up having
     *          dark bands on certain parts, maybe it's my calculation, or maybe
     *          it's my depth map
     */
    func calculateNormals(_ faces: [Face]) -> [SCNVector3] {
        // FIXME: This doesn't seem to be correct
        // return faces.map{ $0.calculateNormal() }
        var normals : [SCNVector3] = []
        
        for _ in 0..<faces.count {
            normals.append( SCNVector3Make(0.0, 0.0, 1.0) )
        }
        return normals
    }
    
    
    /**
     * @brief Clamp CGFloat value
     */
    static func clamp(_ value: CGFloat, min min_value: CGFloat, max max_value: CGFloat) -> CGFloat {
        return max( min( value, max_value ), min_value )
    }
}
