//
//  GameViewController.swift
//  DungeonCrawler
//
//  Created by Mooseker, William Parker on 12/2/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.
////

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var level: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView?{
            if let scene = SKScene(fileNamed: level ?? "GameScene"){
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        
//        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
//        // including entities and graphs.
//        if let scene = GKScene(fileNamed: level ?? "GameScene") {
//
//            if(level == "GameScene" || level == nil){
//                // Get the SKScene from the loaded GKScene
//                if let sceneNode = scene.rootNode as! GameScene? {
//
//                    // Copy gameplay related content over to the scene
//                    //sceneNode.entities = scene.entities
//                    //sceneNode.graphs = scene.graphs
//
//                    // Set the scale mode to scale to fit the window
//                    sceneNode.scaleMode = .aspectFill
//
//                    // Present the scene
//                    if let view = self.view as! SKView? {
//                        view.presentScene(sceneNode)
//
//                        view.ignoresSiblingOrder = true
//                    }
//                }
//            } else if (level == "GameScene2"){
//                if let sceneNode = scene.rootNode as! GameScene2? {
//
//                    // Copy gameplay related content over to the scene
//                    //sceneNode.entities = scene.entities
//                    //sceneNode.graphs = scene.graphs
//
//                    // Set the scale mode to scale to fit the window
//                    sceneNode.scaleMode = .aspectFill
//
//                    // Present the scene
//                    if let view = self.view as! SKView? {
//                        view.presentScene(sceneNode)
//
//                        view.ignoresSiblingOrder = true
//                    }
//                }
//            } else if (level == "GameScene3") {
//                if let sceneNode = scene.rootNode as! GameScene3? {
//
//                    // Copy gameplay related content over to the scene
//                    //sceneNode.entities = scene.entities
//                    //sceneNode.graphs = scene.graphs
//
//                    // Set the scale mode to scale to fit the window
//                    sceneNode.scaleMode = .aspectFill
//
//                    // Present the scene
//                    if let view = self.view as! SKView? {
//                        view.presentScene(sceneNode)
//
//                        view.ignoresSiblingOrder = true
//                    }
//                }
//            }
//        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
