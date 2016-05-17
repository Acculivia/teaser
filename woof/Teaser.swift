import Foundation
import SpriteKit


class Teaser:Enemy{
    
    private var savedPosition:CGPoint?
    private var savedVector:CGVector?
    
    private var targetPosition:CGPoint?
    
    static var spawnAura:SKShapeNode?
    private static var spawnPosition:CGPoint = CGPointZero
    
    private static var spawnRadius = ChangeRange()
    private static var spawnDistance = ChangeRange()
    private static var spawnExtraDistance = ChangeRange()
    
    var reachDistance = ChangeRange()
    var extraDistance = ChangeRange()
    var teaserRadius = ChangeRange()
    
    private override init(){
        self.teaserRadius = ChangeRange(Teaser.spawnRadius)
        self.reachDistance = ChangeRange(Teaser.spawnDistance)
        self.extraDistance = ChangeRange(Teaser.spawnExtraDistance)
        super.init()
        self.name = "Teaser"
        self.fillColor = UIColor.whiteColor()
        self.zRotation = Teaser.spawnAura!.zRotation
        self.xScale = 0
        self.yScale = 0
        
        let radius = self.teaserRadius.currentValue
        let shape = CGPathCreateMutable()
        let rect = CGRect(origin: CGPointMake(-radius, -radius), size: CGSize(width: radius * 2, height: radius * 2))
        CGPathAddRect(shape, nil, rect)
        self.physicsBody = getPhysicsBody(radius: radius)
        self.path = shape
    }
    
    static func spawnAuraDie(){
        let a = Teaser.spawnAura
        Teaser.spawnAura = nil
        a?.runAction(SKAction.sequence([easeScaleTo(1.5, duration: 0.5), easeScaleTo(0), SKAction.removeFromParent()]))
    }
    
    static func spawn() -> SKAction{
        let action = SKAction.runBlock({
            if(Teaser.spawnAura == nil){return}
            let a = Teaser.spawnAura!
            let teaser = Teaser()
            teaser.position = a.position
            GameScene.currentScene!.runAction(SKAction.runBlock({teaser.start()}))
            
            let phantom = SKShapeNode()
            phantom.path = a.path
            phantom.position = a.position
            phantom.xScale = a.xScale
            phantom.yScale = a.yScale
            phantom.zRotation = a.zRotation
            phantom.fillColor = a.strokeColor
            phantom.strokeColor = UIColor.clearColor()
            phantom.alpha = 0.8
            phantom.runAction(SKAction.sequence([
                SKAction.group([SKAction.fadeOutWithDuration(1.0), easeScaleTo(3.0, duration: 1.0)]),
                SKAction.removeFromParent()
                ]))
            GameScene.currentScene!.addChild(phantom)
        })
        return action
    }
    
    static func moveToSqrt(point:CGPoint, duration:Double){
        let action = SKAction.moveTo(point, duration: duration)
        action.timingFunction = {(x:Float) -> Float in sqrt(sqrt(x))}
        Teaser.spawnAura?.runAction(action)
    }
    
    static func setSpawnAura(radius:ChangeRange, _ reachDistance:ChangeRange, _ extraDistance:ChangeRange, duration:Double = 0.5) -> SKAction{
        return SKAction.runBlock({
            if(Teaser.spawnAura == nil){
                Teaser.spawnRadius = radius
                Teaser.spawnDistance = reachDistance
                Teaser.spawnExtraDistance = extraDistance
                
                Teaser.spawnAura = SKShapeNode(rect: CGRectMake(
                    -radius.currentValue, -radius.currentValue, radius.currentValue * 2, radius.currentValue * 2))
                Teaser.spawnAura!.strokeColor = UIColor.whiteColor()
                Teaser.spawnAura!.lineWidth = 7.0
                Teaser.spawnAura!.xScale = 0
                Teaser.spawnAura!.yScale = 0
                Teaser.spawnAura!.alpha = 0.5
                Teaser.spawnAura!.zRotation = CGFloat(M_PI_4)
                Teaser.spawnAura!.position = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
                GameScene.currentScene!.addChild(Teaser.spawnAura!)
                Teaser.spawnAura?.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    easeScaleTo(1.2, duration: 0.5), easeScaleTo(1.0, duration: 0.5)])))
            }
            else{
                let a = Teaser.spawnAura!
                let start = Teaser.spawnRadius.currentValue
                let end = radius.currentValue
                
                a.runAction(SKAction.customActionWithDuration(duration, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
                    let r = (end - start) * elapsedTime / CGFloat(duration) + start
                    let shape = CGPathCreateMutable()
                    let rect = CGRect(origin: CGPointMake(-r, -r), size: CGSize(width: r * 2, height: r * 2))
                    CGPathAddRect(shape, nil, rect)
                    Teaser.spawnAura?.path = shape
                }))
                
                Teaser.spawnRadius = radius
                Teaser.spawnDistance = reachDistance
                Teaser.spawnExtraDistance = extraDistance
            }
        })
    }
    
    override func start(){
        GameScene.currentScene!.addChild(self)
        self.runAction(SKAction.sequence([
            easeScaleTo(1.5, duration: 0.5), easeScaleTo(1, duration: 0.5),
            SKAction.group([SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock({GameScene.currentScene!.getScore(self.position,
                        score: Int(self.teaserRadius.currentValue * 0.01 + self.reachDistance.currentValue * 0.02))}),
                    self.followPlayer()])),
                SKAction.repeatActionForever(SKAction.sequence([
                        rotateBy(M_PI_4), SKAction.waitForDuration(0.25),
                        rotateBy(M_PI_4), SKAction.waitForDuration(0.25),
                        rotateBy(-M_PI_4), SKAction.waitForDuration(0.25),
                        rotateBy(-M_PI_4), SKAction.waitForDuration(0.25)]))])
            ]))
    }
    
    func vectorFromTeaserToTarget() -> CGVector{
        var x = self.targetPosition!.x - self.position.x
        var y = self.targetPosition!.y - self.position.y
        let distance = sqrt(x * x + y * y)
        if distance >= self.reachDistance.currentValue{
            x = x / distance * self.reachDistance.currentValue
            y = y / distance * self.reachDistance.currentValue
        }else{
            x = x / distance * (distance + self.extraDistance.currentValue)
            y = y / distance * (distance + self.extraDistance.currentValue)
        }
        return CGVectorMake(x, y)
    }
    
    func followPlayer() -> SKAction{
        let savePosition = SKAction.runBlock({
            self.targetPosition = GameScene.currentScene!.player!.position
            self.savedPosition = self.position
            self.savedVector = self.vectorFromTeaserToTarget()
        })
        let getToPlayer = SKAction.customActionWithDuration(1.0, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
            let x = pow(elapsedTime, 1.0 / 3.0) * self.savedVector!.dx + self.savedPosition!.x
            let y = pow(elapsedTime, 1.0 / 3.0) * self.savedVector!.dy + self.savedPosition!.y
            self.position = CGPointMake(x, y)
        })
        return SKAction.sequence([savePosition, getToPlayer, SKAction.runBlock({self.addDifficulty()})])
    }
    
    func addDifficulty(){
        self.teaserRadius.update()
        self.reachDistance.update()
        self.extraDistance.update()
        
        let radius = teaserRadius.currentValue
        let shape = CGPathCreateMutable()
        let rect = CGRect(origin: CGPointMake(-radius, -radius), size: CGSize(width: radius * 2, height: radius * 2))
        CGPathAddRect(shape, nil, rect)
        self.physicsBody = getPhysicsBody(radius: radius)
        self.path = shape
    }
    
    func rotateBy(angle: Double, duration: Double = 0.25) -> SKAction{
        let action = SKAction.rotateByAngle(CGFloat(angle), duration: duration)
        let timingFunction = {(x: Float) -> Float in
            return sqrt(x)
        }
        action.timingFunction = timingFunction
        return action
    }
    
    override func getPhysicsBody(radius radius: CGFloat) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOfSize: CGSize(width: radius * 2, height: radius * 2), center:CGPointZero)
        body.collisionBitMask = 0
        body.categoryBitMask = enemyCategory
        body.contactTestBitMask = playerCategory | scoreAuraCategory
        return body
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChangeRange{
    
    private var valueIncrement:CGFloat = 0.0
    var initValue:CGFloat = 0.0
    var endValue:CGFloat = 0.0
    var currentValue:CGFloat = 0.0
    var slice:Int = 0
    
    init(){}
    
    init(initValue:CGFloat, endValue:CGFloat, slice:Int){
        self.initValue = initValue
        self.endValue = endValue
        self.slice = slice
        self.currentValue = initValue
        self.valueIncrement = (endValue - initValue) / CGFloat(slice)
    }
    
    init(_ i:ChangeRange){
        self.initValue = i.initValue
        self.endValue = i.endValue
        self.currentValue = i.currentValue
        self.slice = i.slice
        self.valueIncrement = i.valueIncrement
    }
    
    func update(){
        self.currentValue += self.valueIncrement
        if(valueIncrement >= 0){
            if(self.currentValue >= self.endValue){self.currentValue = self.endValue}
        }else{
            if(self.currentValue <= self.endValue){self.currentValue = self.endValue}
        }
    }
}