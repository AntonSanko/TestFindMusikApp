//
//  Animation.swift
//  ForTests
//
//  Created by Anton on 28/05/2022.
//

import UIKit.UIView

class Animator {
    func scaleAndFade(views: [UIView], identity: Bool ) {
        UIView.animate(withDuration: 0.5) {
            views.forEach {
                $0.transform = identity ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
                $0.alpha = identity ? 1 : 0
            }
        }
    }
    func fade(view: UIView, fade: Bool) {
        UIView.animate(withDuration: 0.5) {
            view.alpha = fade ? 0 : 1
        }
    }
    func animateMatchPulse(view: UIView) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [.repeat, .autoreverse]) {
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            UIView.animate(withDuration: 1, delay: 0) {
                view.transform = CGAffineTransform.identity
            }
        }
    }
}
