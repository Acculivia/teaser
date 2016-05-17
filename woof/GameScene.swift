import SpriteKit

let playerCategory:UInt32 = 1<<0
let enemyCategory:UInt32 = 1<<1
let scoreAuraCategory:UInt32 = 1<<2

func easeScaleTo(scaleTo:CGFloat, duration:Double = 0.25) -> SKAction{
    let action = SKAction.scaleTo(scaleTo, duration: duration)
    action.timingMode = .EaseInEaseOut
    return action
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static var currentScene:GameScene?
    
    enum GameState{
        case CountIn
        case GameStart
        case StageClear
        case GameOver
    }
    
    var player:Player?
    var scoreLabel:ScoreLabel?
    var stage:Stage?
    var nextStage:Int?
    
    var positionReference:CGVector?
    var pointReference:CGPoint?
    
    var currentState:GameState = .CountIn
    
//    var totalScore = 0
    var score = 0
    
    let stageClearWaitTime:Double = 8
    
    static func getGameScene() -> GameScene{
        return currentScene!
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        GameScene.currentScene = self
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.backgroundColor = UIColor.blackColor()
        
        self.setupGame()
        
        func getExitNode() -> SKShapeNode{
            let exit = SKShapeNode(circleOfRadius: 150)
            exit.zPosition = 100
            exit.name = "exit"
            exit.fillColor = UIColor.whiteColor()
            exit.alpha = 0
            self.addChild(exit)
            exit.runAction(SKAction.sequence([
                SKAction.waitForDuration(8.0),
                SKAction.fadeAlphaTo(1.0, duration:0.25),
                SKAction.fadeAlphaTo(0.01, duration: 2.0)
                ]))
            return exit
        }
        
        getExitNode().position = CGPointMake(0, 0)
        getExitNode().position = CGPointMake(size.width, 0)
        getExitNode().position = CGPointMake(0, size.height)
        getExitNode().position = CGPointMake(size.width, size.height)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        let location:CGPoint! = touches.first?.locationInNode(self)
        
        switch currentState{
        case .CountIn, .GameStart, .StageClear:
            positionReference = CGVectorMake(player!.position.x - location.x,
                player!.position.y - location.y)
            var counter = 0
            for touch in (touches as NSSet){
                let node = nodeAtPoint(touch.locationInNode(self))
                if(node.name == "exit"){counter += 1}
            }
            if(counter >= 2){self.gameOver()}
        default:
            break
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let location:CGPoint! = touches.first?.locationInNode(self)
        
        switch currentState{
        case .CountIn, .GameStart, .StageClear:
            player!.position = CGPointMake(positionReference!.dx + location.x,
                positionReference!.dy + location.y)
            if(player!.position.x < 0){player!.position.x = 0}
            if(player!.position.y < 0){player!.position.y = 0}
            if(player!.position.x > size.width){player!.position.x = size.width}
            if(player!.position.y > size.height){player!.position.y = size.height}
        default:
            break
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch currentState{
        default:
            break
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        switch(currentState){
        case .GameStart:
            let x = player!.position.x - self.size.width / 2
            let y = player!.position.y - self.size.height / 2
            scoreLabel!.position.x = 0.3 * x + self.size.width / 2
            scoreLabel!.position.y = 0.3 * y + self.size.height / 2
            scoreLabel!.text = "\(Stage.score)"
        default:
            break
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (self.currentState == .GameStart){
            switch (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask){
            case playerCategory | enemyCategory:
                player!.hurt()
                break
            case scoreAuraCategory | enemyCategory:
                spawnSpark(contact.contactPoint)
                Stage.score += Int(sqrt(self.player!.hp))
            default:
                break
            }
        }
    }
    
    func setupGame(){
        self.scoreLabel = ScoreLabel()
        self.scoreLabel!.xScale = 0
        self.scoreLabel!.yScale = 0
        self.player = Player()
        self.positionReference = CGVectorMake(0, 0)
        self.addChild(player!)
        self.addChild(scoreLabel!)
        self.player!.position = self.pointReference!
        self.scoreLabel!.runAction(SKAction.scaleTo(1, duration: 0.5))
        self.changeStage(self.nextStage!)
    }
    
    func changeStage(id:Int){
        self.stage = Stage.getStage(id)
        Stage.setStageMusicTime()
        self.countIn(id)
    }
    
    func countIn(id:Int){
        self.currentState = .CountIn
        self.stage!.start()
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(Stage.countInTime),
            SKAction.runBlock({self.startGame()})
            ]))
    }
    
    func startGame(){
        self.currentState = .GameStart
        self.player!.start()
        self.scoreLabel!.start()
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(Stage.musicTime),
            SKAction.runBlock({self.stageClear()})
            ]))
    }
    
    func stageClear(){
        let location = self.player!.position
        self.currentState = .StageClear
        self.getGloriousRound(location, particleAmount: 50)
        self.getScore(location, color: UIColor.whiteColor(), score: Int(sqrt(self.player!.hp) * 30), duration: 3, bias: 0,
            fontSize: 100)
        self.player!.stop()
        self.stage!.die()
        self.scoreLabel!.stop()
        
        self.calculateScore(location)
        
        //save stage score.....
        Stage.score = 0
        
        self.player!.hp += 0.2
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(4.0),
            SKAction.runBlock({
            self.changeStage((Stage.id + 1) % stageAmount)
        })]))
    }
    
    func gameOver(){
        func getLabelNode(text:String) -> SKLabelNode{
            let label = SKLabelNode(text: text)
            label.fontName = "Roboto Thin"
            label.alpha = 0
            label.fontColor = UIColor.whiteColor()
            label.fontSize = 100
            label.verticalAlignmentMode = .Center
            label.zPosition = 15
            self.addChild(label)
            return label
        }
        
        let gameOver = getLabelNode("game over")
        let totalScore = getLabelNode("total score: \(self.score)")
        
        gameOver.position = CGPointMake(size.width / 2, size.height / 2 + 100)
        totalScore.position = CGPointMake(size.width / 2, size.height / 2 - 100)
        
        gameOver.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.fadeInWithDuration(1.0),
            SKAction.waitForDuration(2.0),
            SKAction.fadeOutWithDuration(2.0)
            ]))
        
        totalScore.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.fadeInWithDuration(1.0),
            SKAction.waitForDuration(2.0),
            SKAction.fadeOutWithDuration(2.0)
            ]))
        
        self.currentState = .GameOver
        self.removeAllActions()
        self.stage!.die()
        self.player!.die()
        self.scoreLabel!.stop()
        self.score += Stage.score
        self.runAction(SKAction.waitForDuration(6.0), completion: {
            let startScene = StartScene(size:CGSizeMake(1334, 750))
            startScene.scaleMode = .AspectFill
            self.view!.presentScene(startScene)
        })
        
    }
    
    func getScore(position: CGPoint, color:UIColor = UIColor.grayColor(), score:Int, duration:Double = 0.5, bias:CGFloat = 25,
        fontSize:CGFloat = 50){
            
        let scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "Existence"
        scoreLabel.alpha = 0.7
        scoreLabel.fontColor = color
        scoreLabel.fontSize = fontSize
        scoreLabel.verticalAlignmentMode = .Center
        scoreLabel.position = position
        scoreLabel.xScale = 0.2
        scoreLabel.yScale = 0.2
        scoreLabel.zPosition = 20
        
        let check = SKAction.runBlock({
            if(score == 0){
                scoreLabel.removeFromParent()
            }
        })
        
        let expand = easeScaleTo(1, duration: 1)
        expand.timingFunction = {(x:Float) -> Float in sqrt(x)}
        
        let moveUp = SKAction.moveByX(0, y: bias, duration: duration)
        moveUp.timingFunction = {(x:Float) -> Float in sqrt(x)}
        
        let sumUp = SKAction.customActionWithDuration(duration, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
            scoreLabel.text = "\(Int(CGFloat(score) * elapsedTime / CGFloat(duration)))"
        })
        
        let finalScore = SKAction.runBlock({ () -> Void in
            scoreLabel.text = "\(score)"
        })
        
        let blink = SKAction.repeatAction(SKAction.sequence([SKAction.fadeAlphaTo(0.1, duration: 0.025), SKAction.fadeAlphaTo(1, duration: 0.025)]), count: 10)
            
            
        Stage.score += score
        
        scoreLabel.runAction(SKAction.sequence([check,
            SKAction.group([expand, moveUp,
                SKAction.sequence([sumUp, finalScore, blink])]),
            SKAction.group([easeScaleTo(1.5, duration: 0.125),
                SKAction.fadeOutWithDuration(0.125)]),
            SKAction.runBlock({scoreLabel.removeFromParent()})]))
        
        GameScene.currentScene!.addChild(scoreLabel)
    }
    
    
    func calculateScore(bonusLocation: CGPoint){
        
        let stageClear = SKLabelNode(fontNamed: "Roboto")
        let stageScore = SKLabelNode(fontNamed: "Roboto")
        let totalScore = SKLabelNode(fontNamed: "Roboto")
        let lifeBonus = SKLabelNode(fontNamed: "Roboto")
        let score = Stage.score
        
        func easeMoveToY(y:CGFloat, duration:Double = 0.5) -> SKAction{
            let action = SKAction.moveToY(y, duration: duration)
            action.timingMode = .EaseInEaseOut
            return action
        }
        
        func setAttributes(label:SKLabelNode){
            label.alpha = 0.7
            label.fontColor = UIColor.whiteColor()
            label.fontSize = 200
            label.verticalAlignmentMode = .Center
            label.position = CGPointMake(self.size.width / 2, 0 - 100)
            label.xScale = 0.2
            label.yScale = 0.2
            label.zPosition = 15
            self.addChild(label)
        }
        
        func calculateAction(label:SKLabelNode, s:String, finalScore:Int, duration:Double) -> SKAction{
            let action = SKAction.customActionWithDuration(duration, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
                let score = Int(Double(finalScore) * Double(elapsedTime) / duration)
                label.text = "\(s)\(score)"
            })
            return action
        }
        
        self.score += Stage.score
        
        setAttributes(stageClear)
        setAttributes(stageScore)
        setAttributes(totalScore)
        setAttributes(lifeBonus)
        
        stageClear.fontSize = 150
        lifeBonus.fontSize = 130
        lifeBonus.position = CGPointMake(bonusLocation.x, 0 - 100)
        
        stageClear.text = "stage \"\(Stage.name!)\" clear"
        stageClear.runAction(SKAction.sequence([
            easeMoveToY(self.size.height / 2 + 130),
            easeMoveToY(self.size.height / 2 + 180, duration: 2),
            easeMoveToY(self.size.height + 100, duration: 0.25)
            ]))
        
        
        stageScore.text = "STAGE SCORE: 0"
        stageScore.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.5),
            easeMoveToY(self.size.height / 2),
            SKAction.group([easeMoveToY(self.size.height / 2 + 50, duration: 2),
                calculateAction(stageScore, s: "STAGE SCORE: ", finalScore: score, duration: 1)
                ]),
            easeMoveToY(self.size.height + 200, duration: 0.25)
            ]))
        
        totalScore.text = "TOTAL SCORE: 0"
        totalScore.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            easeMoveToY(self.size.height / 2 - 130),
            SKAction.group([easeMoveToY(self.size.height / 2 - 80, duration: 2),
                calculateAction(totalScore, s: "TOTAL SCORE: ", finalScore: self.score, duration: 1)
                ]),
            easeMoveToY(self.size.height + 200, duration: 0.25)
            ]))
        
        lifeBonus.text = "LIFE BONUS"
        lifeBonus.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.5),
            easeMoveToY(bonusLocation.y + 90),
            easeMoveToY(bonusLocation.y + 100, duration: 1.5),
            easeMoveToY(self.size.height + 100, duration: 0.25)
            ]))
    }
    
    func spawnSpark(location:CGPoint, particleAmount:Int = 4, minRadius:Double = 20, maxRadius:Double = 200){
        for _ in 1...particleAmount{
            let particle = SKShapeNode(circleOfRadius: 5)
            particle.fillColor = UIColor.whiteColor()
            particle.position = location
            let radius = Double(arc4random()) % (maxRadius - minRadius) + minRadius
            let angle = Double(arc4random()) % (M_PI * 2.0)
            
            let timingFunction = {(x: Float) -> Float in sqrt(x)}
            let move = SKAction.moveByX(CGFloat(radius * cos(angle)), y: CGFloat(radius * sin(angle)), duration: 0.25)
            move.timingFunction = timingFunction
            let action = SKAction.sequence([
                move,
                SKAction.scaleTo(0, duration: 0.25),
                SKAction.removeFromParent()
            ])
            particle.runAction(action)
            self.addChild(particle)
        }
    }
    
    func getGloriousRound(location:CGPoint, particleAmount:Int = 50, radius:CGFloat = 200, time:Double = 0.5, removeTime:Double = 2){
        for i in 0...particleAmount{
            let particle = SKShapeNode(circleOfRadius: 5)
            particle.fillColor = UIColor.whiteColor()
            particle.position = location
            particle.xScale = 0
            particle.yScale = 0
            let angle:CGFloat = CGFloat(M_PI) * 2.0 * CGFloat(i) / CGFloat(particleAmount) + CGFloat(M_PI_2)
            let timingFunction = {(x: Float) -> Float in sqrt(x)}
            let move = SKAction.moveByX(CGFloat(radius * cos(angle)), y: CGFloat(radius * sin(angle)), duration: 0.25)
            move.timingFunction = timingFunction
            let action = SKAction.sequence([
                SKAction.waitForDuration(time / Double(particleAmount) * Double(i)),
                SKAction.group([move, easeScaleTo(1.0)]),
                SKAction.waitForDuration(time),
                easeScaleTo(1.5),
                SKAction.waitForDuration(removeTime),
                easeScaleTo(0),
                SKAction.removeFromParent()])
            particle.runAction(action)
            self.addChild(particle)
        }
    }
    
}
