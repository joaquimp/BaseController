//
//  JoystickController.swift
//  BaseController Shared
//
//  Created by Pedro Cacique.
//  Contributor Joaquim Pessoa Filho
//

import Foundation
import SpriteKit
import GameController

class JoystickController{
    
    weak var delegate: JoystickDelegate?
    
    // Escolha quais elementos do controller quer usar
    var gamePadLeft: GCControllerDirectionPad?
    var buttonX: GCControllerButtonInput?
    
    // Dicionário para mapear os comandos do jogo. útil para combinar keyboard e controller
    var keyMap: [ GCKeyCode : GameCommand ] = [:]
    
    
#if os( iOS )
    private var _virtualController: Any?
    
    @available(iOS 15.0, *)
    public var virtualController: GCVirtualController? {
        get { return self._virtualController as? GCVirtualController }
        set { self._virtualController = newValue }
    }
#endif
    
    init(){
        // preenche o mapa
        keyMap[.rightArrow] = .RIGHT
        keyMap[.keyD] = .RIGHT
        keyMap[.leftArrow] = .LEFT
        keyMap[.keyA] = .LEFT
        keyMap[.upArrow] = .UP
        keyMap[.keyW] = .UP
        keyMap[.downArrow] = .DOWN
        keyMap[.keyS] = .DOWN
        keyMap[.spacebar] = .ACTION
    }
    
    func observeForGameControllers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidConnect),
            name: NSNotification.Name.GCControllerDidBecomeCurrent, object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidStopBeingCurrent, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidConnect),
                                               name: NSNotification.Name.GCKeyboardDidConnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidDisconnect),
                                               name: NSNotification.Name.GCKeyboardDidDisconnect, object: nil)
        
#if os( iOS )
        if #available(iOS 15.0, *) {
            let virtualConfiguration = GCVirtualController.Configuration()
            
            // crie um array com os elementos que escolheu nas variáveis globais
            virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputButtonX]
            
            virtualController = GCVirtualController(configuration: virtualConfiguration)
            
            // Connect to the virtual controller if no physical controllers are available.
            if GCController.controllers().isEmpty {
                virtualController?.connect()
            }
        }
#endif
        
        guard let controller = GCController.controllers().first else {
            return
        }
        registerGameController(controller)
    }
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
        unregisterGameController()
        
        
#if os( iOS )
        if #available(iOS 15.0, *) {
            if gameController != virtualController?.controller {
                virtualController?.disconnect()
            }
        }
#endif
        
        registerGameController(gameController)
        
        delegate?.controllerDidConnect(controller: gameController)
    }
    
    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
        unregisterGameController()
        delegate?.controllerDidDisconnect()
        
#if os( iOS )
        if #available(iOS 15.0, *) {
            if GCController.controllers().isEmpty {
                virtualController?.connect()
            }
        }
#endif
    }
    
    @objc
    func handleKeyboardDidConnect(_ notification: Notification) {
        guard let keyboard = notification.object as? GCKeyboard else {
            return
        }
        delegate?.keyboardDidConnect(keyboard: keyboard)
    }
    
    @objc
    func handleKeyboardDidDisconnect(_ notification: Notification) {
        guard let keyboard = notification.object as? GCKeyboard else {
            return
        }
        delegate?.keyboardDidDisconnect(keyboard: keyboard)
    }
    
    func registerGameController(_ gameController: GCController) {
        
        // para mudar a cor do led do controle de PS4
        // gameController.light?.color = GCColor(red: 0.5, green: 0.5, blue: 0.5)
        
        if let gamepad = gameController.extendedGamepad {
            self.gamePadLeft = gamepad.leftThumbstick
            self.buttonX = gamepad.buttonX
            
        } else if let gamepad = gameController.microGamepad {
            self.gamePadLeft = gamepad.dpad
            self.buttonX = gamepad.buttonX
        }
    }
    
    func unregisterGameController() {
        gamePadLeft = nil
    }
    
    func checkForKeyboard() {
        if let keyboard = GCKeyboard.coalesced?.keyboardInput {
            keyboard.keyChangedHandler = { (keyboard, key, keyCode, pressed) in
                guard let direction: GameCommand = self.keyMap[keyCode] else { return }
                
                if pressed {
                    self.pressButton( direction )
                } else {
                    self.releaseButton( direction )
                }
            }
        }
    }
    
    //MARK:- Buttons
    func pressButton(_ command: GameCommand){
        delegate?.buttonPressed(command: command)
    }
    
    func releaseButton(_ command: GameCommand){
        delegate?.buttonReleased(command: command)
    }
    
    func update(_ currentTime: TimeInterval) {
        checkForKeyboard()
        delegate?.joystickUpdate(currentTime)
    }
}
