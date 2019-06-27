//
//  GameScene.swift
//  StoreMe
//
//  Created by Shirui Z on 6/27/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode()
    
    //    var livesNum = 0
    //    let livesLabel = SKLabelNode()
    
    var gameTimer: Timer!
    
    let player = SKSpriteNode(imageNamed: "compost")
    
    struct physicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Trash : UInt32 = 0b10 //2
        static let BadTrash: UInt32 = 0b100 //4
        
    }
    
    func rand () -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func rand(min:CGFloat, max: CGFloat) -> CGFloat{
        return   CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    var gameArea = CGRect()
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        super.init(coder:aDecoder)
    }
    
    
    
    
    
    var possibleTrash = ["Banana", "cheese", "apple_core", "fish"]
    var trashCategory:UInt32 = 0x1 << 1
    var binCategory:UInt32 = 0x1 << 0
    
    
    
    
    
    
    
    override func didMove(to view: SKView){
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = -1
        self.addChild(background)
        
        player.setScale(0.75)
        player.position = (CGPoint(x: self.size.width/2, y: self.size.height * 0.2))
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.contactTestBitMask = physicsCategories.Trash
        player.physicsBody!.contactTestBitMask = physicsCategories.BadTrash
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.2, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        //        livesLabel.text = "Live: 3"
        //        livesLabel.fontSize = 70
        //        livesLabel.fontColor = SKColor.white
        //        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        //        livesLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height*0.9)
        //        livesLabel.zPosition = 100
        //        self.addChild(livesLabel)
        
        //        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addTrash), userInfo: nil, repeats: true)
        
        
    }
    
    func loseALife(){
        //        livesNum -= 1
        //        livesLabel.text = "Lives: \(livesNum)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        //        livesLabel.run(scaleSequence)
    }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
    }
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.inGame
    
    func runGameOver(){
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Trash"){
            trash, stop in
            
            trash.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Bad Trash"){
            badTrash, stop in
            badTrash.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        
    }
    
    func changeScene() {
        
        let sceneToMoveTo = gameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTranstion = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTranstion)
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
            
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Trash{
            //if the player has hit the trash
            
            body2.node?.removeFromParent()
            addScore()
            
        }
        
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.BadTrash
        {
            //if player hits not compostable trash
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            runGameOver()
            
        }
        
    }
    
    
    
    //    @objc func addTrash () {
    //        let banana = possibleTrash[0]
    //        let cheese = possibleTrash[1]
    //        let apple_core = possibleTrash[2]
    //        let fish = possibleTrash[3]
    //
    //        possibleTrash = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleTrash) as! [String]
    //        let newTrash = SKSpriteNode(imageNamed: possibleTrash[0])
    //        let randTrashPos = GKRandomDistribution(lowestValue: 0, highestValue: 414)
    //        if newTrash.isEqual(apple_core)
    //        {
    //            newTrash.setScale(0.001)
    //        }
    //
    //        if newTrash.isEqual(banana)
    //        {
    //            newTrash.setScale(0.1)
    //        }
    //
    //        if newTrash.isEqual(fish)
    //        {
    //            newTrash.setScale(0.01)
    //        }
    //
    //        if newTrash.isEqual(cheese)
    //        {
    //            newTrash.setScale(0.1)
    //        }
    //        let pos = CGFloat(randTrashPos.nextInt())
    //        newTrash.position = CGPoint(x: pos, y: self.frame.size.height + newTrash.size.height)
    //
    //
    //        newTrash.physicsBody = SKPhysicsBody(rectangleOf: newTrash.size)
    //        newTrash.physicsBody?.isDynamic = true
    //
    //        newTrash.physicsBody?.categoryBitMask = trashCategory
    //        newTrash.physicsBody?.contactTestBitMask = binCategory
    //        newTrash.physicsBody?.collisionBitMask  = 0
    //
    //        self.addChild(newTrash)
    //
    //    let animationDuration: TimeInterval = 9
    //
    //        var actionArray = [SKAction]()
    //
    //        actionArray.append(SKAction.move(to: CGPoint(x: pos, y: -newTrash.size.height), duration: TimeInterval(animationDuration)))
    //        actionArray.append(SKAction.removeFromParent())
    //
    //        newTrash.run(SKAction.sequence(actionArray))
    //    }
    
    
    
    func spawnTrash()
    {
        let randXStart = rand(min:gameArea.minX, max:gameArea.maxX )
        let randXEnd = rand(min: gameArea.minX, max: gameArea.maxX )
        let startPoint = CGPoint(x: randXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randXEnd, y: -self.size.height * 0.2)
        
        
        let trash = SKSpriteNode(imageNamed: "Banana")
        trash.name = "Trash"
        trash.setScale(0.5)
        trash.position = startPoint
        trash.zPosition = 2
        trash.physicsBody = SKPhysicsBody(rectangleOf: trash.size)
        trash.physicsBody!.affectedByGravity = false
        trash.physicsBody!.categoryBitMask = physicsCategories.Trash
        trash.physicsBody!.collisionBitMask = physicsCategories.None
        trash.physicsBody!.contactTestBitMask = physicsCategories.Player
        self.addChild(trash)
        
        //        let trash1 = SKSpriteNode(imageNamed: "apple_core")
        //        trash1.setScale(0.05)
        //        trash1.position = startPoint
        //        trash1.zPosition = 2
        //        self.addChild(trash1)
        //
        //        let trash2 = SKSpriteNode(imageNamed: "cheese")
        //        trash2.setScale(0.1)
        //        trash2.position = startPoint
        //        trash2.zPosition = 2
        //        self.addChild(trash2)
        //
        //        let trash3 = SKSpriteNode(imageNamed: "fish")
        //        trash3.setScale(0.3)
        //        trash3.position = startPoint
        //        trash3.zPosition = 2
        //        self.addChild(trash3)
        
        
        let moveTrash =  SKAction.move(to: endPoint, duration: 5)
        //        let moveTrash1 =  SKAction.move(to: endPoint, duration: 4)
        //        let moveTrash2 =  SKAction.move(to: endPoint, duration: 2)
        //        let moveTrash3 =  SKAction.move(to: endPoint, duration: 5)
        let deleteTrash = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let trashSequence = SKAction.sequence([moveTrash, deleteTrash, loseALifeAction])
        
        //        let trashSequence1 = SKAction.sequence([moveTrash1, deleteTrash])
        //        let trashSequence2 = SKAction.sequence([moveTrash2, deleteTrash])
        //        let trashSequence3 = SKAction.sequence([moveTrash3, deleteTrash])
        if currentGameState == gameState.inGame{
            trash.run(trashSequence)
        }
        //        trash1.run(trashSequence1)
        //        trash2.run(trashSequence2)
        //        trash3.run(trashSequence3)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amtToRotate = atan2(dy,dx)
        trash.zRotation = amtToRotate
        //        trash1.zRotation = amtToRotate
        //        trash2.zRotation = amtToRotate
        //        trash3.zRotation = amtToRotate
        
    }
    
    func addBadTrash(){
        
        let randXStart = rand(min:gameArea.minX, max:gameArea.maxX )
        let randXEnd = rand(min: gameArea.minX, max: gameArea.maxX )
        let startPoint = CGPoint(x: randXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randXEnd, y: -self.size.height * 0.2)
        
        let trash2 = SKSpriteNode(imageNamed: "cheese")
        trash2.name = "Bad Trash"
        trash2.setScale(0.1)
        trash2.position = startPoint
        trash2.zPosition = 2
        trash2.physicsBody = SKPhysicsBody(rectangleOf: trash2.size)
        trash2.physicsBody!.affectedByGravity = false
        trash2.physicsBody!.categoryBitMask = physicsCategories.BadTrash
        trash2.physicsBody!.collisionBitMask = physicsCategories.None
        trash2.physicsBody!.contactTestBitMask = physicsCategories.Player
        
        self.addChild(trash2)
        //
        //        let trash3 = SKSpriteNode(imageNamed: "fish")
        //        trash3.setScale(0.3)
        //        trash3.position = startPoint
        //        trash3.zPosition = 2
        //        self.addChild(trash3)
        
        let moveTrash2 =  SKAction.move(to: endPoint, duration: 3)
        let deleteTrash = SKAction.removeFromParent()
        let trashSequence2 = SKAction.sequence([moveTrash2, deleteTrash])
        trash2.run(trashSequence2)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amtToRotate = atan2(dy,dx)
        
        trash2.zRotation = amtToRotate
        
    }
    
    
    func startNewLevel(){
        let spawn = SKAction.run(spawnTrash)
        let spawn1 = SKAction.run(addBadTrash)
        let waitToSpawn = SKAction.wait(forDuration: 3)
        let waitToSpawn1 = SKAction.wait(forDuration: 4)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnSequence1 = SKAction.sequence([waitToSpawn1, spawn1])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        let spawnForever1 = SKAction.repeatForever(spawnSequence1)
        self.run(spawnForever)
        self.run(spawnForever1)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        if currentGameState == gameState.inGame{
            spawnTrash()
            addBadTrash()
            startNewLevel()
            loseALife()
        }
        //addTrash()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
                
                if player.position.x > gameArea.maxX - player.size.width/2
                {
                    player.position.x = gameArea.maxX - player.size.width/2
                }
                
                if player.position.x < gameArea.minX + player.size.width/2
                {
                    player.position.x = gameArea.minX + player.size.width/2
                }
            }
        }
        
        
        
    }
    
    
    
    //    var entities = [GKEntity]()
    //    var graphs = [String : GKGraph]()
    //
    //    private var lastUpdateTime : TimeInterval = 0
    //    private var label : SKLabelNode?
    //    private var spinnyNode : SKShapeNode?
    //
    //    override func sceneDidLoad() {
    //
    //        self.lastUpdateTime = 0
    //
    //        // Get label node from scene and store it for use later
    //        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
    //        if let label = self.label {
    //            label.alpha = 0.0
    //            label.run(SKAction.fadeIn(withDuration: 2.0))
    //        }
    //
    //        // Create shape node to use during mouse interaction
    //        let w = (self.size.width + self.size.height) * 0.05
    //        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
    //
    //        if let spinnyNode = self.spinnyNode {
    //            spinnyNode.lineWidth = 2.5
    //
    //            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    //            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
    //                                              SKAction.fadeOut(withDuration: 0.5),
    //                                              SKAction.removeFromParent()]))
    //        }
    //    }
    //
    //
    //    func touchDown(atPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.green
    //            self.addChild(n)
    //        }
    //    }
    //
    //    func touchMoved(toPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.blue
    //            self.addChild(n)
    //        }
    //    }
    //
    //    func touchUp(atPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.red
    //            self.addChild(n)
    //        }
    //    }
    //
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if let label = self.label {
    //            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    //        }
    //
    //        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //    }
    //
    //
    //    override func update(_ currentTime: TimeInterval) {
    //        // Called before each frame is rendered
    //
    //        // Initialize _lastUpdateTime if it has not already been
    //        if (self.lastUpdateTime == 0) {
    //            self.lastUpdateTime = currentTime
    //        }
    //
    //        // Calculate time since last update
    //        let dt = currentTime - self.lastUpdateTime
    //
    //        // Update entities
    //        for entity in self.entities {
    //            entity.update(deltaTime: dt)
    //        }
    //
    //        self.lastUpdateTime = currentTime
    //    }
    
}
