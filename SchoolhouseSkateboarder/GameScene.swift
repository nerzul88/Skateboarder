//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by MATTHEW MCCARTHY on 4/5/17.
//  Copyright © 2017 iOS Kids. All rights reserved.
//

import SpriteKit

// Структура для хранения физических данных
// которые могут взаимодействовать друг с другом
struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Enum для генерации верхних и нижних блоков
    enum BrickLevel: CGFloat {
        
        case low = 0.0
        case high = 100.0
    }
    
    // Enum для определения состояния игры
    enum GameState {
        case notRunning
        case running
    }
    
    // MARK:- Class Properties
    
    // Массив для хранения текущих блоков
    var bricks = [SKSpriteNode]()
    // Массив для хранения текущих кристаллов
    var gems = [SKSpriteNode]()
    // Размер используемых блоков
    var brickSize = CGSize.zero
    // Текущий уровень блока, определяющий y-позицию нового блока
    var brickLevel = BrickLevel.low
    // TОтслеживание текущуего игрового состояния
    var gameState = GameState.notRunning
    // Скорость прокрутки
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    // Константа для гравитации
    let gravitySpeed: CGFloat = 1.5
    // Свойства механизма подсчёта очков
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    // Точка последнего вызова метода обновления
    var lastUpdateTime: TimeInterval?
    // Создание персонажа
    let skater = Skater(imageNamed: "skater")
    
    
    // MARK:- Setup and Lifecycle Methods
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        // Задание физических параметров персонажа и его добавление
        skater.setupPhysicsBody()
        addChild(skater)
        
        // Добавление распознавания касания экрана
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        // Добавление начального меню
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        menuLayer.position = CGPoint(x: 0.0, y: 0.0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Нажмите для начала игры", score: nil)
        addChild(menuLayer)
    }
    
    func resetSkater() {
        // Задание стартовой позиции персонажа, zPosition и minimumY
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        
        // Информация слева
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "Очки")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // Информация о текущих очках
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // Информация о рекордных очках
        
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "Рекорд")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        // Актуальный рекорд
        
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        
        // Сброс позиций при старте новой игры
        
        gameState = .running
        
        resetSkater()
        
        score = 0
        
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func gameOver() {
        
        // Новый рекорд при окончании игры
        
        gameState = .notRunning
        
        if score > highScore {
            highScore = score
            
            updateHighScoreLabelText()
        }
        
        // Сообщение "Игра окончена"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Игра окончена", score: score)
        addChild(menuLayer)
    }
    
    
    // MARK:- Spawn and Remove Methods
    
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        
        // Создание спрайта блока и добавление к сцене
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        // Обновление brickSize реальным значением
        brickSize = brick.size
        
        // Добавление нового блока к массиву
        bricks.append(brick)
        
        // Задание физики телу блока
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        
        // Создание спрайта кристалла и добавление к сцене
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        // Добавление нового кристалла к массиву
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        
        gem.removeFromParent()
        
        if let gemIndex = gems.index(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    
    // MARK:- Update Methods
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        
        // Отслеживание наибольшей позиции-x всех текущих блоков
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            
            let newX = brick.position.x - currentScrollAmount
            
            // Удаление блока, когда он заехал далеко влево
            if newX < -brickSize.width {
                
                brick.removeFromParent()
                
                if let brickIndex = bricks.index(of: brick) {
                    bricks.remove(at: brickIndex)
                }
                
            } else {
                
                // Обновление позции блока на экране
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                // Обновление блоков справа
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        // Проверка заполнения экрана блоками
        while farthestRightBrickX < frame.width {
            
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            
            // Задание пробелов в блоках
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 10 {
                
                // 2-х процентный шанс задание пробелов между блоками
                // после того, как игрок достигнет 10 и более очков
                let gap = 20.0 * scrollSpeed
                brickX += gap
                
                // Добавление кристалла над пробелами
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            }
            else if randomNumber < 4 && score > 20 {
                
                // 2-х процентный шанс изменение высоты блоков
                // после того, как игрок достигнет 20 и более очков
                if brickLevel == .high {
                    brickLevel = .low
                }
                else if brickLevel == .low {
                    brickLevel = .high
                }
            }
            
            // Генерация и обновление блоков
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        
        for gem in gems {
            
            // Обновление позиций кристаллов
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)

            // Удаление кристаллов при переещении их влево за экран
            if gem.position.x < 0.0 {
                
                removeGem(gem)
            }
        }
    }
    
    func updateSkater() {
        
        // Определение положения персонажа по касанию блоков
        if let velocityY = skater.physicsBody?.velocity.dy {
            
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        
        // Проверка, закончилась ли игра
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        
        // Увеличение очков играока по пройденному пути
        // Обновление каждую секунду
        
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            
            // Увеличение очков
            score += Int(scrollSpeed)
            
            // Обновление lastScoreUpdateTime текущим временем
            lastScoreUpdateTime = currentTime
            
            updateScoreLabelText()
        }
    }
    
    
    // MARK:- Main Game Loop Method
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState != .running {
            return
        }
        
        // Медленное увеличение скорости прокрутки
        scrollSpeed += 0.01
        
        // Определение времени с момента последнего обновления
        var elapsedTime: TimeInterval = 0.0
        
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        // Насколько далеко сдвинутся объекты при обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        updateSkater()
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
    }
    
    
    // MARK:- Touch Handling Methods
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        
        if gameState == .running {
            
            // Прыжок при касании, если персонаж на блоке
            if skater.isOnGround {
                
                skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
                
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
        }
        else {
            
            // Если игра не запущена, отображать надпись
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                
                menuLayer.removeFromParent()
            }
            
            startGame()
        }
    }
    
    
    // MARK:- SKPhysicsContactDelegate Methods
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Проверка контакта между персонажем и блоком
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            
            if let velocityY = skater.physicsBody?.velocity.dy {
                
                if !skater.isOnGround && velocityY < 100.0 {
                    
                    skater.createSparks()
                }
            }
            
            skater.isOnGround = true
        }
        else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            
            // Удаление кристалла при касании
            if let gem = contact.bodyB.node as? SKSpriteNode {
                
                removeGem(gem)
                
                // Начисление 50 очков за кристалл
                score += 50
                updateScoreLabelText()
                
                run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
        }
    }
}
