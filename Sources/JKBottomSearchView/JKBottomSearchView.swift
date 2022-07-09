//
//  JKBottomSearchView.swift
//  JKBottomSearchView
//
//  Created by Jarosław Krajewski on 06/04/2018.
//  Copyright © 2018 com.jerronimo. All rights reserved.
//

import UIKit

public enum JKBottomSearchViewExpandingState{
    case fullyExpanded
    case middle
    case fullyCollapsed
}

public class JKBottomSearchView: UIView{

    public var blurEffect: UIBlurEffect?{
        didSet{blurView.effect = blurEffect}
    }
    public var contentView:UIView{
        return blurView.contentView
    }
    public var fastExpandingTime:Double = 0.25
    public var slowExpandingTime:Double = 1
    public var minimalYPosition:CGFloat 

    private let paddingFromTop:CGFloat = 8
    private let maximalYPosition:CGFloat
    private let blurView:UIVisualEffectView! = UIVisualEffectView(effect:nil)
    private var currentExpandedState: JKBottomSearchViewExpandingState = .fullyCollapsed
    private var startedDraggingOnSearchBar = false

    public init(){
        let windowFrame = UIWindow().frame
        let visibleHeight:CGFloat = 56 + paddingFromTop
        let frame = CGRect(
            x: 0,
            y: windowFrame.height - visibleHeight,
            width: windowFrame.width,
            height: windowFrame.height * CGFloat(0.8))
        self.minimalYPosition = windowFrame.height - frame.height
        self.maximalYPosition = frame.origin.y
        super.init(frame: frame)

        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        minimalYPosition = 0
        maximalYPosition = UIWindow().frame.height - 56 - 8
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView(){

        let dragIndicationView = UIView(frame: .zero)
        dragIndicationView.backgroundColor = .lightGray
        dragIndicationView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(dragIndicationView)
        dragIndicationView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor).isActive = true
        dragIndicationView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 2).isActive = true
        dragIndicationView.widthAnchor.constraint(equalToConstant: UIWindow().frame.width / 15).isActive = true
        dragIndicationView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        dragIndicationView.layer.cornerRadius = 1

        blurView.effect = blurEffect
        blurView.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                size: self.frame.size)
        blurView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        addSubview(blurView)

        let dragGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                           action: #selector(userDidPan))
        dragGestureRecognizer.delegate = self
        blurView.contentView.addGestureRecognizer(dragGestureRecognizer)
    }

    @objc
    private func userDidPan(_ sender: UIPanGestureRecognizer){
        let senderView = sender.view
        let loc = sender.location(in: senderView)
        let tappedView = senderView?.hitTest(loc, with: nil)


        if sender.state == .began{
            var viewToCheck:UIView? = tappedView
            while viewToCheck != nil {
                if viewToCheck is UISearchBar{
                    startedDraggingOnSearchBar = true
                    break
                }
                viewToCheck = viewToCheck?.superview
            }
        }

        if sender.state == .ended{
            startedDraggingOnSearchBar = false
            let currentYPosition = frame.origin.y
            let toTopDistance = abs(Int32(currentYPosition - minimalYPosition))
            let toBottomDistance = abs(Int32(currentYPosition  - maximalYPosition))
            let toCenterDistance = abs(Int32(currentYPosition - (minimalYPosition + maximalYPosition) / 2))
            let sortedDistances = [toTopDistance,toBottomDistance,toCenterDistance].sorted()
            if sortedDistances[0] == toTopDistance{
                toggleExpand(.fullyExpanded,fast:true)
            }else if sortedDistances[0] == toBottomDistance{
                toggleExpand(.fullyCollapsed,fast:true)
            }else{
                toggleExpand(.middle,fast:true)
            }
        }else{

            let translation = sender.translation(in: self)

            var destinationY = self.frame.origin.y + translation.y
            if destinationY < minimalYPosition {
                destinationY = minimalYPosition
            }else if destinationY > maximalYPosition {
                destinationY = maximalYPosition
            }
            self.frame.origin.y = destinationY

            sender.setTranslation(CGPoint.zero, in: self)
        }
    }

    private func animationDuration(fast:Bool) -> Double {
        if fast {
            return fastExpandingTime
        }else{
            return slowExpandingTime
        }
    }

    public func toggleExpand(_ state: JKBottomSearchViewExpandingState, fast:Bool = false){
        let duration = animationDuration(fast: fast)
        UIView.animate(withDuration: duration) {
            switch state{
            case .fullyExpanded:
                self.frame.origin.y = self.minimalYPosition
            case .middle:
                self.frame.origin.y = (self.minimalYPosition + self.maximalYPosition)/2
            case .fullyCollapsed:
                self.frame.origin.y = self.maximalYPosition
            }
        }
        self.currentExpandedState = state
    }
}

extension JKBottomSearchView: UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
