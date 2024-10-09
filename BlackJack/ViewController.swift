//
//  ViewController.swift
//  BlackJack
//
//  Created by Han on 2024/8/3.
//

import UIKit
import GameKit

let spades = ["spades_A","spades_2","spades_3","spades_4","spades_5","spades_6","spades_7","spades_8","spades_9","spades_10","spades_J","spades_Q","spades_K"]
let clubs = ["clubs_A","clubs_2","clubs_3","clubs_4","clubs_5","clubs_6","clubs_7","clubs_8","clubs_9","clubs_10","clubs_J","clubs_Q","clubs_K"]
let hearts = ["hearts_A","hearts_2","hearts_3","hearts_4","hearts_5","hearts_6","hearts_7","hearts_8","hearts_9","hearts_10","hearts_J","hearts_Q","hearts_K"]
let diamonds = ["diamonds_A","diamonds_2","diamonds_3","diamonds_4","diamonds_5","diamonds_6","diamonds_7","diamonds_8","diamonds_9","diamonds_10","diamonds_J","diamonds_Q","diamonds_K"]

let pokerCard = spades + clubs + hearts + diamonds

class ViewController: UIViewController {
    @IBOutlet var enemyPokerImg: [UIImageView]!
    @IBOutlet var myPokerImg: [UIImageView]!
    @IBOutlet weak var btnPass: UIButton!
    @IBOutlet weak var btnDeal: UIButton!
    let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: pokerCard.count - 1)
    @IBOutlet weak var chipLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var playerPointLabel: UILabel!
    @IBOutlet weak var enemyPointLabel: UILabel!
    @IBOutlet weak var imgPlayerMessage: UIImageView!
    @IBOutlet weak var imgEnemyMessage: UIImageView!
    
    var index = 0
    var property = 500000
    var chips = 0
    
    var playerCards = [""]
    var enemyCards = [""]
    
    var playerPoint = 0
    var enemyPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetUI()
        propertyLabel.text = "\(property)"
    }
    
    func countProperty(property: Int, chips: Int, mode: Int) -> Int {
        switch mode {
        case 1: // loss
            print(property - chips)
            return property - chips
        case 2: // win
            return property + chips
        case 3: // double loss
            return property - (2 * chips)
        case 4: // double win
            return property + (2 * chips)
        default:
            result(title: "窮鬼", message: "你破產了")
            return 500000
        }
    }
    
    func resetUI() {
        index = 0
        playerCards = [""]
        enemyCards = [""]
        playerPoint = 0
        enemyPoint = 0
        //property = 500000
        playerPointLabel.text = ""
        enemyPointLabel.text = ""
        imgPlayerMessage.isHidden = true
        imgEnemyMessage.isHidden = true
        for i in 0..<enemyPokerImg.count {
            enemyPokerImg[i].isHidden = true
        }
        for i in 0..<myPokerImg.count {
            myPokerImg[i].isHidden = true
        }
        btnPass.isEnabled = false
        btnDeal.isEnabled = true
    }
    
    func count(point: String) -> Int {
        if (point.contains("A")) {
            return 1
        } else if (point.contains("2")) {
            return 2
        } else if (point.contains("3")) {
            return 3
        } else if (point.contains("4")) {
            return 4
        } else if (point.contains("5")) {
            return 5
        } else if (point.contains("6")) {
            return 6
        } else if (point.contains("7")) {
            return 7
        } else if (point.contains("8")) {
            return 8
        } else if (point.contains("9")) {
            return 9
        } else {
            return 10
        }
    }
    
    func calculatePoints(for cards: [String]) -> Int {
        var points = 0
        var aceCount = 0
        
        for card in cards {
            let point = count(point: card)
            points += point
            if point == 1 {
                aceCount += 1
                points += 10
            }
        }
        
        while points > 21 && aceCount > 0 {
            points -= 10
            aceCount -= 1
        }
        
        return points
    }
    
    func isWin(playerPoint: Int, enemyPoint: Int = 0) {
        if (playerPoint > 21) {
            property = countProperty(property: property, chips: chips, mode: 1)
            print("\(property)")
            if (property <= 0) {
                propertyLabel.text = "\(property)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                    result(title: "窮鬼", message: "你破產了")
                    property = 500000
                    propertyLabel.text = "\(property)"
                }
                return
            } else {
                result(title: "遜咖", message: "你的點數爆炸了")
                propertyLabel.text = "\(property)"
                return
            }
        } else if (enemyPoint > 21) {
            result(title: "恭喜", message: "你贏了")
            property = countProperty(property: property, chips: chips, mode: 2)
            propertyLabel.text = "\(property)"
            return
        } else if (enemyPoint <= 21 && enemyPoint > playerPoint) {
            property = countProperty(property: property, chips: chips, mode: 1)
            if (property <= 0) {
                propertyLabel.text = "\(property)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                    result(title: "窮鬼", message: "你破產了")
                    property = 500000
                    propertyLabel.text = "\(property)"
                }
                return
            } else {
                result(title: "遜咖", message: "你輸了")
                propertyLabel.text = "\(property)"
                return
            }
        } else if (enemyPoint == playerPoint) {
            result(title: "可惜", message: "平手")
            return
        }
    }
    
    func isBlackJack(card1: String, card2: String) {
        if (card1.contains("A") && (card2.contains("J") || card2.contains("Q") || card2.contains("K") || card2.contains("10"))) {
            result(title: "恭喜", message: "Black Jack\n這把陽壽局")
            property = countProperty(property: property, chips: chips, mode: 4)
            propertyLabel.text = "\(property)"
        } else if (card2.contains("A") && (card1.contains("J") || card1.contains("Q") || card1.contains("K") || card1.contains("10"))) {
            result(title: "恭喜", message: "Black Jack\n這把陽壽局")
            property = countProperty(property: property, chips: chips, mode: 4)
            propertyLabel.text = "\(property)"
        }
    }
    
    func isEnemyBlackJack(card1: String, card2: String) -> Bool {
        if (card1.contains("A") && (card2.contains("J") || card2.contains("Q") || card2.contains("K") || card2.contains("10"))) {
            return true
        } else if (card2.contains("A") && (card1.contains("J") || card1.contains("Q") || card1.contains("K") || card1.contains("10"))) {
            return true
        }
        return false
    }
    
    func result(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
            resetUI()
        }
        controller.addAction(okAction)
        present(controller, animated: true)
    }
    
    @IBAction func dealCard(_ sender: UIButton) {
        imgPlayerMessage.isHidden = false
        if chips == 0 {
            let controller = UIAlertController(title: "警告", message: "下注金額為0", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                return
            }
            controller.addAction(okAction)
            present(controller, animated: true)
        } else {
            btnPass.isEnabled = true
            if (index == 0) {
                playerCards[0] = pokerCard[distribution.nextInt()]
                playerPoint = playerPoint + count(point: playerCards[0])
                playerPoint = calculatePoints(for: playerCards)
                playerCards.append(pokerCard[distribution.nextInt()])
                playerPoint = playerPoint + count(point: playerCards[1])
                playerPoint = calculatePoints(for: playerCards)
                
                myPokerImg[index].isHidden = false
                myPokerImg[index].image = UIImage(named: playerCards[0])
                myPokerImg[index + 1].isHidden = false
                myPokerImg[index + 1].image = UIImage(named: playerCards[1])
                isBlackJack(card1: playerCards[0], card2: playerCards[1])
                print(playerCards)
                print(String(playerPoint))
                playerPointLabel.text = String(playerPoint)
                
                enemyCards[0] = pokerCard[distribution.nextInt()]
                enemyPoint += count(point: enemyCards[0])
                enemyPoint = calculatePoints(for: enemyCards)
                enemyCards.append(pokerCard[distribution.nextInt()])
                enemyPoint += count(point: enemyCards[1])
                enemyPoint = calculatePoints(for: enemyCards)
                
                enemyPokerImg[index].isHidden = false
                enemyPokerImg[index].image = UIImage(named: "back")
                enemyPokerImg[index + 1].isHidden = false
                enemyPokerImg[index + 1].image = UIImage(named: enemyCards[1])
                print(enemyCards)
                print(String(enemyPoint))
                
                index += 1
            } else {
                playerCards.append(pokerCard[distribution.nextInt()])
                myPokerImg[index].isHidden = false
                myPokerImg[index].image = UIImage(named: playerCards[playerCards.count - 1])
                playerPoint = playerPoint + count(point: playerCards[playerCards.count - 1])
                playerPoint = calculatePoints(for: playerCards)
                
                isWin(playerPoint: playerPoint)
                print(playerCards)
                print(String(playerPoint))
                playerPointLabel.text = String(playerPoint)
            }
            if (index == myPokerImg.count - 1) {
                result(title: "恭喜", message: "過五關  你贏了")
                property = countProperty(property: property, chips: chips, mode: 4)
                propertyLabel.text = "\(property)"
            } else if  (playerPoint == 21) {
                result(title: "恭喜", message: "21點  你贏了")
                property = countProperty(property: property, chips: chips, mode: 2)
                propertyLabel.text = "\(property)"
            } else {
                index += 1 // index += 1 => index = index + 1
            }
        }
    }
    
    @IBAction func pass(_ sender: Any) {
        btnDeal.isEnabled = false
        imgEnemyMessage.isHidden = false
        var enemyIndex = 2

        enemyPokerImg[0].image = UIImage(named: enemyCards[0])
        enemyPointLabel.text = String(enemyPoint)
        if (isEnemyBlackJack(card1: enemyCards[0], card2: enemyCards[1])) {
            property = countProperty(property: property, chips: chips, mode: 3)
            if (property <= 0) {
                propertyLabel.text = "\(property)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    result(title: "窮鬼", message: "你破產了")
                    propertyLabel.text = "\(500000)"
                }
            } else {
                result(title: "殘念", message: "Black Jack\n對面用陽壽玩遊戲")
                propertyLabel.text = "\(property)"
            }
        } else {
            for i in 2..<enemyPokerImg.count {
                if (enemyPoint >= 21 || enemyPoint >= playerPoint) {
                    isWin(playerPoint: playerPoint, enemyPoint: enemyPoint)
                    break
                } else {
                    enemyCards.append(pokerCard[distribution.nextInt()])
                    enemyPokerImg[i].isHidden = false
                    enemyPokerImg[i].image = UIImage(named: enemyCards[enemyCards.count - 1])
                    enemyPoint = enemyPoint + count(point: enemyCards[enemyCards.count - 1])
                    enemyPoint = calculatePoints(for: enemyCards)
                    print(enemyCards)
                    print(String(enemyPoint))
                    enemyPointLabel.text = String(enemyPoint)
                }
                enemyIndex += 1
                print("\(enemyIndex) \(enemyCards.count-1)")
            }
            if enemyIndex == enemyCards.count && enemyPoint <= 21 {
                result(title: "殘念", message: "過五關\n對面用陽壽玩遊戲")
                propertyLabel.text = "\(property)"
            }
        }
    }

    @IBSegueAction func showMenu(_ coder: NSCoder) -> UIViewController? {
        let controller = SheetViewController(coder: coder)
        controller?.chips = property
        controller?.onSubmit = { [weak self] data in
            self?.chips = data
            self?.chipLabel.text = "\(self?.chips ?? 0)"
        }
        if let sheet = controller?.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                300
            })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 50
        }
        return controller
    }
}
