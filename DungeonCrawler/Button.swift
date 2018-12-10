//
//  Button.swift
//  DungeonCrawler
//
//  Created by Mooseker, William Parker on 12/4/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode {
    var defaultButtonSprite = SKSpriteNode()
    var activeButtonSprite = SKSpriteNode()
    var action: () -> Void
    
    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: @escaping () -> Void) {
        defaultButtonSprite = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButtonSprite = SKSpriteNode(imageNamed: activeButtonImage)
        action = buttonAction
        super.init()
        //isUserInteractionEnabled = true
        addChild(defaultButtonSprite)
    }
   //
//   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
//    override func update() {
//        if leftButtonIsPressed == true {
//            let moveDirection = Direction.left
//            movePlayerInDirection(direction: moveDirection)
//        }
//        if rightButtonIsPressed == true {
//            let moveDirection = Direction.right
//            movePlayerInDirection(direction: moveDirection)
//        }
//        if upButtonIsPressed == true {
//            let moveDirection = Direction.up
//            movePlayerInDirection(direction: moveDirection)
//        }
//        if downButtonIsPressed == true {
//            let moveDirection = Direction.down
//            movePlayerInDirection(direction: moveDirection)
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
