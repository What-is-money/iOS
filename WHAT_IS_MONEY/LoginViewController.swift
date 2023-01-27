//
//  LoginViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/8/23.
//

import UIKit

final class UserModel {
    struct User {
        var email: String
        var password: String
    }
    
    var users: [User] = [
        User(email: "abc1234@naver.com", password: "qwerty1234"),
        User(email: "dazzlynnnn@gmail.com", password: "asdfasdf5678")
    ]
    
    // 아이디 형식 검사
    func isValidEmail(id: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: id)
    }
    
    // 비밀번호 형식 검사
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
}

class LoginViewController: UIViewController {

    var userModel = UserModel()
    
    @IBOutlet weak var IDInput: UITextField!
    @IBOutlet weak var PWInput: UITextField!
    
    func loginCheck(id: String, pwd: String) -> Bool {
        for user in userModel.users {
            if user.email == id && user.password == pwd {
                return true
            }
        }
        return false
    }
    func shakeTextField(textField: UITextField) -> Void{
        UIView.animate(withDuration: 0.2, animations: {
            textField.frame.origin.x -= 10
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                textField.frame.origin.x += 20
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    textField.frame.origin.x -= 10
                })
            })
        })
    }
    @objc func didEndOnExit(_ sender: UITextField) {
        if IDInput.isFirstResponder {
            PWInput.becomeFirstResponder()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IDInput.addTarget(self, action: #selector(didEndOnExit), for: UIControl.Event.editingDidEndOnExit)
        PWInput.addTarget(self, action: #selector(didEndOnExit), for: UIControl.Event.editingDidEndOnExit)
      
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let id = IDInput.text else { return }
        guard let password = PWInput.text else { return }
        
        if userModel.isValidEmail(id: id){
            if let removable = self.view.viewWithTag(100) {
                removable.removeFromSuperview()
            }
        }
        else {
            shakeTextField(textField: IDInput)
//            let emailLabel = UILabel(frame: CGRect(x: 40, y: 305, width: 312, height: 30))
//            emailLabel.text = "이메일 형식을 확인해 주세요"
//            emailLabel.textColor = UIColor.red
//            emailLabel.tag = 100
//
//            self.view.addSubview(emailLabel)
        } //email 형식 오류
        
        if userModel.isValidPassword(pwd: password) {
            if let removable = self.view.viewWithTag(101) {
                removable.removeFromSuperview()
            }
        }
        else {
            shakeTextField(textField: PWInput)
//            let passwordLabel = UILabel(frame: CGRect(x: 40, y: 360, width: 312, height: 30))
//            passwordLabel.text = "비밀번호 형식을 확인해 주세요"
//            passwordLabel.textColor = UIColor.red
//            passwordLabel.tag = 101
//
//            self.view.addSubview(passwordLabel)
        }
        if userModel.isValidEmail(id: id) && userModel.isValidPassword(pwd: password) {
            let loginSuccess: Bool = loginCheck(id: id, pwd: password)
            if loginSuccess {
                print("로그인 성공")
                if let removable = self.view.viewWithTag(102) {
                    removable.removeFromSuperview()
                }
                self.performSegue(withIdentifier: "Welcome", sender: self)
            }
            else {
                print("로그인 실패")
                shakeTextField(textField: IDInput)
                shakeTextField(textField: PWInput)
                let loginFailLabel = UILabel(frame: CGRect(x: 68, y: 510, width: 279, height: 45))
                loginFailLabel.text = "아이디나 비밀번호가 다릅니다."
                loginFailLabel.textColor = UIColor.red
                loginFailLabel.tag = 102
                    
                self.view.addSubview(loginFailLabel)
            }
        }
        
    }

        @IBAction func LoginClicked(_ sender: UIButton) {
            guard let url = URL(string: "https://www.pigmoney.xyz/test/log") else {
                    print("Error: cannot create URL")
                    return
                }
                // Create the url request
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil else {
                        print("Error: error calling GET")
                        print(error!)
                        return
                    }
                    guard let data = data else {
                        print("Error: Did not receive data")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                    
                }.resume()
            }
        
        
       
    
}
