//
//  AnimationClass.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 23.11.2025.
//

import UIKit

protocol IAnimationClass: AnyObject {
    func springAnimation<T: UIView>(view: T)
    func stopAnimation<T: UIView>(view: T)
}

final class AnimationClass: IAnimationClass  {
    
    func springAnimation<T: UIView>(view: T) {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.stiffness = 300
        animation.mass = 1
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime() + 0
        animation.repeatCount = .infinity
        view.layer.add(animation, forKey: nil)
    }
    
    func stopAnimation<T: UIView>(view: T) {
        view.layer.removeAllAnimations()
    }
}
