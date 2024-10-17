//
//  BarrageWalkSprite.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import CoreGraphics

public class BarrageWalkSprite: BarrageSprite {

    public var speed: CGFloat = 0.2
    fileprivate(set) var destination: CGPoint = .zero
    
    var trackOrigin: CGPoint = .zero
    /// 轨道数量
    var trackNumber: UInt = 2
    ///该精灵在哪一条跑道，编号从0开始
    var track: UInt = 0
    ///同一跑道精灵间最小距离
    public var minDistance: CGFloat = 44

    ///跑道的高度
    public var trackHeight: CGFloat = 55

    public var direction: BarrageSprite.Direction = .rightToLeft

    ///判断新的精灵能否显示下
    override public func canShow(inBounds rect: CGRect, with sprites: [BarrageSprite], direction: Direction) -> Bool {
        let array = sprites.filter { $0 is BarrageWalkSprite }
        guard let walkSprites = array as? [BarrageWalkSprite] else { return false }
        
        //        guard walkSprites.count > 0 else { return true }
        
        //遍历每一个跑道
        for track in 0..<trackNumber {

            //找到当前跑到最后面一个精灵的位置
            var lastDistance: CGFloat = 0
            switch direction {
            case .rightToLeft:
                lastDistance = 0
            case .leftToRight:
                lastDistance = rect.size.width
            }

            for sprite in walkSprites {
                if sprite.track == track {

                    switch direction {
                    case .rightToLeft:
                        if sprite.view.frame.maxX > lastDistance {
                            lastDistance = sprite.view.frame.maxX
                        }
                    case .leftToRight:
                        if sprite.view.frame.minX < lastDistance {
                            lastDistance = sprite.view.frame.minX
                        }
                    }
                }
            }

            //判断当前跑道能否放得下,可以放下的话，直接返回true
            switch direction {
            case .rightToLeft:
                if lastDistance + minDistance < rect.size.width {
                    self.track = track  //设置精灵所在的跑道
                    return true
                }
            case .leftToRight:
                if lastDistance - minDistance > 0 {
                    self.track = track  //设置精灵所在的跑道
                    return true
                }
            }

        }
        return false
    }

    ///设置精灵初试位置
    override public func origin(inBounds rect: CGRect, with sprites: [BarrageSprite], direction: Direction) -> CGPoint {
        let trackFrom = CGFloat(track) * trackHeight
        switch self.direction {
        case .rightToLeft:
            self.origin.x = 0
            destination.x = rect.size.width
        case .leftToRight:
            self.origin.x = 0 - self.size.width
            destination.x = rect.size.width
        }

        self.origin.y = trackFrom + (trackHeight - self.size.height) / 2
        destination.y = self.origin.y

        return origin
    }

    override public func valid(time: TimeInterval, rect: CGRect) -> Bool {
        switch self.direction {
        case .rightToLeft:

            if self.view.frame.maxX > 0 {
                return true
            }
        case .leftToRight:
            if self.view.frame.minX < rect.size.width {
                return true
            }
        }


        return false
    }
    
    private func destionation() -> CGFloat {
        if origin.x > destination.x {
            return self.destination.x - self.origin.x
        }
        
        return self.origin.x - self.destination.x
    }

    override public func rect(time: TimeInterval) -> CGRect {
        let x = self.destionation()
        let duration = time - self.timestamp
        let postion = CGPoint(x: self.origin.x + CGFloat(duration) * speed * x,
                              y: self.origin.y)
        return CGRect(origin: postion, size: self.size)
    }

    override public func position(point: CGPoint) -> CGRect {

        self.updateTimePostion(point: point)
        
        let postion = CGPoint(x: self.view.frame.origin.x + point.x,
                              y: self.origin.y)
        
        return CGRect(origin: postion, size: self.size)
    }
    

    public override func spriteDistance() -> CGFloat {
        return minDistance
    }
    
    private func updateTimePostion(point: CGPoint) {
        let x = self.destionation()
        self.timestamp = self.timestamp - (point.x / speed / x)
    }
    
    override public func originFrameTimePostionFrom(sprite:BarrageSprite, direction: Direction = .rightToLeft) -> (rect: CGRect, time:CFTimeInterval) {
        let x = self.destionation()
        var time: CFTimeInterval = .zero
        var rect: CGRect = .zero
        let point: CGPoint = .init(x: minDistance, y: .zero)
        
        switch direction {
        case .rightToLeft:
            
            rect = .init(origin: .init(x: sprite.view.frame.maxX + point.x, y: sprite.origin.y), size: self.size)
            time = sprite.timestamp - ((sprite.size.width + point.x) / speed / x)
        case .leftToRight:
            rect = .init(origin: .init(x: sprite.view.frame.minX - point.x - self.size.width, y: sprite.origin.y), size: self.size)
            time = sprite.timestamp - (-(self.size.width + point.x) / speed / x)
        }
        
        return (rect, time)
    }
    
    override public func last(sprites: [BarrageSprite],
                    direction: Direction = .rightToLeft) -> BarrageSprite? {
        var last: BarrageSprite?
        guard let walks = sprites as? [BarrageWalkSprite] else {
            return last
        }
     
        let sames = walks.filter({ $0.track == self.track })
        switch direction {
        case .rightToLeft:
            var distance: CGFloat =  0
            sames.forEach { sprite in
                if sprite.view.frame.maxX > distance {
                    distance = sprite.view.frame.maxX
                    last = sprite
                }
            }

        case .leftToRight:
            var distance: CGFloat = self.size.width
            sames.forEach { sprite in
                if sprite.view.frame.minX < distance {
                    distance = sprite.view.frame.minX
                    last = sprite
                }
            }
        }
        
        return last
    }
}

extension BarrageWalkSprite {
    /// 估算精灵的剩余存活时间
    func estimateActiveTime() -> TimeInterval {
        var activeDistance: CGFloat = 0
        activeDistance = self.position.x - destination.x

        return TimeInterval(activeDistance / self.speed)
    }
}
