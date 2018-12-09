//
//  GameScene.swift
//  DungeonCrawler
//
//  Created by Mooseker, William Parker on 12/2/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var buttonIsPressed = false
    
    var movementDirection: Direction?
    
    let cam = SKCameraNode()
    var playerCharacter: SKSpriteNode!
    var platform = SKTileMapNode()
    var gridGraph = GKGridGraph()
    var isMoveButtonPressed = false
    var leftButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
    })
    var rightButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        let moveDirection = MovementDirection.right
    })
    var upButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        let moveDirection = MovementDirection.up
    })
    var downButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        let moveDirection = MovementDirection.left
    })
    
    enum MovementDirection: Int {
        case up = 1
        case down = -1
        case left = -2
        case right = 2
    }
    
    func loadButtonNodes() {
        upButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 72*5))
        rightButton.position = CGPoint(x: self.frame.minX + 96, y: self.frame.minY + 48*5)
        downButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 24*5))
        leftButton.position = CGPoint(x: self.frame.minX, y: self.frame.minY + 48*5)
        
        addChild(upButton)
        addChild(rightButton)
        addChild(downButton)
        addChild(leftButton)
    }
    
    
    func loadSceneNodes() {
 
        
        guard let playerCharacter = childNode(withName: "playerCharacter") as? SKSpriteNode else{
            fatalError("error with loading player node")
        }
        guard let platformTileMap = childNode(withName: "platform") as? SKTileMapNode else {
            fatalError("error with loading player node")
        }
        self.platform = platformTileMap
        print("\(platform.numberOfColumns)")
        self.playerCharacter = playerCharacter
        loadButtonNodes()
        let graph = GKGridGraph(fromGridStartingAt: vector_int2(0,0), width: Int32(platform.numberOfRows) , height: Int32(platform.numberOfColumns), diagonalsAllowed: false)
        self.gridGraph = graph
        
        var obstacles = [GKGridGraphNode]()
        for column in 0..<self.platform.numberOfColumns
        {
            for row in 0..<self.platform.numberOfRows
            {
                let position = self.platform.centerOfTile(atColumn: column, row: row)
                
                guard let definition = self.platform.tileDefinition(atColumn: column, row: row) else { continue }
                guard let isObstacle: Bool = definition.userData?.value(forKey: "isObstacle") as? Bool else { continue }
                
                if isObstacle
                {
                    let wallNode = self.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row)))!
                    obstacles.append(wallNode)
                }
            }
        }
        graph.remove(obstacles)
    }
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
        self.camera = cam
        
    }
    
        
    
    
    func movePlayerInDirection(direction: Direction) {
        
        var xMove = CGFloat()
        var yMove = CGFloat()
        
        if direction.amount == (0,1) {
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: 128)
        } else if direction.amount == (0,-1) {
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: -128)
        } else if direction.amount == (-1,0) {
            xMove = CGFloat(integerLiteral: -128)
            yMove = CGFloat(integerLiteral: 0)
        } else if direction.amount == (1,0) {
            xMove = CGFloat(integerLiteral: 128)
            yMove = CGFloat(integerLiteral: 0)
        }
        moveStuff(xMove: xMove, yMove: yMove)
    }
    
    func moveStuff(xMove: CGFloat, yMove: CGFloat) {
        
        let currentPlayerLocation = playerCharacter.position
        let currentUpLocation = upButton.position
        let currentLeftLocation = leftButton.position
        let currentRightLocation = rightButton.position
        let currentDownLocation = downButton.position
        
        let newPlayerLocation = CGPoint(x: currentPlayerLocation.x + xMove, y: currentPlayerLocation.y + yMove)
        let newUpLocation = CGPoint(x: currentUpLocation.x + xMove, y: currentUpLocation.y + yMove)
        let newLeftLocation = CGPoint(x: currentLeftLocation.x + xMove, y: currentLeftLocation.y + yMove)
        let newRightLocation = CGPoint(x: currentRightLocation.x + xMove, y: currentRightLocation.y + yMove)
        let newDownLocation = CGPoint(x: currentDownLocation.x + xMove, y: currentDownLocation.y + yMove)
        
        let movePlayerAction = SKAction.move(to: newPlayerLocation , duration: 0.25)
        let moveUpAction = SKAction.move(to: newUpLocation , duration: 0.25)
        let moveLeftAction = SKAction.move(to: newLeftLocation , duration: 0.25)
        let moveRightAction = SKAction.move(to: newRightLocation , duration: 0.25)
        let moveDownAction = SKAction.move(to: newDownLocation , duration: 0.25)
        
        playerCharacter.run(movePlayerAction)
        upButton.run(moveUpAction)
        leftButton.run(moveLeftAction)
        rightButton.run(moveRightAction)
        downButton.run(moveDownAction)
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.position = playerCharacter.position
        
        if let direction = movementDirection {
            if buttonIsPressed {
                movePlayerInDirection(direction: direction)
            }
        }
        
    }
    
    func updateTouches(touches: Set<UITouch>) {
        print("testing for a direction")
        
        if let touch = touches.first {
            print("\(touch.location(in: self))")
            
            if leftButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                print("left button pressed")
                movementDirection = .W
            } else if rightButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                print("right button pressed")
                movementDirection = .E
            } else if upButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                print("up button pressed")
                movementDirection = .N
            } else if downButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                print("down button pressed")
                movementDirection = .S
            } else {
                movementDirection = .X
                buttonIsPressed = false
            }
            
        } else {print("updateTouches is weird")}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
        self.updateTouches(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches moved")
        self.updateTouches(touches: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        self.endTouches()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("how do you cancel a touch?")
        self.endTouches()
    }

    func endTouches() {
        print("no more touches")
        buttonIsPressed = false
    }

    
//    var touches = Set<UITouch>()
//    var firstTouchLocation = CGPoint(x: 0, y: 0)
//
//    var dPadDirection: Direction? {
//        if self.touches.count != 1 {
//            return nil
//        }
//        let touch = self.touches.first!
//        let loc = touch.location(in: self.view)
//        let coordX = loc.x - firstTouchLocation.x
//        let coordY = loc.y - firstTouchLocation.y
//        if (coordX < 3 && coordY < 3) { // minimum distance to be considered movement
//            return nil
//        }
//        let coords = CGPoint(x: coordX, y: coordY)
//        let degrees = 180 + Int(Float(Double.pi/2) - Float(180 / Double.pi) * atan2f(Float(coords.x), Float(coords.y)))
//        return Direction(degrees: degrees)
//    }
//
//    func updateTouches(touches: Set<UITouch>) {
//        if self.touches.count <= 0 && touches.count > 0 {
//            firstTouchLocation = touches.first!.location(in: self.view)
//        }
//        //self.touches.unionInPlace(touches: touches)
//    }
//
//    func endTouches(touches: Set<UITouch>) {
//        //self.touches.subtractInPlace(touches: touches)
//        firstTouchLocation = CGPoint(x: self.frame.midX, y: self.frame.midY)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.updateTouches(touches: touches)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.endTouches(touches: touches)
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.endTouches(touches: touches)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.updateTouches(touches: touches)
//    }
}

