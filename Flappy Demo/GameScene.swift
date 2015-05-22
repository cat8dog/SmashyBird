import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let birdCategory: UInt32 = 0x1 << 0 //  00000000000000000000000000000001
    let pipesUniteCategory: UInt32 = 0x1 << 1 // 00000000000000000000000000000010
    let pipe1Category: UInt32 = 0x1 << 2 //
    let pipe2Category: UInt32 = 0x1 << 3
    
  

//    var pipeOne = SKSpriteNode()
    var bird = SKSpriteNode()
//    var backGround = SKSpriteNode()
    var animationNode = SKSpriteNode()
    

    
    override func didMoveToView(view: SKView) {
    // physicsWorld will access the delegate
        self.physicsWorld.contactDelegate = self
     
    // assign texture to the node
    
        // assign texture to the node
    var birdTexture = SKTexture (imageNamed: "flappy1.png")
        var birdTexture2 = SKTexture (imageNamed: "flappy2.png")
        
    var animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        
    var makePlayerAnimate = SKAction.repeatActionForever(animation)
    
    bird = SKSpriteNode(texture:birdTexture)
    bird.runAction(makePlayerAnimate)
    bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))

    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
    bird.physicsBody?.dynamic = true
    bird.physicsBody?.allowsRotation = false
    bird.zPosition = 10
    bird.physicsBody?.categoryBitMask = birdCategory
    bird.physicsBody?.collisionBitMask = pipe1Category | pipe2Category
    bird.physicsBody?.contactTestBitMask = pipesUniteCategory
    self.addChild(bird)
        
    var ground = SKNode()
    // set the ground postion
    ground.position = CGPointMake(0, 0)
    ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width * 2, 150))
    ground.physicsBody?.dynamic = false
    self.addChild(ground)
        // Add the background
    
      self.beginBackGroundLoop()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector ("makePipes"), userInfo: nil, repeats: true)
    
    
    }
    
  
    
    func beginBackGroundLoop() {
        
        var bgTexture = SKTexture(imageNamed: "bg.png")
        
        var moveBg = SKAction.moveByX(-bgTexture.size().width, y:0, duration: 4)
        var replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        var moveBGForEver = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        
        for var i:CGFloat = 0; i < 3; i++ {
            
            
            var backGround = SKSpriteNode(texture:bgTexture)
            
            backGround.position = CGPoint(x: bgTexture.size().width / 2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            backGround.size.height = self.frame.height
            
            backGround.runAction(moveBGForEver)
            addChild(backGround)
            
            // set up timer
            
        }
     
        
    }
 
        func makePipes() {
            
            // Create a gap between 2 pipes (4 birds can fit between the gap)
            var gap = bird.size.height * 4

            //movement amount
            var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
            // gap offset
            var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
//            var movePipes1 = SKAction.moveByX(:0, y:(-self.frame.size.height * 2), duration: NSTimeInterval(self.frame.size.width / 100))
            
          var movePipesX1 = SKAction.moveByX(-self.frame.size.width * 2,y: 0, duration: NSTimeInterval (self.frame.size.width / 100))
        var movePipesX2 = SKAction.moveByX(-self.frame.size.width * 2,y:0, duration: NSTimeInterval (self.frame.size.width / 100))
            
            let collapseDuration = NSTimeInterval(arc4random() % UInt32(5.0)) + 1.0

            var movePipesY1 = SKAction.moveByX(0, y: (-gap / 2.0 + pipeOffset), duration: NSTimeInterval (collapseDuration))
            
//            movePipesY1.timingMode = SKActionTimingMode.EaseIn
            
            movePipesY1.timingFunction = { time -> Float in
                return pow(6.0, time) - 1.0
            }
            var movePipesY2 = SKAction.moveByX(0, y: (gap / 2.0 + pipeOffset), duration: NSTimeInterval (collapseDuration))
            
            movePipesY2.timingFunction = { time -> Float in
                return pow(6.0, time) - 1.0
            }
//            movePipesY2.timingFunction = { time -> Float in
//                return time
//            }
            
            var removePipes = SKAction.removeFromParent()
            var moveAndRemovePipes1 = SKAction.sequence([movePipesX1, removePipes])
              var moveAndRemovePipes2 = SKAction.sequence([movePipesX2, removePipes])
            // Pipe 1
            
            let collapseAction1 = SKAction.repeatActionForever(SKAction.sequence([movePipesY1, movePipesY1.reversedAction()]))
            let collapseAction2 = SKAction.repeatActionForever(SKAction.sequence([movePipesY2, movePipesY2.reversedAction()]))
            var collapseAndMove1 = SKAction.group([collapseAction1, moveAndRemovePipes1])
              var collapseAndMove2 = SKAction.group([collapseAction2, moveAndRemovePipes2])
            
            var pipe1Texture = SKTexture(imageNamed: "pipe1.png")
            var pipe1 = SKSpriteNode(texture:pipe1Texture)
            // added action to pipe1
            pipe1.runAction(collapseAndMove1)
            pipe1.physicsBody = SKPhysicsBody (rectangleOfSize: pipe1.size)
            pipe1.physicsBody?.dynamic = false
            pipe1.position = CGPoint(x: self.frame.size.width, y: CGRectGetMidY (self.frame) + pipe1.size.height / 2 + gap / 2 + pipeOffset)
            pipe1.physicsBody?.categoryBitMask = pipe1Category
            pipe1.physicsBody?.collisionBitMask = birdCategory
        
            

            
       //**     self.addChild(pipe1)
            // Pipe 2
            var pipe2Texture = SKTexture(imageNamed: "pipe2.png")
            var pipe2 = SKSpriteNode(texture: pipe2Texture)
            pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
            pipe2.physicsBody?.dynamic = false
            pipe2.runAction(collapseAndMove2)
            pipe2.position = CGPoint(x: self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height / 2 - gap / 2 + pipeOffset)
            pipe2.physicsBody?.categoryBitMask = pipe2Category
            pipe2.physicsBody?.collisionBitMask = birdCategory
//                 pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height / 2)
       //**     self.addChild(pipe2)
            
            
//            var gapObject = SKSpriteNode()
//            gapObject.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + pipeOffset)
//            gapObject.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gap))
//            var moveGapObject = SKAction.moveByX(-self.frame.size.width * 2,y: 0, duration: NSTimeInterval (self.frame.size.width / 100))
//            var removeGapObject = SKAction.removeFromParent()
//            var moveAndRemoveGapObject = SKAction.sequence([moveGapObject, removeGapObject])
//            gapObject.addChild(self)
//            
//            
//            gapObject.physicsBody?.dynamic = false;
//            gapObject.physicsBody?.collisionBitMask = gapObjectCategory
//            gapObject.physicsBody?.categoryBitMask = gapObjectCategory
//            gapObject.physicsBody?.contactTestBitMask = birdCategory
            
            
            var pipesUnite = SKSpriteNode ()
            pipesUnite.addChild(pipe1)
            pipesUnite.addChild(pipe2)
            self.addChild(pipesUnite)
    
          
            
        }
    

 
    
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        println("Flappy is Flying")
        bird.physicsBody?.velocity = CGVectorMake(0,0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location) == self.bird {
                println("Flappy is touched")
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

}