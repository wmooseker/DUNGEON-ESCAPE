//
//  GameScene.swift
//  DungeonCrawler
//
//  Created by Mooseker, William Parker on 12/2/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.
// potion Image Credit: <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// key image Credit: <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var viewController: MenuViewController!
    
    var timer: Timer? = nil
    
    var buttonIsPressed = false
    var scoreLabel = SKLabelNode(fontNamed: "Papyrus")
    var healthLabel = SKLabelNode(fontNamed: "Papyrus")
    var walls = [SKSpriteNode]()
    var potions = [SKSpriteNode]()
    var monsterHealth = [Int]()
    var monsters = [SKSpriteNode]()
    var levelKey = SKSpriteNode()
    var levelDoor = SKSpriteNode()
    var keyFound: Bool = false
    
    var scoreTotal = 0 {
        didSet {
            scoreLabel.text = ("Score: \(scoreTotal)")
        }
    }
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
    var playerFrontWalkFrames: [SKTexture] = []
    var playerBackWalkFrames: [SKTexture] = []
    var playerAttackUpFrames: [SKTexture] = []
    var playerAttackDownFrames: [SKTexture] = []
    var playerAttackRightFrames: [SKTexture] = []
    var playerAttackLeftFrames: [SKTexture] = []
    var monsterFrontWalkFrames: [SKTexture] = []
    var monsterBackWalkFrames: [SKTexture] = []
    var monsterAttackUpFrames: [SKTexture] = []
    var monsterAttackDownFrames: [SKTexture] = []
    var monsterAttackRightFrames: [SKTexture] = []
    var monsterAttackLeftFrames: [SKTexture] = []
    
    var platform = SKTileMapNode()
    var isMoveButtonPressed = false
    
    var leftButton = Button(defaultButtonImage: "leftArrow", activeButtonImage: "leftArrow", buttonAction: {
    })
    var rightButton = Button(defaultButtonImage: "rightArrow", activeButtonImage: "rightArrow", buttonAction: {
        //let moveDirection = MovementDirection.right
    })
    var upButton = Button(defaultButtonImage: "upArrow", activeButtonImage: "upArrow", buttonAction: {
        //let moveDirection = MovementDirection.up
    })
    var downButton = Button(defaultButtonImage: "downArrow", activeButtonImage: "downArrow", buttonAction: {
        //let moveDirection = MovementDirection.left
    })
    
    func loadButtonNodes() {

        upButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 72*5))
        rightButton.position = CGPoint(x: self.frame.minX + 96, y: self.frame.minY + 48*5)
        downButton.position = CGPoint(x: self.frame.minX + 48, y: (self.frame.minY + 24*5))
        leftButton.position = CGPoint(x: self.frame.minX, y: self.frame.minY + 48*5)
        
        healthLabel.fontSize = 50
        healthLabel.text = ("Health: \(playerHealth)/100")
        healthLabel.position = CGPoint(x: self.frame.midX + self.frame.maxX/4, y: self.frame.minY + 24*5)
        
        scoreLabel.fontSize = 50
        scoreLabel.text = ("Score: \(scoreTotal)")
        scoreLabel.position = CGPoint(x: self.frame.midX + self.frame.maxX/4, y: self.frame.maxY - 24*5)
        
        
        addChild(upButton)
        addChild(rightButton)
        addChild(downButton)
        addChild(leftButton)
        addChild(healthLabel)
        addChild(scoreLabel)
    }
    
    
    func loadSceneNodes() {
        print("loading scenenodes for scene 1")
        var wallCount = 1
        var monsterCount = 1
        var potionCount = 1
        
        guard let door = childNode(withName: "door") as? SKSpriteNode else {
            fatalError(" failed to load door sprite")
        }
        self.levelDoor = door
        
        guard let key = childNode(withName: "key") as? SKSpriteNode else {
            fatalError(" failed to load key sprite")
        }
        self.levelKey = key
        
        while(potionCount > 0) {
            if let potion = childNode(withName: "potion\(potionCount)") as? SKSpriteNode {
                potions.append(potion)
            } else {
                potionCount = -1
            }
            potionCount += 1
        }
        
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
        buildPlayer()
        buildMonsters()
        loadButtonNodes()
        monsterTime()
    }
    
    override func didMove(to view: SKView) {
        print("moved to scene 1")
        loadSceneNodes()
        self.camera = cam
        
    }
    
    func buildPlayer() {
        let playerFrontWalkAnimatedAtlas = SKTextureAtlas(named: "PlayerWalkingFront")
        var frontWalkFrames: [SKTexture] = []
        let numFrontImages = playerFrontWalkAnimatedAtlas.textureNames.count
        for i in 1...numFrontImages {
            let playerTextureName = "Dudefrontwalk\(i)"
            frontWalkFrames.append(playerFrontWalkAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerFrontWalkFrames = frontWalkFrames
        
        let playerBackWalkAnimatedAtlas = SKTextureAtlas(named: "PlayerWalkingBack")
        var backWalkFrames: [SKTexture] = []
        let numBackImages = playerBackWalkAnimatedAtlas.textureNames.count
        for x in 1...numBackImages {
            let playerTextureName = "DudeWalking(Back)\(x)"
            backWalkFrames.append(playerBackWalkAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerBackWalkFrames = backWalkFrames
        
        let playerUpAttackAnimatedAtlas = SKTextureAtlas(named: "PlayerAttackUp")
        var attackUpFrames: [SKTexture] = []
        let numAttackUpImages = playerUpAttackAnimatedAtlas.textureNames.count
        for y in 1...numAttackUpImages {
            let playerTextureName = "DudeBackUp\(y)"
            attackUpFrames.append(playerUpAttackAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerAttackUpFrames = attackUpFrames
        
        let playerDownAttackAnimatedAtlas = SKTextureAtlas(named: "PlayerAttackDown")
        var attackDownFrames: [SKTexture] = []
        let numAttackDownImages = playerDownAttackAnimatedAtlas.textureNames.count
        for z in 1...numAttackDownImages {
            let playerTextureName = "Dudefrontdown\(z)"
            attackDownFrames.append(playerDownAttackAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerAttackDownFrames = attackDownFrames
        
        let playerRightAttackAnimatedAtlas = SKTextureAtlas(named: "PlayerAttackRight")
        var attackRightFrames: [SKTexture] = []
        let numAttackRightImages = playerRightAttackAnimatedAtlas.textureNames.count
        for e in 1...numAttackRightImages {
            let playerTextureName = "Dudefrontright\(e)"
            attackRightFrames.append(playerRightAttackAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerAttackRightFrames = attackRightFrames
        
        let playerLeftAttackAnimatedAtlas = SKTextureAtlas(named: "PlayerAttackLeft")
        var attackLeftFrames: [SKTexture] = []
        let numAttackLeftImages = playerLeftAttackAnimatedAtlas.textureNames.count
        for s in 1...numAttackLeftImages {
            let playerTextureName = "Dudefrontleft\(s)"
            attackLeftFrames.append(playerLeftAttackAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerAttackLeftFrames = attackLeftFrames
        
        
        let firstFrontWalkFrameTexture = frontWalkFrames[0]
        playerCharacter.texture = firstFrontWalkFrameTexture
    }
    
    func animatePlayerFrontWalk() {
        playerCharacter.run(SKAction.animate(with: playerFrontWalkFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animatePlayerBackWalk() {
        playerCharacter.run(SKAction.animate(with: playerBackWalkFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    func animatePlayerAttackUp() {
        playerCharacter.run(SKAction.animate(with: playerAttackUpFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animatePlayerAttackDown() {
        playerCharacter.run(SKAction.animate(with: playerAttackDownFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animatePlayerAttackRight() {
        playerCharacter.run(SKAction.animate(with: playerAttackRightFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animatePlayerAttackLeft() {
        playerCharacter.run(SKAction.animate(with: playerAttackLeftFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func buildMonsters() {
        let monsterFrontWalkAnimatedAtlas = SKTextureAtlas(named: "MonsterWalkingFront")
        var frontWalkFrames: [SKTexture] = []
        let numFrontImages = monsterFrontWalkAnimatedAtlas.textureNames.count
        for i in 1...numFrontImages {
            let monsterTextureName = "BanditfrontWalk\(i)"
            frontWalkFrames.append(monsterFrontWalkAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterFrontWalkFrames = frontWalkFrames
        
        let monsterBackWalkAnimatedAtlas = SKTextureAtlas(named: "MonsterWalkingBack")
        var backWalkFrames: [SKTexture] = []
        let numBackImages = monsterBackWalkAnimatedAtlas.textureNames.count
        for x in 1...numBackImages {
            let monsterTextureName = "banditBackwalk\(x)"
            backWalkFrames.append(monsterBackWalkAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterBackWalkFrames = backWalkFrames
        
        let monsterUpAttackAnimatedAtlas = SKTextureAtlas(named: "MonsterAttackUp")
        var attackUpFrames: [SKTexture] = []
        let numAttackUpImages = monsterUpAttackAnimatedAtlas.textureNames.count
        for y in 1...numAttackUpImages {
            let monsterTextureName = "Banditbackup\(y)"
            attackUpFrames.append(monsterUpAttackAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterAttackUpFrames = attackUpFrames
        
        let monsterDownAttackAnimatedAtlas = SKTextureAtlas(named: "MonsterAttackDown")
        var attackDownFrames: [SKTexture] = []
        let numAttackDownImages = monsterDownAttackAnimatedAtlas.textureNames.count
        for z in 1...numAttackDownImages {
            let monsterTextureName = "Banditfrontdown\(z)"
            attackDownFrames.append(monsterDownAttackAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterAttackDownFrames = attackDownFrames
        
        let monsterRightAttackAnimatedAtlas = SKTextureAtlas(named: "MonsterAttackRight")
        var attackRightFrames: [SKTexture] = []
        let numAttackRightImages = monsterRightAttackAnimatedAtlas.textureNames.count
        for e in 1...numAttackRightImages {
            let monsterTextureName = "Banditfrontright\(e)"
            attackRightFrames.append(monsterRightAttackAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterAttackRightFrames = attackRightFrames
        
        let monsterLeftAttackAnimatedAtlas = SKTextureAtlas(named: "MonsterAttackLeft")
        var attackLeftFrames: [SKTexture] = []
        let numAttackLeftImages = monsterLeftAttackAnimatedAtlas.textureNames.count
        for s in 1...numAttackLeftImages {
            let monsterTextureName = "banditfrontleft\(s)"
            attackLeftFrames.append(monsterLeftAttackAnimatedAtlas.textureNamed(monsterTextureName))
        }
        monsterAttackLeftFrames = attackLeftFrames
        
    }
    
    func animateMonsterFrontWalk(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterFrontWalkFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animateMonsterBackWalk(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterBackWalkFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    func animateMonsterAttackUp(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterAttackUpFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animateMonsterAttackDown(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterAttackDownFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animateMonsterAttackRight(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterAttackRightFrames, timePerFrame: 0.1, resize: false, restore: true))
    }
    
    func animateMonsterAttackLeft(monster: SKSpriteNode) {
        monster.run(SKAction.animate(with: monsterAttackLeftFrames, timePerFrame: 0.1, resize: false, restore: true))
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
            if (direction == .N) {
                animateMonsterBackWalk(monster: monster)
            } else if (direction == .W) {
                animateMonsterFrontWalk(monster: monster)
            } else if (direction == .E) {
                animateMonsterFrontWalk(monster: monster)
            } else if (direction == .S) {
                animateMonsterFrontWalk(monster: monster)
            }
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
            let currentAttackDirection = attackDirection(targetPoint: playerCharacter.position, charNode: monster)
            if (currentAttackDirection == .N) {
                animateMonsterAttackUp(monster: monster)
            } else if (currentAttackDirection == .W) {
                animateMonsterAttackLeft(monster: monster)
            } else if (currentAttackDirection == .E) {
                animateMonsterAttackRight(monster: monster)
            } else if (currentAttackDirection == .S) {
                animateMonsterAttackDown(monster: monster)
            }
            self.playerHealth -= 10
            if(self.playerHealth <= 0){
                self.playerCharacter.texture = SKTexture(imageNamed: "bones")
                gameOver()
            }
 
            
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
    
    func attackDirection(targetPoint: CGPoint, charNode: SKSpriteNode) -> Direction? {
        let coordY = targetPoint.x - charNode.position.x
        let coordX = targetPoint.y - charNode.position.y
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
            if (direction == .N) {
                animatePlayerBackWalk()
            } else if (direction == .W) {
                animatePlayerFrontWalk()
            } else if (direction == .E) {
                animatePlayerFrontWalk()
            } else if (direction == .S) {
                animatePlayerFrontWalk()
            }
                
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
        let currentScoreLocation = scoreLabel.position
        
        
        let newPlayerLocation = CGPoint(x: currentPlayerLocation.x + xMove, y: currentPlayerLocation.y + yMove)
        let newUpLocation = CGPoint(x: currentUpLocation.x + xMove, y: currentUpLocation.y + yMove)
        let newLeftLocation = CGPoint(x: currentLeftLocation.x + xMove, y: currentLeftLocation.y + yMove)
        let newRightLocation = CGPoint(x: currentRightLocation.x + xMove, y: currentRightLocation.y + yMove)
        let newDownLocation = CGPoint(x: currentDownLocation.x + xMove, y: currentDownLocation.y + yMove)
        let newHealthLocation = CGPoint(x: currentHealthLocation.x + xMove, y: currentHealthLocation.y + yMove)
        let newScoreLocation = CGPoint(x: currentScoreLocation.x + xMove, y: currentScoreLocation.y + yMove)
        
        let movePlayerAction = SKAction.move(to: newPlayerLocation , duration: 0.25)
        let moveUpAction = SKAction.move(to: newUpLocation , duration: 0.25)
        let moveLeftAction = SKAction.move(to: newLeftLocation , duration: 0.25)
        let moveRightAction = SKAction.move(to: newRightLocation , duration: 0.25)
        let moveDownAction = SKAction.move(to: newDownLocation , duration: 0.25)
        let moveHealthAction = SKAction.move(to: newHealthLocation , duration: 0.25)
        let moveScoreAction = SKAction.move(to: newScoreLocation, duration: 0.25)
        
        playerCharacter.run(movePlayerAction)
        upButton.run(moveUpAction)
        leftButton.run(moveLeftAction)
        rightButton.run(moveRightAction)
        downButton.run(moveDownAction)
        healthLabel.run(moveHealthAction)
        scoreLabel.run(moveScoreAction)
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
                    
                    let currentAttackDirection = attackDirection(targetPoint: touch.location(in:self), charNode: playerCharacter)
                    
                    if (currentAttackDirection == .N) {
                        animatePlayerAttackUp()
                    } else if (currentAttackDirection == .W) {
                        animatePlayerAttackRight()
                    } else if (currentAttackDirection == .E) {
                        animatePlayerAttackLeft()
                    } else if (currentAttackDirection == .S) {
                        animatePlayerAttackDown()
                    }
                    
                    print("monster in range")
                    monsterHealth[count] -= 10
                    if(monsterHealth[count] <= 0){
                        self.scoreTotal += 10
                        monster.texture = SKTexture(imageNamed: "bones")
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
            count = 0
            for potion in potions {
                let xRange = abs((self.playerCharacter.position.x + 2000) - (potion.position.x + 2000))
                let yRange = abs((self.playerCharacter.position.y + 2000) - (potion.position.y + 2000))
                if((xRange < 250 && yRange < 250) && potion.contains(touch.location(in:self))){
                    print("potion Touched")
                    let healAmount = 100 - self.playerHealth
                    self.playerHealth += healAmount
                    self.potions.remove(at: count)
                    potion.removeFromParent()

                }
                count += 1
            }
            let xRange = abs((self.playerCharacter.position.x + 2000) - (levelKey.position.x + 2000))
            let yRange = abs((self.playerCharacter.position.y + 2000) - (levelKey.position.y + 2000))
            if((xRange < 250 && yRange < 250) && levelKey.contains(touch.location(in:self))){
                print("key found")
                self.keyFound = true
                self.levelKey.removeFromParent()
            }
            if levelDoor.contains(touch.location(in: self)) {
                if(keyFound == true){
                    let reveal = SKTransition.flipHorizontal(withDuration: 1.0)
                    let scene = SKScene(fileNamed: "GameScene2")!
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene , transition: reveal)
                } else {
                    let doorWarning = SKLabelNode(fontNamed: "Papyrus")
                    doorWarning.fontSize = 30
                    doorWarning.text = "You must find the key before opening door!"
                    doorWarning.position = levelDoor.position
                    addChild(doorWarning)
                    fadeAndRemove(node: doorWarning)
                }
            }
        }
    }
    
    func fadeAndRemove(node: SKNode) {
        let fadeOutAction = SKAction.fadeOut(withDuration: 3.0)
        let remove = SKAction.run({ node.removeFromParent }())
        let sequence = SKAction.sequence([fadeOutAction, remove])
        node.run(sequence)
    }
    func gameOver() {
        //var deathTimer: Timer? = nil
        //var seconds: Int = 0
        let deadLabel = SKLabelNode(text: "YOU DIED")
        deadLabel.fontSize = 70
        deadLabel.fontName = "Papyrus"
        deadLabel.position = CGPoint(x: playerCharacter.position.x, y: playerCharacter.position.y - 80)
        addChild(deadLabel)
        self.playerCharacter.texture = SKTexture(imageNamed: "bones")
        self.isPaused = true
//        deathTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (deathTimer) in
//            seconds += 1
//        })
        //deathTimer?.invalidate()
        self.isPaused = true
        //self.view!.window!.rootViewController?.performSegue(withIdentifier: "LoseSegue", sender: self)
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


