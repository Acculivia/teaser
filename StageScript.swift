

import Foundation
import SpriteKit

let stageAmount = 6

func setAttributes(label:SKLabelNode, fontSize:CGFloat = 40, yBias:CGFloat = 0, duration:Double = 3){
    let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
    label.verticalAlignmentMode = .Center
    label.fontSize = fontSize
    label.fontName = "Roboto Light"
    label.alpha = 0
    label.position.x = GameScene.currentScene!.size.width + 200
    label.position.y = GameScene.currentScene!.size.height / 2 + yBias
    label.runAction(SKAction.sequence([
        SKAction.group([SKAction.moveToX(center.x + 50, duration: 0.25),
            SKAction.fadeAlphaTo(0.6, duration: 0.25)]),
        SKAction.moveToX(center.x - 50, duration: duration),
        SKAction.group([SKAction.moveToX(-200, duration: 0.25),
            SKAction.fadeAlphaTo(0, duration: 0.25)]),
        SKAction.removeFromParent()
        ]))
}

func wait(duration: Double) -> SKAction{
    return SKAction.waitForDuration(duration)
}

func display(label:SKLabelNode, _ beforeTime:Double = 0){
    Stage.currentStage!.runAction(SKAction.sequence([
        SKAction.waitForDuration(beforeTime),
        SKAction.runBlock({GameScene.currentScene!.addChild(label)})
        ]))
}

let stages:[(name:String, countInTime:Int, musicTime:Int, runStageScript:() -> Void)] = [
    
    //0
    (name:"Tutorial", countInTime:8, musicTime:24, runStageScript:{
        
        let label1 = SKLabelNode(text: "teaser")
        let label2 = SKLabelNode(text: "a game by EG")
        
        let label3 = SKLabelNode(text: "get more score with your big circle ring")
        let label4 = SKLabelNode(text: "rather than your tiny square core")
        
        let label5 = SKLabelNode(text: "hold any two corners")
        let label6 = SKLabelNode(text: "to DIE instantly")
        
        setAttributes(label1, yBias: 50)
        setAttributes(label2, yBias: -100)
        setAttributes(label3, yBias: 170)
        setAttributes(label4, yBias: -170)
        setAttributes(label5, yBias: 200, duration: 5)
        setAttributes(label6, yBias: -200, duration: 5)
        
        display(label1, 0)
        display(label2, 0)
        display(label3, 4)
        display(label4, 4)
        display(label5, 8)
        display(label6, 8)
        
        Stage.currentStage!.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(4),//CountIn
                Teaser.setSpawnAura(
                    ChangeRange(initValue: 50, endValue: 10, slice: 8),
                    ChangeRange(initValue: 100, endValue: 300, slice: 8),
                    ChangeRange(initValue: 50, endValue: 100, slice: 8)), wait(4),
                SKAction.repeatActionForever(SKAction.sequence([Teaser.spawn(), wait(4.0)]))
            ])
        )
    }),
    
    //1
    (name:"Teaser", countInTime:4, musicTime:32, runStageScript:{
        //will be removed
        let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
        
        Stage.currentStage!.runAction(
        SKAction.sequence([
            wait(0),//CountIn
            Teaser.setSpawnAura(
                ChangeRange(initValue: 50, endValue: 30, slice: 16),
                ChangeRange(initValue: 100, endValue: 300, slice: 16),
                ChangeRange(initValue: 50, endValue: 100, slice: 16)), wait(4.0),
            SKAction.repeatActionForever(SKAction.sequence([
                SKAction.repeatAction(
                    SKAction.sequence([Teaser.spawn(), wait(1.0)]), count: 2),
                SKAction.runBlock({
                    let a = GameScene.currentScene!.player!.position
                    Teaser.moveToSqrt(a, duration: 1.0)
                }), wait(1.0),
                Teaser.setSpawnAura(
                    ChangeRange(initValue: 20, endValue: 5, slice: 16),
                    ChangeRange(initValue: 120, endValue: 600, slice: 6),
                    ChangeRange(initValue: 100, endValue: 150, slice: 6), duration: 1.0),
                wait(1.0),
                SKAction.repeatAction(SKAction.sequence([Teaser.spawn(), wait(1.0)]), count: 2),
                SKAction.runBlock({
                    let a = GameScene.currentScene!.player!.position
                    Teaser.moveToSqrt(a, duration: 1.0)
                }), wait(1.0),
                Teaser.setSpawnAura(
                    ChangeRange(initValue: 50, endValue: 10, slice: 16),
                    ChangeRange(initValue: 100, endValue: 300, slice: 16),
                    ChangeRange(initValue: 50, endValue: 100, slice: 16)), wait(1.0)
                ]))
        ]))
    }),
    
    //2
    (name:"Huge", countInTime:4, musicTime:16, runStageScript:{
        //will be removed
        let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
        
        Stage.currentStage!.runAction(SKAction.sequence([
            Teaser.setSpawnAura(
                ChangeRange(initValue: 100, endValue: 30, slice: 12),
                ChangeRange(initValue: 100, endValue: 300, slice: 8),
                ChangeRange(initValue: 50, endValue: 100, slice: 8), duration:4.0), wait(4),//CountIn
            SKAction.repeatActionForever(
            SKAction.group([
                SKAction.repeatActionForever(SKAction.sequence([Teaser.spawn(), wait(4.0)])),
                SKAction.repeatActionForever(
                    SKAction.sequence([
                        Teaser.setSpawnAura(
                            ChangeRange(initValue: 150, endValue: 50, slice: 12),
                            ChangeRange(initValue: 100, endValue: 300, slice: 8),
                            ChangeRange(initValue: 50, endValue: 100, slice: 8), duration:4.0), wait(8.0),
                        Teaser.setSpawnAura(
                            ChangeRange(initValue: 100, endValue: 30, slice: 12),
                            ChangeRange(initValue: 100, endValue: 300, slice: 8),
                            ChangeRange(initValue: 50, endValue: 100, slice: 8), duration:4.0),
                        ])),
                SKAction.runBlock({Teaser.spawnAura!.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 6), wait(2.0)
                    ])))})
                ])
        )]))
    }),
    
    //3
    (name:"Mini", countInTime:4, musicTime:28, runStageScript:{
        //will be removed
        let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
        
        Stage.currentStage!.runAction(
            SKAction.sequence([
                Teaser.setSpawnAura(
                    ChangeRange(initValue: 20, endValue: 5, slice: 16),
                    ChangeRange(initValue: 150, endValue: 800, slice: 6),
                    ChangeRange(initValue: 150, endValue: 200, slice: 6), duration: 1.0),
                SKAction.waitForDuration(3.0),//CountIn
                SKAction.repeatActionForever(SKAction.sequence(([
                    SKAction.runBlock({
                        let a = GameScene.currentScene!.player!.position
                        Teaser.moveToSqrt(a, duration: 1.0)
                    }), wait(1.0),
                    Teaser.spawn(), wait(1.5),
                    Teaser.spawn(), wait(0.5),
                    Teaser.spawn(), wait(1)
                    ])))
                ])
        )
    }),
    
    //4
    (name:"More", countInTime:4, musicTime:24, runStageScript:{
        let center = CGPointMake(GameScene.currentScene!.size.width / 2, GameScene.currentScene!.size.height / 2)
        
        let label1 = SKLabelNode(text: "feel free to move around")
        let label2 = SKLabelNode(text: "before the stage has started")
        
        setAttributes(label1, yBias: 50)
        setAttributes(label2, yBias: -100)
        
        display(label1, 0)
        display(label2, 0)
        
        for i in 1...4{
            let node = SKShapeNode()
            let enemy = Enemy(radius: 50)
            enemy.position = CGPointMake(0, 300)
            enemy.start()
            node.addChild(enemy)
            node.position = center
            node.zRotation = CGFloat(Double(i) / 4.0 * M_PI_2 * 4.0)
            node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI_2), duration:1.0)))
            Stage.currentStage!.addChild(node)
        }
        
        for i in 1...4{
            let node = SKShapeNode()
            let enemy = Enemy(radius: 50)
            enemy.position = CGPointMake(0, 300)
            enemy.start()
            node.addChild(enemy)
            node.position = center
            node.zRotation = CGFloat(Double(i) / 4.0 * M_PI_2 * 4.0)
            node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(-M_PI_2), duration:1.0)))
            Stage.currentStage!.addChild(node)
        }
        
        Stage.currentStage!.runAction(SKAction.sequence([
            SKAction.waitForDuration(4),//CountIn
            Teaser.setSpawnAura(
                ChangeRange(initValue: 50, endValue: 10, slice: 8),
                ChangeRange(initValue: 100, endValue: 300, slice: 8),
                ChangeRange(initValue: 50, endValue: 100, slice: 8)), wait(4),
            SKAction.repeatActionForever(SKAction.sequence([Teaser.spawn(), wait(4.0)]))
            ])
        )
        
    }),
    
    //ALL STAGE CLEAR
    (name:"ALL STAGE CLEAR", countInTime:100, musicTime:0, runStageScript:{
        let label1 = SKLabelNode(text: "All stage clear")
        let label2 = SKLabelNode(text: "Total score:")
        let label3 = SKLabelNode(text: "Thanks for playing!")
        let scoreLabel = SKLabelNode(text: "")
        
        let totalScore = GameScene.currentScene!.score
        let duration = 5.0
        
        setAttributes(label1, yBias: 200, duration:8)
        setAttributes(label2, yBias: 100, fontSize: 80, duration: 8)
        setAttributes(label3, yBias: -150, fontSize: 60, duration: 10)
        setAttributes(scoreLabel, yBias: 0, fontSize: 80, duration: 8)
        scoreLabel.fontName = "Roboto Thin"
        
        let sumUp = SKAction.customActionWithDuration(duration, actionBlock: {(node:SKNode, elapsedTime:CGFloat) -> Void in
            scoreLabel.text = "\(Int(CGFloat(totalScore) * elapsedTime / CGFloat(duration)))"
        })
        
        let finalScore = SKAction.runBlock({ () -> Void in
            scoreLabel.text = "\(totalScore)"
        })
        
        let blink = SKAction.repeatAction(SKAction.sequence([SKAction.fadeAlphaTo(0.1, duration: 0.025), SKAction.fadeAlphaTo(1, duration: 0.025)]), count: 20)
        
        scoreLabel.runAction(SKAction.sequence([sumUp, finalScore, blink]))
        
        display(label1, 0)
        display(label2, 0)
        display(label3, 0)
        display(scoreLabel, 0)
        
        GameScene.currentScene!.runAction(SKAction.sequence([wait(9), SKAction.fadeOutWithDuration(2)]), completion:{
            GameScene.currentScene!.removeAllActions()
            let startScene = StartScene(size:CGSizeMake(1334, 750))
            startScene.scaleMode = .AspectFill
            GameScene.currentScene!.view!.presentScene(startScene)
        })
        
    })
]