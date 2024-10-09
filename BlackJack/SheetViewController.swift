//
//  SheetViewController.swift
//  BlackJack
//
//  Created by Han on 2024/8/4.
//
import UIKit

class SheetViewController: UIViewController {
    @IBOutlet weak var chipsLabel: UILabel!
    @IBOutlet weak var inputChips: UITextField!
    
    var onSubmit: ((Int) -> Void)?
    var chips: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipsLabel.text = "\(chips ?? 0)"
    }
    @IBAction func pay(_ sender: Any) {
        guard let text = Int(inputChips.text!) else {
            inputChips.placeholder = "金額為0  請輸入下注金額"
            return
        }
        onSubmit?(text)
        dismiss(animated: true, completion: nil)
    }
}
