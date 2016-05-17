
import Foundation
import SpriteKit

class StartScene: SKScene{
    
    var startStage = 0
    
    let weiboAccount = "http://weibo.com/u/1869839975"
    let twitterAccount = "https://twitter.com/Alter_Taceo"
    
    enum State{
        case Main
        case Option
        case Info
        case SelectStage
        case IsMoving
    }
    
    var currentState:State = .Main
    var aura:StartSquareAura?
    var mainNode = SKNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = UIColor.blackColor()
        self.userInteractionEnabled = true
        self.alpha = 0
        self.runAction(SKAction.fadeInWithDuration(3.0))
        
        self.addChild(mainNode)
        
        setupMain()
        setupIntro()
    }
    
    func setLabelAttribute(text:String, fontSize:CGFloat = 50, parentNode:SKNode?) -> SKLabelNode{
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = "Existence"
        label.fontColor = UIColor.whiteColor()
        label.alpha = 0.7
        parentNode?.addChild(label)
        return label
    }
    
    func getSquare(position:CGPoint){
        let square = SKShapeNode(rect: CGRect(x: -100, y: -100, width: 200, height: 200))
        square.position = position
        square.fillColor = UIColor.whiteColor()
        square.strokeColor = UIColor.blackColor()
        square.lineWidth = 10
        square.alpha = 0
        square.xScale = 0
        square.yScale = 0
        square.zRotation = CGFloat(M_PI_4)
        square.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.sequence([
                    SKAction.fadeAlphaTo(1.0, duration: 1),
                    SKAction.fadeAlphaTo(0, duration: 1)]),
                SKAction.scaleTo(3.0, duration: 2.0)]),
            SKAction.removeFromParent()]))
        self.addChild(square)
    }
    
    func setupMain(){
        let main = SKNode()
        main.name = "main"
        
        let teaserLabel = setLabelAttribute("teaser", fontSize: 190, parentNode: main)
        teaserLabel.position = CGPointMake(size.width / 2, size.height / 2 + 80)
        
        let extra = setLabelAttribute("hold anywhere to start", fontSize: 50, parentNode: main)
        extra.position = CGPointMake(size.width / 2, size.height / 2 - 120)
        extra.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.fadeAlphaTo(1.0, duration: 2.0),
            SKAction.fadeAlphaTo(0.3, duration: 2.0)
            ])))
        
        mainNode.addChild(main)
    }
    
    func setupIntro(){
        let intro = SKNode()
        intro.name = "info"
        intro.zRotation = CGFloat(-M_PI_4 * 1.3)
        intro.position = CGPointMake(size.width * 0.7, 0)
        
        let background = SKShapeNode(rect: CGRectMake(0, 0, size.width, size.height))
        background.fillColor = UIColor.whiteColor()
        background.alpha = 0.6
        background.name = "info-background"
        intro.addChild(background)
        
        let introLabel1 = setLabelAttribute("this is a game made by", parentNode: intro)
        let introLabelEG = setLabelAttribute("EG", parentNode: intro)
        let introLabel2 = setLabelAttribute("in Central South University in China", parentNode: intro)
        let introLabel3 = setLabelAttribute("special thanks to my schoolmate", parentNode: intro)
        let introLabel4 = setLabelAttribute("JustZht", parentNode: intro)
        let introLabel5 = setLabelAttribute("find me at:", parentNode: intro)
        let twitter = setLabelAttribute("Twitter", parentNode: intro)
        let or1 = setLabelAttribute("or", parentNode: intro)
        let weibo = setLabelAttribute("Weibo", parentNode: intro)
        
        twitter.name = "twitter"
        twitter.fontName = "Avenir"
        weibo.name = "weibo"
        weibo.fontName = "Avenir"
        
        let introLabel6 = setLabelAttribute("support me:", parentNode: intro)
        let watchVideo = setLabelAttribute("watch a video", fontSize: 50, parentNode: intro)
        let or2 = setLabelAttribute("or", fontSize: 50, parentNode: intro)
        let donateMe = setLabelAttribute("donate me", fontSize: 50, parentNode: intro)
        watchVideo.name = "video"
        watchVideo.fontName = "Avenir"
        donateMe.name = "donate"
        donateMe.fontName = "Avenir"
        
        introLabel1.position = CGPointMake(size.width / 2, size.height / 2 + 270)
        introLabelEG.position = CGPointMake(size.width / 2, size.height / 2 + 200)
        introLabel2.position = CGPointMake(size.width / 2, size.height / 2 + 130)
        introLabel3.position = CGPointMake(size.width / 2, size.height / 2 + 60)
        introLabel4.position = CGPointMake(size.width / 2, size.height / 2 - 10)
        
        introLabel5.position = CGPointMake(size.width / 2, size.height / 2 - 90)
        twitter.position = CGPointMake(size.width / 2 - 200, size.height / 2 - 150)
        or1.position = CGPointMake(size.width / 2, size.height / 2 - 150)
        weibo.position = CGPointMake(size.width / 2 + 200, size.height / 2 - 150)
        introLabel6.position = CGPointMake(size.width / 2, size.height / 2 - 220)
        watchVideo.position = CGPointMake(size.width / 2 - 200, size.height / 2 - 290)
        or2.position = CGPointMake(size.width / 2 , size.height / 2 - 290)
        donateMe.position = CGPointMake(size.width / 2 + 170, size.height / 2 - 290)
        
        mainNode.addChild(intro)
    }
    
    func moveToIntro(){
        self.currentState = .IsMoving
        let move = SKAction.moveBy(CGVectorMake(-size.width * 0.7, 0), duration: 2.0)
        move.timingMode = .EaseInEaseOut
        let rotate = SKAction.rotateByAngle(CGFloat(M_PI_4 * 1.3), duration: 2.0)
        rotate.timingMode = .EaseInEaseOut
        mainNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.25), rotate]))
        mainNode.childNodeWithName("main")?.runAction(SKAction.fadeOutWithDuration(1.0))
        mainNode.childNodeWithName("info")?.runAction(SKAction.sequence([SKAction.waitForDuration(0.25), move]))
        mainNode.childNodeWithName("info")?.childNodeWithName("info-background")?.runAction(
            SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.5), SKAction.waitForDuration(2.5)]),
            completion:{self.currentState = .Info}
        )
    }
    
    func moveFromIntro(){
        self.currentState = .IsMoving
        let move = SKAction.moveBy(CGVectorMake(size.width * 0.7, 0), duration: 2.0)
        move.timingMode = .EaseInEaseOut
        let rotate = SKAction.rotateByAngle(CGFloat(-M_PI_4 * 1.3), duration: 2.0)
        rotate.timingMode = .EaseInEaseOut
        mainNode.runAction(rotate)
        mainNode.childNodeWithName("main")?.runAction(SKAction.fadeInWithDuration(2.0))
        mainNode.childNodeWithName("info")?.runAction(move)
        mainNode.childNodeWithName("info")?.childNodeWithName("info-background")?.runAction(
            SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.fadeAlphaTo(0.6, duration: 0.5)]),
            completion:{self.currentState = .Main}
        )
    }
    
    func enterGameScene(){
        self.userInteractionEnabled = false
        let position = aura!.position
        self.runAction(SKAction.sequence([
            SKAction.runBlock({self.getSquare(position)}),
            SKAction.waitForDuration(0.3),
            SKAction.runBlock({self.getSquare(position)}),
            SKAction.waitForDuration(0.3),
            SKAction.runBlock({self.getSquare(position)}),
            SKAction.fadeOutWithDuration(2),
            ]),
            completion:{
                let gameScene = GameScene(size:CGSizeMake(1334, 750))
                gameScene.scaleMode = .AspectFill
                gameScene.pointReference = position
                gameScene.nextStage = self.startStage
                self.scene!.view!.presentScene(gameScene)
            }
        )
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location:CGPoint! = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        switch currentState{
        case .Main:
            if (touchedNode.name == nil){
                StartSquareAura.appear(self)
                self.aura!.position = location
            }
        default:break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location:CGPoint! = touches.first?.locationInNode(self)
        switch currentState{
        case .Main:
            self.aura?.position = location
        default:
            break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location:CGPoint! = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        switch(currentState){
        case .Main:
            if (touchedNode.name != nil){
                switch (touchedNode.name!){
                case "info-background":
                    moveToIntro()
                default:
                    break
                }
            }
            self.aura?.corrupt()
        case.Info:
            if(touchedNode.name == nil){moveFromIntro()}
            else{
                switch touchedNode.name!{
                case "twitter":
                    UIApplication.sharedApplication().openURL(NSURL(string: twitterAccount)!)
                case "weibo":
                    UIApplication.sharedApplication().openURL(NSURL(string: weiboAccount)!)
                default:
                    break
                }
            }
        case .IsMoving:
            break
        default:
            break
        }
    }
    
}