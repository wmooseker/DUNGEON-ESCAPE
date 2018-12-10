//
//  GameScene.swift
//  DungeonCrawler
//
//  Created by Mooseker, William Parker on 12/2/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var timer: Timer? = nil
    
    var buttonIsPressed = false
    var healthLabel = SKLabelNode(fontNamed: "Papyrus")
    var walls = [SKSpriteNode]()
    var monsterHealth = [Int]()
    var monsters = [SKSpriteNode]()
    
    var movementDirection: Direction?
    
    var playerHealth = 100 {
        didSet {
            if(playerHealth <= 0){
                healthLabel.text = ("Health: dead/100")
            } else {
                healthLabel.text = ("Health: \(playerHealth)/100")
            }
        }
    }
    
    let cam = SKCameraNode()
    var playerCharacter: SKSpriteNode!
    var platform = SKTileMapNode()
    var gridGraph = GKGridGraph()
    var isMoveButtonPressed = false
    var leftButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
    })
    var rightButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        //let moveDirection = MovementDirection.right
    })
    var upButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        //let moveDirection = MovementDirection.up
    })
    var downButton = Button(defaultButtonImage: "roman", activeButtonImage: "roman", buttonAction: {
        //let moveDirection = MovementDirection.left
    })
    
//    enum MovementDirection: Int {
//        case up = 1
//        case down = -1
//        case left = -2
//        case right = 2
//    }
    
    func loadButtonNodes() {
        upButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 72*5))
        rightButton.position = CGPoint(x: self.frame.minX + 96, y: self.frame.minY + 48*5)
        downButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 24*5))
        leftButton.position = CGPoint(x: self.frame.minX, y: self.frame.minY + 48*5)
        
        healthLabel.fontSize = 50
        healthLabel.text = ("Health: \(playerHealth)/100")
        healthLabel.position = CGPoint(x: self.frame.midX + self.frame.maxX/4, y: self.frame.minY + 24*5)
        
        addChild(upButton)
        addChild(rightButton)
        addChild(downButton)
        addChild(leftButton)
        addChild(healthLabel)
    }
    
    
    func loadSceneNodes() {
        
        var wallCount = 1
        var monsterCount = 1
        
        while(wallCount > 0){
            
            if let wall = childNode(withName: "wall\(wallCount)") as? SKSpriteNode {
                walls.append(wall)
            } else {
                wallCount = -1
            }
            wallCount += 1
        }
        
        while(monsterCount > 0){
            
            if let monster = childNode(withName: "monster\(monsterCount)") as? SKSpriteNode {
                monsters.append(monster)
                monsterHealth.append(100)
                print(monster.position)
                print("added monster")
            } else {
                monsterCount = -1
            }
            monsterCount += 1
        }
        
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
        monsterTime()
        graph.remove(obstacles)
    }
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
        self.camera = cam
        
    }
    
    
    
        
    func monsterTime(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (timer) in
            for monster in self.monsters{
                let xRange = abs((self.playerCharacter.position.x + 2000) - (monster.position.x + 2000))
                let yRange = abs((self.playerCharacter.position.y + 2000) - (monster.position.y + 2000))
                if(xRange < 640 && yRange < 640){
                    if let direction = self.monsterDirection(monster: monster){
                        self.canMonsterMove(direction: direction, monster: monster)
                    }
                }
            }
        })
    }
    
    func canMonsterMove(direction: Direction, monster: SKSpriteNode) {
        var xMove = CGFloat()
        var yMove = CGFloat()
        var canMove = true
        let currentMonsterLocation = monster.position
        var futureLocation: CGPoint
        
        if direction.amount == (0,1) {      //up
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: 128)
        } else if direction.amount == (0,-1) {      //down
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: -128)
        } else if direction.amount == (-1,0) {      //left
            xMove = CGFloat(integerLiteral: -128)
            yMove = CGFloat(integerLiteral: 0)
        } else if direction.amount == (1,0) {       //right
            xMove = CGFloat(integerLiteral: 128)
            yMove = CGFloat(integerLiteral: 0)
        }
        futureLocation = CGPoint(x: currentMonsterLocation.x + xMove, y: currentMonsterLocation.y + yMove)
        for wall in walls {
            if (wall.contains(futureLocation) || playerCharacter.contains(futureLocation)){
                canMove = false
            }
        }
        if(canMove){
            moveMonster(xMove: xMove, yMove: yMove, monster: monster)
        } else {
            monsterAttack(monster: monster)
        }
    }
    
    func moveMonster(xMove: CGFloat, yMove: CGFloat, monster: SKSpriteNode){
        let currentMonsterLocation = monster.position
        
        let newMonsterLocation = CGPoint(x: currentMonsterLocation.x + xMove, y: currentMonsterLocation.y + yMove)
        
        let moveMonsterAction = SKAction.move(to: newMonsterLocation , duration: 0.25)
        
        monster.run(moveMonsterAction)
        
    }
    
    func monsterAttack(monster: SKSpriteNode){
            let xRange = abs((self.playerCharacter.position.x + 2000) - (monster.position.x + 2000))
            let yRange = abs((self.playerCharacter.position.y + 2000) - (monster.position.y + 2000))
            if(xRange < 250 && yRange < 250){
                self.playerHealth -= 10
                if(self.playerHealth <= 0){
                    self.playerCharacter.texture = SKTexture(imageNamed: "Pine_Tree")
                    //gameOver()
                }
                //let action = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 1)
                //monster.run(action)
                
            }
    }
    
    func monsterDirection(monster: SKSpriteNode)  -> Direction? {
        let loc = playerCharacter.position
        let coordY = loc.x - monster.position.x
        let coordX = loc.y - monster.position.y
//        if (coordX < 3 && coordY < 3) { // minimum distance to be considered movement
//            return nil
//        }
        let coords = CGPoint(x: coordX, y: coordY)
        let degrees = 180 + Int(Float(Double.pi/2) - Float(180 / Double.pi) * atan2f(Float(coords.x), Float(coords.y)))
        return Direction(degrees: degrees)
    }
    
    func movePlayerInDirection(direction: Direction) {
        
        var xMove = CGFloat()
        var yMove = CGFloat()
        var canMove = true
        let currentPlayerLocation = playerCharacter.position
        var futureLocation: CGPoint
        
        if direction.amount == (0,1) {      //up
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: 128)
        } else if direction.amount == (0,-1) {      //down
            xMove = CGFloat(integerLiteral: 0)
            yMove = CGFloat(integerLiteral: -128)
        } else if direction.amount == (-1,0) {      //left
            xMove = CGFloat(integerLiteral: -128)
            yMove = CGFloat(integerLiteral: 0)
        } else if direction.amount == (1,0) {       //right
            xMove = CGFloat(integerLiteral: 128)
            yMove = CGFloat(integerLiteral: 0)
        }
        futureLocation = CGPoint(x: currentPlayerLocation.x + xMove, y: currentPlayerLocation.y + yMove)
        for wall in walls {
            if (wall.contains(futureLocation)){
                canMove = false
            }
        }
        if(canMove){
          moveStuff(xMove: xMove, yMove: yMove)
       }
    }
    
    func moveStuff(xMove: CGFloat, yMove: CGFloat) {
        
        let currentPlayerLocation = playerCharacter.position
        let currentUpLocation = upButton.position
        let currentLeftLocation = leftButton.position
        let currentRightLocation = rightButton.position
        let currentDownLocation = downButton.position
        let currentHealthLocation = healthLabel.position
        
        let newPlayerLocation = CGPoint(x: currentPlayerLocation.x + xMove, y: currentPlayerLocation.y + yMove)
        let newUpLocation = CGPoint(x: currentUpLocation.x + xMove, y: currentUpLocation.y + yMove)
        let newLeftLocation = CGPoint(x: currentLeftLocation.x + xMove, y: currentLeftLocation.y + yMove)
        let newRightLocation = CGPoint(x: currentRightLocation.x + xMove, y: currentRightLocation.y + yMove)
        let newDownLocation = CGPoint(x: currentDownLocation.x + xMove, y: currentDownLocation.y + yMove)
        let newHealthLocation = CGPoint(x: currentHealthLocation.x + xMove, y: currentHealthLocation.y + yMove)
        
        let movePlayerAction = SKAction.move(to: newPlayerLocation , duration: 0.25)
        let moveUpAction = SKAction.move(to: newUpLocation , duration: 0.25)
        let moveLeftAction = SKAction.move(to: newLeftLocation , duration: 0.25)
        let moveRightAction = SKAction.move(to: newRightLocation , duration: 0.25)
        let moveDownAction = SKAction.move(to: newDownLocation , duration: 0.25)
        let moveHealthAction = SKAction.move(to: newHealthLocation , duration: 0.25)
        
        playerCharacter.run(movePlayerAction)
        upButton.run(moveUpAction)
        leftButton.run(moveLeftAction)
        rightButton.run(moveRightAction)
        downButton.run(moveDownAction)
        healthLabel.run(moveHealthAction)
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
        
        if let touch = touches.first {
            
            if leftButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                movementDirection = .W
            } else if rightButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                movementDirection = .E
            } else if upButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                movementDirection = .N
            } else if downButton.contains(touch.location(in: self)) {
                buttonIsPressed = true
                movementDirection = .S
            } else {
                movementDirection = .X
                buttonIsPressed = false
            }
            
            var count = 0
            for monster in self.monsters{
                let xRange = abs((self.playerCharacter.position.x + 2000) - (monster.position.x + 2000))
                let yRange = abs((self.playerCharacter.position.y + 2000) - (monster.position.y + 2000))
                if((xRange < 250 && yRange < 250) && monster.contains(touch.location(in:self))){
                    print("monster in range")
                    monsterHealth[count] -= 10
                    if(monsterHealth[count] <= 0){
                        monster.texture = SKTexture(imageNamed: "Pine_Tree")
                        self.monsters.remove(at: count)
                        self.monsterHealth.remove(at: count)
                    } else if (monsterHealth[count] <= 50){
                        monster.color = UIColor.red
                    } else {
                        monster.color = UIColor.magenta
                    }
                    monster.colorBlendFactor = 1
                    //let action = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 1)
                    //monster.run(action)
                    
                }
                count += 1
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.updateTouches(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.updateTouches(touches: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endTouches()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endTouches()
    }

    func endTouches() {
        buttonIsPressed = false
    }

}

