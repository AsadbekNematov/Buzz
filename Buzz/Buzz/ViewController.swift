//
//  ViewController.swift
//  Buzz
//
//  Created by Asadbek Nematov on 3/31/23.
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/road.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
}
