//
//  ViewController.swift
//  TestAR
//
//  Created by Asadbek Nematov on 4/3/23.
//


import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    private var rocketImageView: UIImageView!
    private var whiteBackgroundView: UIView!

    // MARK: - Changing Texture

    @IBOutlet weak var changeTextureButton: UIButton!
    let textureMapping: [String: String] = [
        "moon": "earth",
        "mars": "earth",
        "venus": "mercury",
        "uranus": "jupiter",
        "neptune": "uranus",
        "jupiter": "mars",
        "earth": "moon"
    ]
    
    
    @IBAction func changeTextureButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Change Texture", message: "Select a texture for the gray rectangle", preferredStyle: .actionSheet)
        
        for (rectangleTexture, _) in textureMapping {
            let textureAction = UIAlertAction(title: "\(rectangleTexture.capitalized)", style: .default) { _ in
                self.updateTextures(rectangleTextureName: rectangleTexture)
            }
            alertController.addAction(textureAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateTextures(rectangleTextureName: String) {
        // Update gray rectangle texture
        let textureMaterial = SCNMaterial()
        textureMaterial.diffuse.contents = UIImage(named: "\(rectangleTextureName).jpg")
        grayRectangle?.geometry?.materials = [textureMaterial]
        
        // Update sphere texture
        if let sphereTextureName = textureMapping[rectangleTextureName],
           let sphereNode = grayRectangle?.childNodes.first(where: { $0.geometry is SCNSphere }) {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "\(sphereTextureName).jpg")
            sphereNode.geometry?.materials = [material]
        }
    }
    
    
    
    
    
    // MARK: - Properties
    @IBOutlet var sceneView: ARSCNView!
    
    var nodesToMove: [SCNNode] = []
    var grayRectangle: GrayRectangle?
    var selectedNode: SCNNode?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the white background view
        whiteBackgroundView = UIView(frame: view.bounds)
        whiteBackgroundView.backgroundColor = .white
        view.addSubview(whiteBackgroundView)
        
        // Create the rocket image view
        rocketImageView = UIImageView(image: UIImage(named: "rocket"))
        rocketImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Scale the rocket image view to half its original size
        let scaleFactor: CGFloat = 0.2
        rocketImageView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        whiteBackgroundView.addSubview(rocketImageView)
        
        // Set the initial constraints for the rocket image view
        NSLayoutConstraint.activate([
            rocketImageView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: 400),
            rocketImageView.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor)
        ])

        
        // Layout the view
        view.layoutIfNeeded()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Disable statistics display
        sceneView.showsStatistics = false
        
        // Enable debug options to visualize feature points
        sceneView.debugOptions = [.showFeaturePoints]
        
        // Set up the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Add gesture recognizers
        setUpGestureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate the rocket
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseIn], animations: {
            self.rocketImageView.center = CGPoint(x: self.whiteBackgroundView.center.x, y: -(self.rocketImageView.bounds.height))
        }, completion: { _ in
            // Remove the white background and rocket image view after the animation completes
            self.whiteBackgroundView.removeFromSuperview()
            self.rocketImageView.removeFromSuperview()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the AR session configuration
        setUpARSessionConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Setup Methods
    private func setUpGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setUpARSessionConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    // MARK: - Gesture Recognizers
    class GrayRectangle: SCNNode {
        func create(width: CGFloat, height: CGFloat) {
            let rectangleGeometry = SCNBox(width: width, height: 0.001, length: height, chamferRadius: 0)
            
            let textureMaterial = SCNMaterial()
            textureMaterial.diffuse.contents = UIImage(named: "moon.jpg")
            
            rectangleGeometry.materials = [textureMaterial]
            
            self.geometry = rectangleGeometry
        }
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // Handle tap gesture and create the gray rectangle, Earth and Sun
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal) else {
            return
        }
        let results = sceneView.session.raycast(query)
        guard let hitResult = results.first else { return }
        
        if grayRectangle == nil {
            grayRectangle = GrayRectangle()
            let rectangleWidth: CGFloat = 7
            let rectangleHeight: CGFloat = 7
            grayRectangle!.create(width: rectangleWidth, height: rectangleHeight)
            let yOffset: Float = 10
            grayRectangle!.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y - yOffset, hitResult.worldTransform.columns.3.z)
            
            // Create the textured sphere
            let sphereRadius: CGFloat = 0.3 // Set the size of the sphere
            let sphereNode = createTexturedSphere(radius: sphereRadius, textureName: "earth.jpg")
            
            // Position the sphere above the gray rectangle in the top right corner
            let sphereXOffset: Float = 1
            let sphereZOffset: Float = -3
            sphereNode.position = SCNVector3(sphereXOffset, Float(sphereRadius) + 0.5, sphereZOffset)
            
            // Add the sphere node as a child of the gray rectangle node
            grayRectangle?.addChildNode(sphereNode)
            
            // Create and add the Sun
            let sunRadius: CGFloat = 3
            let sunNode = createTexturedSphere(radius: sunRadius, textureName: "sun.jpg")
            sunNode.position = SCNVector3(-4, Float(sunRadius) - 4, -10)
            grayRectangle!.addChildNode(sunNode)
            
            // Add grayRectangle to the scene
            sceneView.scene.rootNode.addChildNode(grayRectangle!)
            
            // Add grayRectangle to the nodesToMove array
            nodesToMove.append(grayRectangle!)
            
            // Set Earth's tilt and rotation
            let earthTilt: CGFloat = 23.5
            let tiltTransform = SCNMatrix4MakeRotation(GLKMathDegreesToRadians(Float(earthTilt)), 0, 0, 1)
            sphereNode.pivot = SCNMatrix4Mult(tiltTransform, sphereNode.pivot)
            sphereNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 20)))
        }
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        // Handle pan gesture and move the gray rectangle
        
        let sceneView = sender.view as! ARSCNView
        let touchLocation = sender.location(in: sceneView)
        
        if sender.state == .began {
            let hitResults = sceneView.hitTest(touchLocation, options: nil)
            if let hitResult = hitResults.first {
                selectedNode = hitResult.node
            }
        } else if sender.state == .changed, let _ = selectedNode {
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal) else {
                return
            }
            let results = sceneView.session.raycast(query)
            guard let hitResult = results.first else { return }
            let newPosition = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            
            // Move the grayRectangle node
            grayRectangle?.position = newPosition
            
        } else if sender.state == .ended {
            selectedNode = nil
        }
        
    }
    
    // MARK: - Scene Management
    private func createTexturedSphere(radius: CGFloat, textureName: String) -> SCNNode {
        // Create a textured sphere with the specified radius and texture
        let sphere = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: textureName)
        sphere.materials = [material]
        let sphereNode = SCNNode(geometry: sphere)
        return sphereNode
    }
    
    
    private func createBuzzModel() -> SCNNode? {
        // Create and return the Buzz model
        guard let buzzScene = SCNScene(named: "art.scnassets/Buzz.scn"),
              let buzzNode = buzzScene.rootNode.childNode(withName: "Buzz", recursively: true) else {
            print("Failed to load Buzz model")
            return nil
        }
        
        // Scale and position the Buzz model
        let scale: CGFloat = 0.0005 // Adjust this value to resize the Buzz model
        buzzNode.scale = SCNVector3(scale, scale, scale)
        buzzNode.position = SCNVector3(0, 0, 0)
        
        return buzzNode
    }
    
    // MARK: - ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Handle image anchor detection and add the Buzz model
        guard anchor is ARImageAnchor else { return }
        
        // Get the detected image's size
        
        // Create the Buzz model
        guard let buzzNode = createBuzzModel() else { return }
        
        // Position the Buzz model on top of the detected image and at the same level as the grayRectangle
        buzzNode.position = SCNVector3(0, 0.3, 0)
        buzzNode.eulerAngles.x = -.pi / 2
        
        // Add the Buzz model as a child node of the detected image node
        node.addChildNode(buzzNode)
    }
    
}
