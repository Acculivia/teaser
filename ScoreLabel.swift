
import Foundation
import SpriteKit

class ScoreLabel:SKLabelNode{
//    var score:Int = 0
    
    override init(){
        super.init()
        self.name = "ScoreLabel"
        self.text = "0"
        self.fontSize = 150
        self.fontName = "Roboto"
        self.zPosition = 0
        self.alpha = 0
        self.fontColor = UIColor.whiteColor()
        self.horizontalAlignmentMode = .Center
        self.verticalAlignmentMode = .Center
        self.position = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
//        self.runAction(scoreLabelAction())
    }
    
//    func scoreLabelAction() -> SKAction{
//        let scaling = SKAction.repeatActionForever(SKAction.sequence([
//            easeScaleTo(1.1, duration: 0.1),
//            easeScaleTo(1.0, duration: 0.9)]))
//        
//        let rotateLeft = SKAction.rotateToAngle(CGFloat(M_PI / 20.0), duration: 8)
//        rotateLeft.timingMode = .EaseInEaseOut
//        let rotateRight = SKAction.rotateToAngle(CGFloat(-M_PI / 20.0), duration: 8)
//        rotateRight.timingMode = .EaseInEaseOut
//        let rotating = SKAction.repeatActionForever(SKAction.sequence([rotateLeft, rotateRight]))
//        
//        return SKAction.group([
//            scaling,
////            easeScaleTo(1.0, duration: 1.0),
//            rotating])
//    }
    
    func start(){
        self.runAction(SKAction.fadeAlphaTo(0.5, duration: 1.0))
    }
    
    func stop(){
        let score = Stage.score
        self.runAction(SKAction.sequence([
            SKAction.customActionWithDuration(1.0, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
                self.text = "\(score - Int(CGFloat(score) * elapsedTime))"
            }), SKAction.fadeOutWithDuration(1.0)]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
