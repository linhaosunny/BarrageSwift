//
//  ViewController.swift
//  BarrageSwift
//
//  Created by lishengfeng on 09/25/2020.
//  Copyright (c) 2020 lishengfeng. All rights reserved.
//

import UIKit
import BarrageSwift

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    var index: Int = 0

    let renderer = BarrageRenderer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        renderer.masked = false
        renderer.isLoopDisplay = true
        
        contentView.addSubview(renderer.view)
        
        let datas = ["How to talk about sexual boundaries",
                     "Pelvic floor exercises for better sex",
                     "Understanding sex after childbirth",
                     "Tips for first time sex Kinks and fetishes",
                     "The top app-controlled sex toy brand",
                     "How to manage sexual anxiety",
                     "Non-penetrative sex",
                     "Sexual Health During Menopause",
                     "Asexuality and Sexual Fluidity",
                     "The best way to start with anal sex",
                     "How can I spice up my sex life",
                     "The best condom brands",
                     "What does bdsm stand for",
                     "The top common kinks amony women",
                     "What are the 10 role plays"]
        
        
        datas.forEach { title in
            sendSprite(title: title)
        }
        
        renderer.isAllowTouchScroll = true
        renderer.start()
    }


    @IBAction func startClick(_ sender: UIButton) {
        renderer.start()
        index = 0
    }


    @IBAction func pauseClick(_ sender: UIButton) {
        renderer.pause()
    }

    @IBAction func stopClick(_ sender: UIButton) {
        renderer.stop()
    }


    @IBAction func send1Click(_ sender: UIButton) {
//        sendSprite()
    }


    @IBAction func send2Click(_ sender: UIButton) {
//        sendSprite()
//        sendSprite()
    }


    @IBAction func send4Click(_ sender: UIButton) {
//        sendSprite()
//        sendSprite()
//        sendSprite()
//        sendSprite()
    }

    func sendSprite(title: String) {

        let walkSprite = BarrageWalkSprite { BarrageSpriteView() }
        walkSprite.viewParams["title"] = title
//        walkSprite.direction = .rightToLeft
        walkSprite.direction = .leftToRight
        walkSprite.minDistance = 20.0
        walkSprite.speed = 0.1
        walkSprite.clickAction = { params in
            let title = params["title"] as? String
            print("\(title ?? "")")
        }

        index += 1
        renderer.receive(sprite: walkSprite)
    }
}

