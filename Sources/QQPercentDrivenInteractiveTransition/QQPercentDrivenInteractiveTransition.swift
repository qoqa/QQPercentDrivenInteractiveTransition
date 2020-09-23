//
//  QQPercentDrivenInteractiveTransition.swift
//  QoQa
//
//  Created by Alexandre on 23.09.20.
//  Copyright © 2020 QoQa Services SA. All rights reserved.
//

import UIKit

open class QQPercentDrivenInteractiveTransition: NSObject {

    // MARK: - Init
    public required init(animator: UIViewControllerAnimatedTransitioning) {
        self.animator = animator
    }

    // MARK: - Setters and getters
    public let animator: UIViewControllerAnimatedTransitioning
    public var completionSpeed: CGFloat = 1.0
    public var duration: TimeInterval {
        return self.animator.transitionDuration(using: self.transitionContext)
    }
    public fileprivate(set) var percentComplete: CGFloat = 0.0

    // MARK: - Private Helpers
    fileprivate weak var transitionContext: UIViewControllerContextTransitioning?

    fileprivate var animationDisplayLink: CADisplayLink? = nil {
        willSet {
            guard self.animationDisplayLink != newValue else {
                return
            }

            self.animationDisplayLink?.invalidate()
        }
    }

    // MARK: - Finalization
    deinit {
        self.animationDisplayLink = nil
    }
}

// MARK: - Managing the Interactive Transition
extension QQPercentDrivenInteractiveTransition: UIViewControllerInteractiveTransitioning {

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        guard self.transitionContext == nil else {
            return
        }

        self.transitionContext = transitionContext

        self.transitionContainerLayer?.speed = 0.0

        self.animator.animateTransition(using: transitionContext)
    }

    open func update(_ percentComplete: CGFloat) {

        self.percentComplete = min(1.0, max(0.0, percentComplete))

        self.transitionContainerLayer?.timeOffset = TimeInterval(self.percentComplete) * self.duration

        self.transitionContext?.updateInteractiveTransition(self.percentComplete)
    }

    open func cancel() {
        self.transitionContext?.cancelInteractiveTransition()
        self.completeTransition()
    }

    open func finish() {
        self.transitionContext?.finishInteractiveTransition()
        self.completeTransition()
    }
}

// MARK: - Managing Animator Progressive Transition
extension QQPercentDrivenInteractiveTransition {

    fileprivate var transitionContainerLayer: CALayer? {
        return self.transitionContext?.containerView.layer
    }

    fileprivate func completeTransition() {

        guard self.animationDisplayLink == nil else {
            return
        }

        self.animationDisplayLink = CADisplayLink(target: self, selector: #selector(completeTransitionUpdate))
        self.animationDisplayLink?.add(to: .main, forMode: .common)
    }

    @objc fileprivate func completeTransitionUpdate(sender: CADisplayLink) {

        guard let transitionContext = self.transitionContext, let layer = self.transitionContainerLayer else {
            return
        }

        var deltaTimeOffset = sender.duration * TimeInterval(self.completionSpeed)
        deltaTimeOffset *= transitionContext.transitionWasCancelled ? -1.0 : 1.0
        let timeOffset = layer.timeOffset + deltaTimeOffset

        if timeOffset < 0.0 || timeOffset > self.duration {
            self.completeTransitionDidFinish()
        } else {
            layer.timeOffset = timeOffset
        }
    }

    private func completeTransitionDidFinish() {

        self.animationDisplayLink = nil

        guard let transitionContext = self.transitionContext, let layer = self.transitionContainerLayer else {
            return
        }

        layer.speed = 1.0

        if !transitionContext.transitionWasCancelled {
            let pausedTime = layer.timeOffset
            layer.timeOffset = 0.0
            layer.beginTime = 0.0  // Need to reset to zero to avoid flickering
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }

        self.transitionContext = nil
    }
}
