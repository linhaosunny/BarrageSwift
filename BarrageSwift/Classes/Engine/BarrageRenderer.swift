//
//  BarrageRenderer.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class BarragePanState: NSObject {
    var direction: BarrageSprite.Direction = .rightToLeft
    
    var isTouchScroll: Bool = false
}

public class BarrageRenderer: NSObject {


    public var isLoopDisplay: Bool = false
    
    public var isAllowTouchScroll: Bool = false
    
    var time: TimeInterval = 0

    private var dispatcher: BarrageDispatcher?
    private(set) var canvas: BarrageCanvas
    private(set) var startTime: Date?
    private(set) var pausedTime: Date?
    private var pausedDuration: TimeInterval = 0
    
    private var _panState: BarragePanState = .init()

    public var view: BarrageCanvas {
        return self.canvas
    }

    private lazy var clock: BarrageClock = {
         let clock = BarrageClock(block: { [weak self] (time) in
             self?.time = time
             self?.update()
         })
         return clock
     }()

    public override init() {
        self.canvas = BarrageCanvas()
    }



    public func start() {
        canvas.setNeedsLayout()
        if startTime == nil {
            startTime = Date()
            dispatcher = BarrageDispatcher()
            dispatcher?.set(delegate: self)
        }
        else if let time = pausedTime {
            self.pausedDuration += Date().timeIntervalSince(time)
        }
        dispatcher?.isLoopDisplay = isLoopDisplay
        pausedTime = nil
        clock.start()

        
        guard isAllowTouchScroll else {
            return
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        self.canvas.addGestureRecognizer(pan)
    }

    public func pause() {
        // 没有运行, 则暂停无效
        if startTime == nil {
            return
        }

        //正在暂停
        if let time = pausedTime {
            pausedDuration += Date().timeIntervalSince(time)
        }
        else {// 当前没有暂停
            clock.pause()
            pausedTime = Date()
        }
    }

    public func stop() {
        startTime = nil
        clock.stop()
        pausedDuration = 0
    }

    private func update() {
        guard let dispatcher = dispatcher, !_panState.isTouchScroll else { return }
        dispatcher.dispatch()

        for sprite in dispatcher.activeSprites {
            sprite.update(time: time, rect: self.canvas.bounds)
        }
    }


    public func receive(sprite: BarrageSprite) {
        DispatchQueue.main.async {
            // 如果没有启动,则抛弃接收弹幕
            if self.startTime == nil {
                return
            }
            self.dispatcher?.add(sprite: sprite)
        }
    }


    ///获取当前暂停时长
    public func getPausedDuration() -> TimeInterval {
        if let time = pausedTime {
            return Date().timeIntervalSince(time) + pausedDuration
        }
        return 0
    }

    /// 获取当前时间
    public var currentTime: TimeInterval {
        guard let start = startTime else { return 0}
        let currentTime = Date().timeIntervalSince(start) - pausedDuration
        return currentTime
    }


    public var canvasMargin: UIEdgeInsets {
        set {
            canvas.margin = newValue
        }
        get {
            return canvas.margin
        }
    }
    public var masked: Bool {
        set {
            canvas.masked = newValue
        }
        get {
            return canvas.masked
        }
    }
    public var speed: CGFloat {
        set {
            clock.set(speed: newValue)
        }
        get {
            return clock.speed
        }
    }
}

extension BarrageRenderer {
    @objc fileprivate func panAction(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            pause()
            _panState.isTouchScroll = true
        case .changed:
            let point = pan.translation(in: pan.view)
            
            _panState.direction = point.x < 0 ? .rightToLeft : .leftToRight
            
            updatePosition(point: point)
            pan.setTranslation(CGPoint.zero, in: pan.view)
        case .ended, .cancelled:
            start()
            _panState.isTouchScroll = false
        default:
            break
        }
    }
    
    private func updatePosition(point: CGPoint) {
        guard let dispatcher = dispatcher else { return }
        
        for sprite in dispatcher.activeSprites {
            sprite.position(point: point, rect: self.canvas.bounds)
        }
        
        dispatcher.dispatch(direction: true)
    }
}


extension BarrageRenderer: BarrageDispatcherDelegate {
    private func getDirection(sprite: BarrageWalkSprite) -> BarrageSprite.Direction {
        return _panState.isTouchScroll ? _panState.direction : sprite.direction
    }

    func shouldActive(sprite: BarrageSprite) -> Bool {
        guard let dispatcher = dispatcher, let sprite = sprite as? BarrageWalkSprite else { return false }
        
        if !_panState.isTouchScroll {
            //暂停状态
            if pausedTime != nil {
                return false
            }
        }
        
        let canShow = sprite.canShow(inBounds: canvas.bounds, with: dispatcher.activeSprites, direction: getDirection(sprite: sprite))
        return canShow
    }
    
    func time(for dispatcher: BarrageDispatcher) -> TimeInterval {
        return self.currentTime
    }

    func willActive(sprite: BarrageSprite) {
        guard let dispatcher = dispatcher, let sprite = sprite as? BarrageWalkSprite else { return }
        sprite.active(sprites: dispatcher.activeSprites, timestamp: self.time, rect: canvas.bounds, direction: getDirection(sprite: sprite))
        canvas.addSubview(sprite.view)
    }

    func willDeactive(sprite: BarrageSprite) {
        sprite.view.removeFromSuperview()
        sprite.deactive()
    }
}
