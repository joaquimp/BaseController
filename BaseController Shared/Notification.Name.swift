//
//  Notification.Name.swift
//  TheGame
//
//  Created by Pedro Cacique on 17/10/21.
//

import Foundation

extension Notification.Name {
    static var renderProcessLoaded: Notification.Name {
        return .init(rawValue: "Render.processLoaded")
    }
    
    static var gameProcessLoaded: Notification.Name {
        return .init(rawValue: "Game.processLoaded")
    }
    
    static var renderDidLoad: Notification.Name {
        return .init(rawValue: "render.didLoad")
    }
    
    static var renderObject: Notification.Name {
        return .init(rawValue: "render.draw")
    }
}
