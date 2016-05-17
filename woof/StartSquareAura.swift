

import Foundation
import SpriteKit

class StartSquareAura:SKNode{
    
    private var bodyLeft = SKShapeNode()
    private var bodyRight = SKShapeNode()
    
    private var hasStarted:Bool = false
    
    private override init(){
        super.init()
        self.addChild(bodyLeft)
        self.addChild(bodyRight)
    }
    
    static func appear(startScene:StartScene){
        if(startScene.aura == nil){
            startScene.aura = StartSquareAura()
            startScene.addChild(startScene.aura!)
        }
        startScene.aura!.start()
    }
    
    func setBodyAttribute(body:SKShapeNode, position:CGPoint){
        let radius:CGFloat = 100
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0,0, radius, 0, CGFloat( M_PI * 2.0 ), true)
        body.path = path
        body.lineWidth = 10.0
        body.alpha = 0
        body.xScale = 3.0
        body.yScale = 3.0
        body.position = position
    }
    
    func start(){
        hasStarted = true
        let duration:Double = 1.0
        var duration2 = duration - 0.5
        if(duration2 < 0){duration2 = 0}
        
        let scaleDown = SKAction.scaleTo(0, duration: duration)
        scaleDown.timingFunction = {(x:Float) -> Float in x * x}
        
        setBodyAttribute(bodyLeft, position: CGPoint(x: -100, y: 0))
        setBodyAttribute(bodyRight, position: CGPoint(x: 100, y: 0))
        
        bodyLeft.runAction(SKAction.group([
            scaleDown,
            SKAction.fadeAlphaTo(0.6, duration: duration),
            SKAction.moveByX(100, y: 0, duration: duration2)
            ]))
        
        bodyRight.runAction(SKAction.group([
            scaleDown,
            SKAction.fadeAlphaTo(0.6, duration: duration),
            SKAction.moveByX(-100, y: 0, duration: duration2)
            ]))
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(duration),
            SKAction.runBlock({
                (self.scene as! StartScene).enterGameScene()
                self.remove()
            })
            ]))
    }
    
    func corrupt(){
        if(!hasStarted){return}
        hasStarted = false
        self.removeAllActions()
        bodyLeft.removeAllActions()
        bodyLeft.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlphaTo(0, duration: 0.125),
                SKAction.scaleBy(1.3, duration: 0.125)]),
            ]))
        
        bodyRight.removeAllActions()
        bodyRight.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlphaTo(0, duration: 0.125),
                SKAction.scaleBy(1.3, duration: 0.125)]),
            ]))
    }
    
    func remove(){
        (self.parent as! StartScene).aura = nil
        self.removeFromParent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}