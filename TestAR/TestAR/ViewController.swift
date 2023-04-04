//
//  ViewController.swift
//  TestAR
//
//  Created by Asadbek Nematov on 4/3/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Enable debug options to visualize feature points and world origin
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if let referenceObjectLibrary = createReferenceObjectLibrary() {
            configuration.detectionObjects = referenceObjectLibrary
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal) else {
            return
        }
        let results = sceneView.session.raycast(query)
        
        guard let hitResult = results.first else { return }
        
        let grayRectangle = GrayRectangle()
        grayRectangle.create(width: 1, height: 3) // Change these values to your desired size
        let yOffset: Float = 0.1
        grayRectangle.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y - yOffset, hitResult.worldTransform.columns.3.z)

        
        sceneView.scene.rootNode.addChildNode(grayRectangle)
    }


    
    func createOcclusionMaterial() -> SCNMaterial {
        let occlusionMaterial = SCNMaterial()
        occlusionMaterial.colorBufferWriteMask = []
        return occlusionMaterial
    }
    
    func createReferenceObjectLibrary() -> Set<ARReferenceObject>? {
        guard let objectURL = Bundle.main.url(forResource: "ToyCar", withExtension: "arobject", subdirectory: "AR Resources") else {
            print("Failed to find the toy car's AR object file.")
            return nil
        }

        do {
            let referenceObject = try ARReferenceObject(archiveURL: objectURL)
            let referenceObjectLibrary = Set<ARReferenceObject>(arrayLiteral: referenceObject)
            return referenceObjectLibrary
        } catch {
            print("Failed to load the toy car's AR object file: \(error.localizedDescription)")
            return nil
        }
    }




    
    func createToyCarNode(from referenceObject: ARReferenceObject) -> SCNNode {
        let toyCarNode = SCNNode()
        // Set up toy car node based on the reference object
        // You can add any additional transformations or setup for the toy car node here
        return toyCarNode
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            let toyCarNode = createToyCarNode(from:
                                                objectAnchor.referenceObject)
            toyCarNode.geometry?.firstMaterial = createOcclusionMaterial()
            node.addChildNode(toyCarNode)
        }
    }
}
