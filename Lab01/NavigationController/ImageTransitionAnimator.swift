//
//  CustomAnimator.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit

protocol ImageTransitionAnimatable {
    var imageViewForTransition: UIImageView! { get set }
    var imageFrame: CGRect { get }
}

extension ImageTransitionAnimatable where Self: UIViewController {
    var imageFrame: CGRect {
        var frame = imageViewForTransition.superview!
            .convert(imageViewForTransition.frame, to: view)
        frame.origin = frame.origin.add(x: 0, y: UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0))
        return frame
    }
}

class ImageTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: Double = 0.3

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        let toViewController = transitionContext.viewController(forKey: .to) as! ImageTransitionAnimatable
        let fromViewController = transitionContext.viewController(forKey: .from) as! ImageTransitionAnimatable
        
        let blackOverlay = UIView(frame: fromView.frame)
        blackOverlay.backgroundColor = .black
        blackOverlay.alpha = 0
        container.addSubview(blackOverlay)
        
        let startFrame = fromViewController.imageFrame
        let endFrame = toViewController.imageFrame
        let snapShotView = fromViewController.imageViewForTransition.snapshotView()!
        
        snapShotView.frame = startFrame
        container.addSubview(snapShotView)
        
        toView.frame = fromView.frame
        
        toViewController.imageViewForTransition.alpha = 0
        fromViewController.imageViewForTransition.alpha = 0
        
        UIView.animate(withDuration: duration/2, animations: {
            blackOverlay.alpha = 1
        })
        { [unowned self] _ in
            container.addSubview(toView)
            container.bringSubview(toFront: blackOverlay)
            container.bringSubview(toFront: snapShotView)
            UIView.animate(withDuration: self.duration/2, animations: {
                blackOverlay.alpha = 0
            })
        }
        
        UIView.animate(withDuration: duration, animations: {
            snapShotView.frame = endFrame
            })
        {  _ in
            blackOverlay.removeFromSuperview()
            snapShotView.removeFromSuperview()
            toViewController.imageViewForTransition.alpha = 1
            fromViewController.imageViewForTransition.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}
