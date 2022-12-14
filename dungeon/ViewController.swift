//
//  ViewController.swift
//  dungeon
//
//  Created by Fernando Salom Carratala on 27/7/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var positionStack: UIStackView!
    @IBOutlet weak var Xlabel: UILabel!
    @IBOutlet weak var YLabel: UILabel!
    let squarePerRow = 12
    var sizeOfSquare: CGFloat = 0
    var character: UIView!
    var numberOfRows: Int = 0
    var controlDuration = 0.5
    var board: [[Int]] = [[]]
    var map = [[Terrain]]()
    var isPressed = false

    struct Texture {
        var image: UIImage!
        var isBlocked: Bool!
    }

    struct Terrain {
        var texture: Texture!
        var view: UIImageView!
        init(texture: Texture, size: CGFloat) {
            self.view = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            self.view.image = texture.image
            self.texture = texture
        }
    }

    enum Movement {
        case up
        case down
        case left
        case right
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sizeOfSquare = UIScreen.main.bounds.width / CGFloat(squarePerRow)
        numberOfRows = Int(UIScreen.main.bounds.height / CGFloat(sizeOfSquare))
        loadMap()
        character = loadCharacter()
        loadController()
    }

    func loadMap() {
        for n in 0...numberOfRows {
            let positionY = CGFloat(n) * sizeOfSquare
            let row = UIStackView(frame: CGRect(x: 0, y: positionY, width: UIScreen.main.bounds.width, height: sizeOfSquare))
            let terrains = loadRow()
            self.map.append(terrains)
            for terrain in terrains {
                row.addArrangedSubview(terrain.view)
                row.distribution = .fillEqually
            }
            row.backgroundColor = .black
            self.view.addSubview(row)
        }
    }

    func loadRow() -> [Terrain]{
        let textures = [
            Texture(image: UIImage(named: "concrete")!, isBlocked: false),
            Texture(image: UIImage(named: "concrete2")!, isBlocked: false),
            Texture(image: UIImage(named: "concrete3")!, isBlocked: false),
            Texture(image: UIImage(named: "door")!, isBlocked: true),
            Texture(image: UIImage(named: "steel")!, isBlocked: true),
            Texture(image: UIImage(named: "steel2")!, isBlocked: true),
            Texture(image: UIImage(named: "floor")!, isBlocked: false)
        ]
        var mapPieces: [Terrain] = []
        for _ in 0...squarePerRow - 1{
            let isConcrete = arc4random_uniform(20) <= 18 ? true : false
            let texture = isConcrete ? textures[0] : textures.randomElement()!
            mapPieces.append(Terrain(texture: texture, size: sizeOfSquare))
        }
        return mapPieces
    }

    func loadCharacter() -> UIView{
        let image = UIImage(named: "character")
        let character = UIImageView(frame: CGRect(x: 0, y: 0, width: self.sizeOfSquare, height: self.sizeOfSquare))
        character.image = image
        self.view.addSubview(character)
        return character
    }

    func canMove(to position: CGPoint) async -> Bool {
        let x = Int(position.x)
        let y = Int(position.y)
        if x < 0 || y < 0 || x >= map[0].count || y >= map.count{
            return false
        }
        if map[y][x].texture.isBlocked {
            return false
        }
        return true
    }

    func getPosition() -> CGPoint {
        CGPoint(x: Int(character.layer.position.x / sizeOfSquare), y: Int(character.layer.position.y / sizeOfSquare))
    }

    func check(this movement: Movement) async -> Bool {
        let currentPosition = getPosition()
        Xlabel.text = "\(currentPosition.x)"
        YLabel.text = "\(currentPosition.y)"
        self.view.bringSubviewToFront(positionStack)
        var futurePosition: CGPoint = currentPosition
        switch movement {
        case .up:
            futurePosition.y -= 1
        case .down:
            futurePosition.y += 1
        case .left:
            futurePosition.x -= 1
        case .right:
            futurePosition.x += 1
        }
        if await canMove(to: futurePosition) {
            return true
        } else {
            return false
        }
    }

    @objc func moveUp(){
        isPressed = true
        move(with: .up)
    }

    func move(with movement: Movement) {
        Task {
            if await !check(this: movement) { return }
            if !isPressed { return }
            UIView.animate(withDuration: self.controlDuration, delay: 0, options: .curveEaseInOut) {
                switch movement {
                case .up:
                    self.character.frame.origin.y = self.character.frame.origin.y - self.sizeOfSquare
                case .down:
                    self.character.frame.origin.y = self.character.frame.origin.y + self.sizeOfSquare
                case .left:
                    self.character.frame.origin.x = self.character.frame.origin.x - self.sizeOfSquare
                case .right:
                    self.character.frame.origin.x = self.character.frame.origin.x + self.sizeOfSquare
                }
            } completion: { finished in
                self.move(with: movement)
            }
        }
    }

    @objc func stop(){
        isPressed = false
    }
    @objc func moveDown(){
        isPressed = true
        move(with: .down)
    }
    @objc func moveLeft(){
        isPressed = true
        move(with: .left)
    }
    @objc func moveRight(){
        isPressed = true
        move(with: .right)
    }

    func loadController(){
        let controllerSize: CGFloat = 120.0
        let buttonSize: CGFloat = 40.0
        let image = UIImage(named: "controller")
        let controllerBackground = UIImageView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height - 200, width: controllerSize, height: controllerSize))
        controllerBackground.image = image
        let mainStack = UIStackView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height - 200, width: controllerSize, height: controllerSize))
        mainStack.axis = .vertical

        let upButton = UIButton(type: UIButton.ButtonType.custom)
        upButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        upButton.addTarget(self, action: #selector(moveUp), for: .touchDown)
        upButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        let leftButton = UIButton(type: UIButton.ButtonType.custom)
        leftButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        leftButton.addTarget(self, action: #selector(moveLeft), for: .touchDown)
        leftButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        let rightButton = UIButton(type: UIButton.ButtonType.custom)
        rightButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        rightButton.addTarget(self, action: #selector(moveRight), for: .touchDown)
        rightButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        let downButton = UIButton(type: UIButton.ButtonType.custom)
        downButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        downButton.addTarget(self, action: #selector(moveDown), for: .touchDown)
        downButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        let firstLine = UIStackView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height - 200, width: controllerSize, height: buttonSize))
        firstLine.axis = .horizontal
        firstLine.addArrangedSubview(upButton)
        firstLine.distribution = .fillEqually

        let secondLine = UIStackView(frame: CGRect(x: 0, y: 0, width: controllerSize, height: buttonSize))
        secondLine.axis = .horizontal
        secondLine.addArrangedSubview(leftButton)
        secondLine.addArrangedSubview(rightButton)
        secondLine.distribution = .fillEqually

        let thirdLine = UIStackView(frame: CGRect(x: 0, y:0, width: controllerSize, height: buttonSize))
        thirdLine.axis = .horizontal
        thirdLine.addArrangedSubview(downButton)
        thirdLine.distribution = .fillEqually

        mainStack.distribution = .fillEqually
        mainStack.addArrangedSubview(firstLine)
        mainStack.addArrangedSubview(secondLine)
        mainStack.addArrangedSubview(thirdLine)

        self.view.addSubview(controllerBackground)
        self.view.addSubview(mainStack)
    }
}
