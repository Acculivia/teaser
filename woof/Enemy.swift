import Foundation
import SpriteKit

class Enemy:SKShapeNode{

    override init(){
        super.init()
        self.name = "Enemy"
        self.fillColor = SKColor.whiteColor()
        self.strokeColor = SKColor.whiteColor()
        self.xScale = 0
        self.yScale = 0
        self.zPosition = 8
    }
    
    convenience init(radius r:CGFloat, fillColor f:UIColor = SKColor.whiteColor(), strokeColor s:UIColor = SKColor.whiteColor()){
        self.init()
        let shape = CGPathCreateMutable()
        CGPathAddArc(shape, nil, 0,0, r, 0, CGFloat( M_PI * 2.0 ), true)
        self.path = shape
        self.fillColor = f
        self.strokeColor = s
        self.physicsBody = getPhysicsBody(radius: r)
    }
    
    func start(){
        self.runAction(easeScaleTo(1.0))
    }
    
    func die(){
        self.removeAllActions()
        self.runAction(SKAction.sequence([easeScaleTo(2.0), easeScaleTo(0), SKAction.removeFromParent()]))
    }

    
    func getPhysicsBody(radius radius:CGFloat) -> SKPhysicsBody{
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.collisionBitMask = 0
        body.categoryBitMask = enemyCategory
        body.contactTestBitMask = playerCategory | scoreAuraCategory
        return body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }}