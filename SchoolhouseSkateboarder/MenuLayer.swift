//
//  MenuLayer.swift
//  SchoolhouseSkateboarder
//
//  Created by MATTHEW MCCARTHY on 4/9/17.
//  Copyright © 2017 iOS Kids. All rights reserved.
//

import SpriteKit

class MenuLayer: SKSpriteNode {
    
    // Отображаем сообщение и текущий счёт
    func display(message: String, score: Int?) {
        
        // Создание надписи сообщения
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        // Установка начального пложения надписи в левом слое меню
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 32.0
        messageLabel.zPosition = 20
        self.addChild(messageLabel)
        
        // Анимация движения надписи к центру экрана
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        // Если есть очки, отображаем их на экране
        if let scoreToDisplay = score {
            
            // Создание текста количества очков
            let scoreString = String(format: "Score: %04d", scoreToDisplay)
            let scoreLabel: SKLabelNode = SKLabelNode(text: scoreString)
            
            // Начальное положение надписи справа от меню
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            
            // Анимация движения надписи к центру экрана
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}
