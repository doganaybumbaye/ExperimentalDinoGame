//
//  GameScene.swift
//  DinoGame
//
//  Created by Doğanay Şahin on 15.08.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    enum ColliderType : UInt32{
        case Ground =  1
        case Cactus =  2
        case Dino =  4
    }
    var bigEnemies = ["pixil-frame-0-4","pixil-frame-0-5","pixil-frame-0-7","pixil-frame-0-8","pixil-frame-0-9"]
    var level3 = false
    var Cactus = SKNode()
    var big_cactus = SKSpriteNode()
    var ground = SKSpriteNode()
    var dino = SKSpriteNode()
    var moveAndRemove = SKAction()
    var backgroundMove = SKAction()
    var gameStarted = Bool()
    var random = Int()
    var died = false
    var onGround = true
    var moveFactor:CGFloat = 0.5
    var score = 0
    var highScore = 0
    var scoreLabel = SKLabelNode(fontNamed: "Press Start 2P")
    var timer = Timer()
    var highScoreLabel = SKLabelNode(fontNamed: "Press Start 2P")
    var tapToLabel = SKLabelNode(fontNamed: "Press Start 2P")
    var startLabel = SKLabelNode(fontNamed: "Press Start 2P")
    var gameOverLabel = SKLabelNode(fontNamed: "Press Start 2P")
    var resButton = SKLabelNode(fontNamed: "Press Start 2P")
    var newHighScoreText = SKLabelNode(fontNamed: "Press Start 2P")
    var newHighScoreValue = SKLabelNode(fontNamed: "Press Start 2P")
    override func didMove(to view: SKView) {
        
        createScene()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(increaseScore), userInfo: nil, repeats: true)
    }
    
    func createDino()  {
            dino = SKSpriteNode(imageNamed: "dino1")
            let atlas = SKTextureAtlas(named: "DinoAnim")
            let m1 = atlas.textureNamed("din0_2.png")
            let m2 = atlas.textureNamed("dino_1.png")
            let textures = [m1, m2]
            let meleeAnimation = SKAction.animate(with: textures, timePerFrame: 0.008)
            
            dino.run(SKAction.repeatForever(meleeAnimation))
            dino.size = CGSize(width: 80, height: 90)
            
            dino.position = CGPoint(x: 100, y: self.frame.height / 2 + 40)
            dino.physicsBody = SKPhysicsBody(circleOfRadius: dino.frame.height/2)
            dino.physicsBody?.categoryBitMask = ColliderType.Dino.rawValue
            dino.physicsBody?.collisionBitMask = ColliderType.Ground.rawValue | ColliderType.Cactus.rawValue
            dino.physicsBody?.contactTestBitMask = ColliderType.Ground.rawValue | ColliderType.Cactus.rawValue
            dino.physicsBody?.affectedByGravity = true
            dino.physicsBody?.allowsRotation = false
            dino.physicsBody?.isDynamic = true
            dino.zPosition = 5
            self.addChild(dino)
    }
    @objc func increaseScore(){
        if gameStarted == true{
            if died == false{
                score += 1
                scoreLabel.text = String(score)

            }
        }
    }
    func createBigCactus(){
        Cactus = SKSpriteNode()
        Cactus.name = "Cactuses"
        
        if score > 750 && level3 != true{
            bigEnemies.append("pixil-frame-0-6")
        }
        let randomBig = bigEnemies[Int(arc4random_uniform(UInt32(bigEnemies.count)))]

        big_cactus = SKSpriteNode(imageNamed: randomBig)
        big_cactus.physicsBody = SKPhysicsBody(rectangleOf: big_cactus.size)
        big_cactus.physicsBody?.categoryBitMask = ColliderType.Cactus.rawValue
        big_cactus.physicsBody?.collisionBitMask = ColliderType.Dino.rawValue
        big_cactus.physicsBody?.contactTestBitMask = ColliderType.Dino.rawValue
        big_cactus.physicsBody?.isDynamic = false
        big_cactus.physicsBody?.affectedByGravity = false
        big_cactus.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + 50)
        
        Cactus.addChild(big_cactus)
        Cactus.zPosition = 5
        self.addChild(Cactus)
        Cactus.run(moveAndRemove)
        
    }
    func restartGame(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        score = 0
        gameStarted = false
        tapToLabel.isHidden = false
        startLabel.isHidden = false
        level3 = false
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted = true
            Cactus.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                () in
                
                self.createBigCactus()
                
                
            })
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            let distance = CGFloat(self.frame.width + Cactus.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 100, y: 0, duration: TimeInterval(0.003 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            removeDoubleJump()
        }else {
            if died ==  true{
            }else{
                removeDoubleJump()
            }
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            if died == true{
                if resButton.contains(location){
                    restartGame()
                }
            }
        }

        
    }
    func removeDoubleJump(){
        if self.onGround == true{
            self.jump()
            self.onGround = false
        }else{
            
        }
    }
    func jump(){
        if level3 != true{
            dino.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            dino.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        }else{
            dino.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            dino.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
            big_cactus.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            big_cactus.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
        }

        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.collisionBitMask == ColliderType.Dino.rawValue || contact.bodyB.collisionBitMask == ColliderType.Dino.rawValue{
            self.onGround = true

            
        }
        
        if contact.bodyA.categoryBitMask == ColliderType.Ground.rawValue && contact.bodyB.categoryBitMask == ColliderType.Cactus.rawValue || contact.bodyA.categoryBitMask == ColliderType.Cactus.rawValue && contact.bodyB.categoryBitMask == ColliderType.Ground.rawValue {
            print("cactus touch")
            
        }
        if contact.bodyA.categoryBitMask == ColliderType.Dino.rawValue && contact.bodyB.categoryBitMask == ColliderType.Cactus.rawValue || contact.bodyA.categoryBitMask == ColliderType.Cactus.rawValue && contact.bodyB.categoryBitMask == ColliderType.Dino.rawValue{
           
            enumerateChildNodes(withName: "Cactuses", using:({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                gameOverText()
                highScoreSave()
                
            }
            
        }
        
        func gameOverText(){
            gameOverLabel.fontSize = 40
            gameOverLabel.text = "G A M E O V E R"
            gameOverLabel.fontColor = .darkGray
            gameOverLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 200)
            gameOverLabel.zPosition = 2
            gameOverLabel.run(SKAction.scale(to: 1.0, duration: 0.3))
            restartButton()
            self.addChild(gameOverLabel)
        }
        

        func restartButton(){
            resButton.fontSize = 30
            resButton.text = "R E S T A R T ?"
            resButton.fontColor = .darkGray
            resButton.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 - 200)
            resButton.zPosition = 2

            self.addChild(resButton)
        }
        

    }
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        createDino()
        scoretext()
        highScoreText()
        tapToStartText()
        for i in 0..<4 {
            let background = SKSpriteNode(imageNamed: "ground3b")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0 + background.frame.height / 2 + self.frame.height / 2)
            background.name = "ground3b"
            background.setScale(1.0)
            background.physicsBody = SKPhysicsBody(rectangleOf: background.size)
            background.physicsBody?.categoryBitMask = ColliderType.Ground.rawValue
            background.physicsBody?.collisionBitMask = ColliderType.Dino.rawValue
            background.physicsBody?.contactTestBitMask = ColliderType.Dino.rawValue
            
            
            
            background.physicsBody?.affectedByGravity = false
            background.physicsBody?.isDynamic = false
            background.zPosition = 3
            self.addChild(background)
            
        }
    }
    func scoretext(){
        scoreLabel.fontSize = 30
        scoreLabel.text = String(self.score)
        scoreLabel.fontColor = .darkGray
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3.5)
        scoreLabel.zPosition = 2
        self.addChild(scoreLabel)
    }
    
    func highScoreText(){
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = .darkGray
        highScoreLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 3.2)
        highScoreLabel.zPosition = 2
        let storedHighScore = UserDefaults.standard.object(forKey: "highScore")
        
        if storedHighScore == nil {
            highScore = 0
            highScoreLabel.text = "HI\(highScore)"
        }
        
        if let newScore = storedHighScore as? Int{
            highScore = newScore
            highScoreLabel.text = "HI\(highScore)"
        }
        self.addChild(highScoreLabel)
    }
    
    func tapToStartText(){
        tapToLabel.fontSize = 60
        tapToLabel.horizontalAlignmentMode = .center
        tapToLabel.text = "T A P  T O"
        tapToLabel.fontColor = .darkGray
        tapToLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + 100)
        tapToLabel.zPosition = 2
        startLabel.fontSize = 60
        startLabel.horizontalAlignmentMode = .center
        startLabel.text = "S T A R T"
        startLabel.fontColor = .darkGray
        startLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2  - 100)
        startLabel.zPosition = 2
        tapToLabel.run(SKAction.scale(to: 1.0, duration: 0.3))
        startLabel.run(SKAction.scale(to: 1.0, duration: 0.3))
        self.addChild(startLabel)
        self.addChild(tapToLabel)

    }
    func highScoreSave() {
        if self.score > self.highScore {
            self.highScore = self.score
            highScoreLabel.text = "HI\(String(self.highScore))"
            UserDefaults.standard.set(self.highScore, forKey: "highScore")
            showNewHighScore()
        }
    }
    
    func showNewHighScore(){
        newHighScoreText.fontSize = 20
        newHighScoreText.text = "N E W   H I G H S C O R E"
        newHighScoreText.fontColor = .darkGray
        newHighScoreText.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 - 300)
        newHighScoreText.zPosition = 2
        newHighScoreValue.fontSize = 20
        newHighScoreValue.text = "\"\(String(self.highScore))\""
        newHighScoreValue.fontColor = .darkGray
        newHighScoreValue.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 - 400)
        newHighScoreValue.zPosition = 2
        self.addChild(newHighScoreValue)
        self.addChild(newHighScoreText)
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted == true{
            if died == false{
                self.goNextLevel()
                tapToLabel.isHidden = true
                startLabel.isHidden = true
                self.action(forKey: "spawnDelayForever")?.speed += 0.0008
                moveAndRemove.speed += 0.0008
                enumerateChildNodes(withName: "ground3b", using: ({
                                (node, error) in
                let bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                                }
                            }))
        }
    }
}
    
    func LevelTwo(){
        dino.setScale(0.5)
        
        
  
    }
    func LevelThree(){
        self.level3 = true
        dino.setScale(1.0)

        Cactus.physicsBody?.collisionBitMask = ColliderType.Cactus.rawValue
        big_cactus.physicsBody?.collisionBitMask = ColliderType.Ground.rawValue
        big_cactus.physicsBody?.contactTestBitMask = ColliderType.Ground.rawValue
        big_cactus.physicsBody?.affectedByGravity = true
        big_cactus.physicsBody?.allowsRotation = false
        big_cactus.physicsBody?.isDynamic = true
        
        big_cactus.zPosition = 3
        
        print("level 3")
    }
    
    func goNextLevel(){
        if score > 1000 {
            LevelTwo()
        }
        if score > 15000 {

            LevelThree()
        }
    }
    
    
}
