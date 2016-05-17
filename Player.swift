import Foundation
import SpriteKit

class Player:SKNode, SKSceneDelegate{
    
    var body = SKShapeNode(rect: CGRectMake(-5, -5, 10, 10))
    var radius:CGFloat = 5
    var hp:Double = 999
    let auraRadius:CGFloat = 100
    let auraHurtRadius:CGFloat = 350
    
    override init(){
        super.init()
        self.name = "Player"
        body.physicsBody = getPhysicsBody(radius: radius)
        body.fillColor = SKColor.whiteColor()
        body.strokeColor = SKColor.grayColor()
        body.zPosition = 10
        body.xScale = 0
        body.yScale = 0
        body.runAction(SKAction.scaleTo(1, duration: 0.5))
        self.addChild(body)
        self.addAura()
    }
    
    func getPhysicsBody(radius radius: CGFloat) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOfSize: CGSize(width: radius * 2, height: radius * 2), center:CGPointZero)
        body.collisionBitMask = 0
        body.categoryBitMask = playerCategory
        body.contactTestBitMask = enemyCategory
        return body
    }
    
    func rotateBy(angle: Double, duration: Double = 0.25) -> SKAction{
        let action = SKAction.rotateByAngle(CGFloat(angle), duration: duration)
        let timingFunction = {(x: Float) -> Float in
            return sqrt(x)
        }
        action.timingFunction = timingFunction
        return action
    }
    
    func addAura(){
        let aura = SKShapeNode(circleOfRadius: auraRadius)
        self.addChild(aura)
        aura.name = "Aura"
        aura.fillColor = UIColor.clearColor()
        aura.alpha = 0.2
        aura.strokeColor = UIColor.whiteColor()
        aura.lineWidth = 7.0
        aura.zPosition = 10
        aura.xScale = 0
        aura.yScale = 0
        self.setAuraSize(aura, radius: auraRadius)
        aura.physicsBody!.usesPreciseCollisionDetection = true
        aura.runAction(easeScaleTo(1.0, duration: 1.0))
    }
    
    func start(){
        self.body.removeAllActions()
        self.body.runAction(SKAction.repeatActionForever(rotateBy(M_PI_4)))
        self.childNodeWithName("Aura")!.runAction(
            SKAction.repeatActionForever(SKAction.sequence([
                SKAction.fadeAlphaTo(0, duration: 0.25),
                SKAction.fadeAlphaTo(1.0, duration: 0.25)
                ])
            )
        )
    }
    
    func stop(){
        self.body.removeAllActions()
        self.body.runAction(SKAction.sequence([
            SKAction.rotateToAngle(0, duration: 0.25),
            SKAction.repeatActionForever(SKAction.sequence([easeScaleTo(1.1), easeScaleTo(1.0)]))
            ]))
        self.childNodeWithName("Aura")!.removeAllActions()
        self.childNodeWithName("Aura")!.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.5))
    }
    
    func hurt(){
        self.hp -= 1
        self.body.physicsBody = nil
        if(hp <= 0){GameScene.currentScene!.gameOver()}else{
            let hurtAura = SKShapeNode(circleOfRadius: 350)
            hurtAura.fillColor = UIColor.whiteColor()
            hurtAura.strokeColor = UIColor.clearColor()
            hurtAura.xScale = 0
            hurtAura.yScale = 0
            hurtAura.position = self.position
            hurtAura.glowWidth = 20
            self.setAuraSize(hurtAura, radius: 350)
            let flash = SKAction.sequence([SKAction.runBlock{
                self.setAuraSize(hurtAura, radius: 350)
                hurtAura.alpha = 0.7}, SKAction.fadeAlphaTo(0, duration: 1.0)])
            hurtAura.runAction(SKAction.sequence([
                easeScaleTo(1.0, duration: 0.1),
                SKAction.repeatAction(flash, count: 3),
                SKAction.removeFromParent()]),
                completion: {self.body.physicsBody = self.getPhysicsBody(radius: self.radius)})
            GameScene.currentScene!.addChild(hurtAura)
        }
    }
    
    func die(){
        self.childNodeWithName("Aura")?.removeAllActions()
        self.childNodeWithName("Aura")?.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.group([
                SKAction.scaleTo(2.0, duration: 4),
                SKAction.fadeOutWithDuration(4)
                ])
            ]))
        self.body.removeAllActions()
        self.body.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.group([
                SKAction.scaleTo(10.0, duration: 4),
                SKAction.fadeOutWithDuration(4)
                ])
            ]))
    }
    
    func setAuraSize(aura: SKShapeNode, radius:CGFloat){
        let auraPhysicsBody = SKPhysicsBody(circleOfRadius: radius)
        auraPhysicsBody.collisionBitMask = 0
        auraPhysicsBody.categoryBitMask = scoreAuraCategory
        auraPhysicsBody.contactTestBitMask = enemyCategory
        aura.physicsBody = auraPhysicsBody
        let shape = CGPathCreateMutable()
        CGPathAddArc(shape, nil, 0,0, radius, 0, CGFloat( M_PI * 2.0 ), true)
        aura.path = shape
    }
    
    func auraEaseScale(startRadius: CGFloat, endRadius: CGFloat, time:Double) -> SKAction{
        let action = SKAction.customActionWithDuration(time, actionBlock: {(node: SKNode, elapsedTime: CGFloat) -> Void in
            let distance = endRadius - startRadius
            let radius = distance / 2 * (1 - CGFloat(cos(M_PI * Double(elapsedTime) / time))) + startRadius
            self.setAuraSize(self.childNodeWithName("Aura") as! SKShapeNode, radius: radius)
        })
        return action
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}