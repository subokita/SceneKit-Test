//
//  GameViewController.swift
//  SceneKitTest
//
//  Created by Saburo Okita on 31.07.17.
//  Copyright (c) 2017 Saburo Okita. All rights reserved.
//

import SceneKit
import QuartzCore


class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        let scene = SCNScene()

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        
        let depth_map_mesh = DepthMapMesh(  planeSize    : CGSize(width: 10, height: 10), 
                                            gridDivisions: CGSize(width: 100, height: 100),
                                            depthMap     : NSImage(named: "IMG_0915d.jpg"))

        let mesh_geometry = depth_map_mesh.createGeometry()
        
        let manager = MetalManager()
        manager.setMetalShader(withName: "pixelate")
        let pixellated = manager.apply(with: NSImage(named: "IMG_0915.jpg") )
        
        let material                        = SCNMaterial()
        material.diffuse.contents           = pixellated
        material.diffuse.wrapS              = SCNWrapMode.repeat
        material.diffuse.wrapT              = SCNWrapMode.repeat
        material.diffuse.contentsTransform  = SCNMatrix4Identity
        material.isDoubleSided              = true
        material.normal.wrapS               = SCNWrapMode.repeat
        material.normal.wrapT               = SCNWrapMode.repeat
        material.shaderModifiers = [
            SCNShaderModifierEntryPoint.geometry :
                """
                uniform float depth_multiplier;
                _geometry.position.z *= depth_multiplier;
                """
        ]
        
        SCNTransaction.begin()
        material.setValue(6.0, forKey: "depth_multiplier")
        SCNTransaction.commit()
        
        mesh_geometry.materials = [material]
        
        let mesh_node = SCNNode(geometry: mesh_geometry)
        scene.rootNode.addChildNode( mesh_node )
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black
    }
}
