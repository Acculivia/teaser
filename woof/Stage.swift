import Foundation
import SpriteKit

class Stage: SKNode{
    
    static var score:Int = 0
    static var countInTime:Double = 0
    static var musicTime:Double = 0
    
    static var id:Int = 0
    static var name:String?
    
    static var currentStage:Stage?
    
    static func getStage(id:Int)->Stage?{
        Stage.currentStage?.removeFromParent()
        Stage.currentStage = Stage()
        GameScene.currentScene!.addChild(Stage.currentStage!)
        Stage.id = id
        Stage.name = stages[id].name
        return Stage.currentStage!
    }
    
    static let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
    
    private override init(){
        super.init()
    }
    
    func start(){
        stages[Stage.id].runStageScript()
    }
    
    func die(){
        self.removeAllActions()
        self.runAction(SKAction.sequence([
            SKAction.runBlock({
                GameScene.currentScene!.enumerateChildNodesWithName("Teaser",
                    usingBlock: {(node: SKNode, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        (node as! Teaser).die()})
                Teaser.spawnAuraDie()}),
            SKAction.fadeOutWithDuration(1.0),
            SKAction.removeFromParent()]))
    }
    
    static func setStageMusicTime(){
        Stage.countInTime = Double(stages[id].countInTime)
        Stage.musicTime = Double(stages[id].musicTime)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}