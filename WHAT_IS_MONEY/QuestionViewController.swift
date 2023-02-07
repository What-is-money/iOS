//
//  QuestionViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class QuestionViewController: UIViewController, UITextViewDelegate {
    let textViewPlaceHolder = "내용을 입력해주세요"
    
    @IBOutlet weak var questionView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        questionView.layer.borderWidth = 0.5
        questionView.layer.cornerRadius = 5.0
        questionView.textContainerInset = UIEdgeInsets(top: 17.0, left: 5.0, bottom: 16.0, right: 16.0)
        questionView.font = .systemFont(ofSize: 12)
        questionView.text = textViewPlaceHolder
        questionView.textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    }
}
