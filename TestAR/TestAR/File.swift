//
//  File.swift
//  TestAR
//
//  Created by Asadbek Nematov on 4/3/23.
//
import SceneKit
import ARKit

class GrayRectangle: SCNNode {
    func create(width: CGFloat, height: CGFloat) {
        let rectangleGeometry = SCNBox(width: width, height: 0.001, length: height, chamferRadius: 0)
        
        let grayMaterial = SCNMaterial()
        grayMaterial.diffuse.contents = UIColor.gray
        
        rectangleGeometry.materials = [grayMaterial]
        
        self.geometry = rectangleGeometry
    }
}
