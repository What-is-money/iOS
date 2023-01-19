//
//  WholeSettingViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/03.
//

import UIKit


class WholeSettingViewController: UIViewController {

    @IBOutlet weak var ProfileView: UIView!
    
    @IBOutlet weak var AlertSwitch: UISwitch!
    
    @IBOutlet weak var QuestionView: UIView!
    
    @IBOutlet weak var PrivateInfView: UIView!
    
    @IBOutlet weak var LogoutView: UIView!
    
    @IBOutlet weak var WithDrawalView: UIView!
    
    override func viewDidLoad() {
    super.viewDidLoad()
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.goProfileEdit(sender:)))
    self.ProfileView.addGestureRecognizer(gesture1)
        let gesture4 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.goQuestion(sender:)))
        self.QuestionView.addGestureRecognizer(gesture4)
        let gesturealert1 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showSIAlert(sender:)))
        self.PrivateInfView.addGestureRecognizer(gesturealert1)
        let gesturealert2 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showLogoutAlert(sender:)))
        self.LogoutView.addGestureRecognizer(gesturealert2)
        let gesturealert3 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showWDAlert(sender:)))
        self.WithDrawalView.addGestureRecognizer(gesturealert3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func goProfileEdit(sender:UIGestureRecognizer){
           let storyboard  = UIStoryboard(name: "Main", bundle: nil)
           let profileEditViewController = storyboard.instantiateViewController(withIdentifier:"ProfileEditViewController")
           self.navigationController!.pushViewController(profileEditViewController, animated: true)
       }
 
    @objc func goQuestion(sender:UIGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let QuestionViewController = storyboard.instantiateViewController(withIdentifier: "QuestionViewController")
        self.navigationController!.pushViewController(QuestionViewController, animated: true)
        
    }
    
    @objc func showSIAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "개인정보 처리방침", message: "동의서 열람", preferredStyle: .alert)
        alert.addTextField { textField in
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500)
            textField.addConstraint(heightConstraint)
            textField.text = "여기에 개인정보 동의서 열람과 내용이 표시됩니다.\n 상당히 길 것으로 예측되는데 스크롤도 넣어야 할까요 아니면 그정도면 괜찮을까요"
            textField.isUserInteractionEnabled = false
        }
        
        let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
        let close = UIAlertAction(title: "닫기", style: .destructive, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showLogoutAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "로그아웃", style: .default, handler: nil)
        let close = UIAlertAction(title: "안나갈래요", style: .destructive, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showWDAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "회원탈퇴", message: "탈퇴하시는 이유가 무엇인가요?", preferredStyle: .alert)
        alert.addTextField { textField in
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
            textField.addConstraint(heightConstraint)
        }
        
        let confirm = UIAlertAction(title: "탈퇴", style: .default, handler: nil)
        let close = UIAlertAction(title: "안할래요", style: .destructive, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
  }
  
 


