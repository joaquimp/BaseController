//
//  GameScene.swift
//  BaseController Shared
//
//  Created by Pedro Cacique.
//  Contributor Joaquim Pessoa Filho
//  Learning modificataions Thallis Sousa

import SpriteKit
import GameController

class GameScene: SKScene, JoystickDelegate {
    
    var animal = SKSpriteNode(imageNamed: "parrot")
    var secondAnimal = SKSpriteNode(imageNamed: "penguin")
    let initialPositionSecondAnimal = CGPoint(x: 300, y: 300)
    let initialPosition = CGPoint(x: 100, y: 100)
    let multiplier: CGFloat = 10.0
    let joystickController: JoystickController = JoystickController()
    var lastActionTime: TimeInterval = TimeInterval.zero
    let whaitForNextAction: Double = 1
    
    var animalDx: CGFloat = 0
    var animalDy: CGFloat = 0
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    func setUpScene() {
        joystickController.delegate = self
        joystickController.observeForGameControllers()
        
        createAnimal()
    }
    
    func createAnimal() {
        let animalName = ["parrot", "bear", "buffalo", "chick"]
        let secondAnimalName = ["penguin", "pig", "crocodile", "narwhal"]
        let secondIndex = Int.random(in: 0..<secondAnimalName.count)
        let index = Int.random(in: 0..<animalName.count)
        
        animal.removeFromParent()
        animal = SKSpriteNode(imageNamed: animalName[index])
        animal.position = initialPosition
        
        secondAnimal.removeFromParent()
        secondAnimal = SKSpriteNode(imageNamed: secondAnimalName[secondIndex])
        secondAnimal.position = initialPositionSecondAnimal
        
        self.addChild(animal)
        self.addChild(secondAnimal)
    }
    
    func moveAnimal(dx: CGFloat, dy: CGFloat) {
        var xValue = animal.position.x + dx * multiplier
        var yValue = animal.position.y + dy * multiplier
        
        let halfWidth = animal.size.width/2
        let halfHeight = animal.size.height/2
        
        if xValue > self.size.width - halfWidth {
            xValue = self.size.width - halfWidth
        }
        if xValue < halfWidth {
            xValue = halfWidth
        }
        if yValue > self.size.height - halfHeight {
            yValue = self.size.height - halfHeight
        }
        if yValue < halfHeight {
            yValue = halfHeight
        }
        animal.position = CGPoint(x: xValue, y: yValue)
    }
    
    func moveSecondAnimal(dx: CGFloat, dy: CGFloat) {
        var xValueSAnimal = secondAnimal.position.x + dx * multiplier
        var yValueSAnimal = secondAnimal.position.y + dy * multiplier
        
        let halfSecondWidth = secondAnimal.size.width/2
        let halfSecondHeight = secondAnimal.size.height/2
        
        if xValueSAnimal > self.size.width - halfSecondWidth {
            xValueSAnimal = self.size.width - halfSecondWidth
        }
        if xValueSAnimal < halfSecondWidth {
            xValueSAnimal = halfSecondWidth
        }
        if yValueSAnimal > self.size.height - halfSecondHeight {
            yValueSAnimal = self.size.height - halfSecondHeight
        }
        if yValueSAnimal < halfSecondHeight {
            yValueSAnimal = halfSecondHeight
        }
        secondAnimal.position = CGPoint(x: xValueSAnimal + 1.7, y: yValueSAnimal + 1.7)
    }
    func resetAnimal() {
        animal.position = initialPosition
        secondAnimal.position = initialPositionSecondAnimal
        
        createAnimal()
    }
    
    override func update(_ currentTime: TimeInterval) {
        joystickController.update(currentTime)
        moveAnimal(dx: animalDx, dy: animalDy)
        moveSecondAnimal(dx: animalDx, dy: animalDy)
    }
    
#if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
#else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
#endif
    
    //MARK :- iOS and tvOS
#if os(iOS) || os(tvOS)
    // Touch-based event handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
#endif
    
#if os(OSX)
    // Mouse-based event handling
    override func mouseDown(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    
    // evita o beep quando aperta uma tecla normalmente
    override func keyDown(with event: NSEvent) { }
    override func keyUp(with event: NSEvent) { }
#endif
    
    //MARK:- JoystickDelegate
    func controllerDidConnect(controller: GCController) {
        print("Controller connected")
    }
    
    func controllerDidDisconnect() {
        print("Controller disconnected")
    }
    
    func keyboardDidConnect(keyboard: GCKeyboard) {
        print("Keyboard connected")
    }
    
    func keyboardDidDisconnect(keyboard: GCKeyboard) {
        print("Keyboard disconnected")
    }
    
    func buttonPressed(command: GameCommand) {
        print("pressed: \(command)")
        //        var dx:CGFloat = 0
        //        var dy:CGFloat = 0
        
        switch command {
        case .UP:
            animalDy = 1
        case .DOWN:
            animalDy = -1
        case .RIGHT:
            animalDx = 1
        case .LEFT:
            animalDx = -1
        case .ACTION:
            resetAnimal()
            return
        }
        
        //        self.moveAnimal(dx: dx, dy: dy)
    }
    
    func buttonReleased(command: GameCommand) {
        print("released: \(command)")
        
        switch command {
        case .UP:
            animalDy = 0
        case .DOWN:
            animalDy = 0
        case .LEFT:
            animalDx = 0
        case .RIGHT:
            animalDx = 0
        case .ACTION:
            resetAnimal()
            return
        }
    }
    
    func joystickUpdate(_ currentTime: TimeInterval){
        if let gamePadLeft = joystickController.gamePadLeft {
            if gamePadLeft.xAxis.value != 0 || gamePadLeft.xAxis.value != 0{
                let dx: CGFloat = CGFloat(gamePadLeft.xAxis.value)
                let dy: CGFloat = CGFloat(gamePadLeft.yAxis.value)
                // print("dpad: \(dx), \(dy)")
                moveAnimal(dx: dx, dy: dy)
            }
        }
        
        if let buttonX = joystickController.buttonX {
            if buttonX.isPressed{
                // print("X Button: \(buttonX.isPressed)")
                if(lastActionTime + whaitForNextAction < currentTime) {
                    resetAnimal()
                    lastActionTime = currentTime
                }
            }
        }
    }
}
