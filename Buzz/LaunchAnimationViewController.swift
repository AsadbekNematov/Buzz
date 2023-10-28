//
//  LaunchAnimationViewController.swift
//  Buzz
//
//  Created by Asadbek Nematov on 4/19/23.
//

import UIKit

class LaunchAnimationViewController: UIViewController {
    var rocketImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the white background view
        view.backgroundColor = .white
        
        // Set up the rocket image view
        let rocketImage = UIImage(named: "rocket")
        rocketImageView = UIImageView(image: rocketImage)
        rocketImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rocketImageView)
        
        // Set the initial position of the rocket image view
        let rocketHeight = rocketImageView.bounds.height
        rocketImageView.frame.origin.y = view.bounds.height - rocketHeight
        
        // Set up constraints for the rocket image view
        let bottomConstraint = rocketImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            rocketImageView.widthAnchor.constraint(equalToConstant: 100),
            rocketImageView.heightAnchor.constraint(equalToConstant: 200),
            rocketImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomConstraint,
            rocketImageView.topAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animate the rocket image view
        animateRocket()
    }
    private func animateRocket() {
        // Set initial position of rocket
        self.rocketImageView.frame.origin.y = self.view.bounds.height - self.rocketImageView.bounds.height - 20
        
        // Set up animation properties
        let animationOptions: UIView.AnimationOptions = [.curveEaseOut]
        let timingFunction = CAMediaTimingFunction(name: .easeOut)
        let finalPosition = CGPoint(x: self.rocketImageView.frame.origin.x, y: -self.rocketImageView.frame.size.height)
        
        // Perform animation
        UIView.animate(withDuration: 1.5, delay: 0, options: animationOptions, animations: {
            self.rocketImageView.frame.origin = finalPosition
        }, completion: { (completed) in
            // Remove rocket image view from superview
            self.rocketImageView.removeFromSuperview()
        })
        
        // Add easing effect to animation
        let keyPath = "position.y"
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.values = [self.rocketImageView.center.y, finalPosition.y]
        animation.keyTimes = [0, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.duration = 1.5
        self.rocketImageView.layer.add(animation, forKey: "rocketAnimation")
    }

    
    private func setupRocket() {
        rocketImageView = UIImageView(image: UIImage(named: "rocket"))
        rocketImageView.center = CGPoint(x: view.center.x, y: view.bounds.maxY)
        view.addSubview(rocketImageView)
    }
    
    private func transitionToMainViewController() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = mainStoryboard.instantiateInitialViewController()
        self.view.window?.rootViewController = mainViewController
        self.view.window?.makeKeyAndVisible()
    }
}
