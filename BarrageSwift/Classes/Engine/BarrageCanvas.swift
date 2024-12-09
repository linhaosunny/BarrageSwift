
//
//  BarrageCanvas.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import UIKit

public class BarrageCanvas: UIView {
    public enum MaskType {
        case none
        case subviews
        case onlyself
        case all
    }
    /// canvas是否拦截事件
    public var masked: MaskType = .all


    var margin: UIEdgeInsets = .zero {
        didSet {
            if self.margin != oldValue {
                setNeedsLayout()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setup() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let superView = self.superview {
            let frame = superView.bounds.inset(by: self.margin)
            if frame != self.frame {
                self.frame = frame
            }
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
        layoutIfNeeded()
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        switch masked {
        case .none:
            guard let view = super.hitTest(point, with: event) else {
                for item in self.subviews {
                    let itemPoint = item.convert(point, from: self)
                    if let responder = item.hitTest(itemPoint, with: event) {
                        return responder
                    }
                }
                
                return self
            }

            return view
        case .subviews:
            return self
        case .onlyself:
            for item in self.subviews {
                let itemPoint = item.convert(point, from: self)
                if let responder = item.hitTest(itemPoint, with: event) {
                    return responder
                }
            }
            return nil
        case .all:
            return super.hitTest(point, with: event)
        }
    }

}
