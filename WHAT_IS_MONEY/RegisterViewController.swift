//
//  RegisterViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/8/23.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var NameInput: UITextField!
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var IDInput: UITextField!
    @IBOutlet weak var PWInput: UITextField!
    @IBOutlet weak var ConfirmPWInput: UITextField!
    @IBOutlet weak var IDCheckLabel: UILabel!
    @IBOutlet weak var IDCheckBtn: UIButton!
    
    var isIdChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NameInput.delegate = self
        EmailInput.delegate = self
        IDInput.delegate = self
        PWInput.delegate = self
        ConfirmPWInput.delegate = self
        
        self.IDInput.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        self.IDCheckBtn.isEnabled = true
    }
        @IBAction func checkIDValidation(_ sender: UIButton) {
            guard let id = IDInput.text, !id.isEmpty else { return }
            guard let url = URL(string: "https://www.pigmoney.xyz/users/idCheck/\(id)") else {
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
                    
            
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                        print("Error: HTTP request failed")
                        return
                    }
                    DispatchQueue.main.async {
                        do {
                            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                print("Error: Cannot convert data to JSON object")
                                return
                            }
                            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                                print("Error: Cannot convert JSON object to Pretty JSON data")
                                return
                            }
                            guard String(data: prettyJsonData, encoding: .utf8) != nil else {
                                print("Error: Couldn't print JSON in String")
                                return
                            }
                            
                            let result = jsonObject["result"] as? String
                            if result == "사용가능한 아이디입니다!" {
                                self.IDCheckLabel?.text = "사용가능한 아이디입니다."
                                self.IDCheckBtn.isEnabled = false
                                self.isIdChecked = true
                     
                            } else if result == "이미 사용중인 아이디입니다." {
                                self.IDCheckLabel?.text = "이미 사용중인 아이디입니다."
                        
                            } else {
                                self.IDCheckLabel?.text = "아이디 형식이 올바르지 않습니다."
                            }
                            
                        } catch {
                            print("Error: Trying to convert JSON data to string")
                            return
                        }
                    }
                    
                }.resume()
        }
    
    @IBAction func RegisterClicked(_ sender: UIButton) {
        guard let name = NameInput.text else { return }
        guard let email = EmailInput.text else { return }
        guard let id = IDInput.text else { return }
        guard let pw = PWInput.text else { return }
        guard let confirmPw = ConfirmPWInput.text else { return }
        
        if name.isEmpty || email.isEmpty || id.isEmpty || pw.isEmpty || confirmPw.isEmpty {
            let sheet = UIAlertController(title: "경고", message: "모든 입력칸에 올바르게 입력하였는지 확인해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
        }
        func isValidEmail(testStr:String) -> Bool {
              let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
              let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
              return emailTest.evaluate(with: testStr)
        }
        func isValidPassword(testStr:String) -> Bool {
              let passwordRegEx = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"
              let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
              return passwordTest.evaluate(with: testStr)
        }
        if !isValidEmail(testStr: email) {
            let sheet = UIAlertController(title: "경고", message: "이메일 형식이 올바르지 않습니다", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("이메일 확인") }))
            present(sheet, animated: true)
        }
        if !isValidPassword(testStr: pw) {
            let sheet = UIAlertController(title: "경고", message: "비밀번호는 8~16자 영문 대 소문자, 숫자, 특수문자를 사용하세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("비밀번호 확인") }))
            present(sheet, animated: true)
        }
        if pw != confirmPw {
            let sheet = UIAlertController(title: "경고", message: "비밀번호가 서로 일치하지 않습니다", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("비밀번호 일치 확인") }))
            print("비밀번호가 서로 일치하지 않습니다.")
            present(sheet, animated: true)
        }
        if isIdChecked == false {
            let sheet = UIAlertController(title: "경고", message: "아이디 중복확인을 진행해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("아이디중복 확인") }))
            present(sheet, animated: true)
        }

        // Create model
        struct RegisterData: Codable {
            let userId: String
            let password: String
            let confirmPassword: String
            let name: String
            let email: String
            let agree: Bool
            let idCheck: Bool
        }
        
        
        guard let vc = storyboard?.instantiateViewController(identifier: "AgreePrivacyPolicyViewController") as? AgreePrivacyPolicyViewController else { return }
        vc.userId = id
        vc.password = pw
        vc.confirmPassword = confirmPw
        vc.name = name
        vc.email = email

        self.navigationController?.pushViewController(vc, animated: true)
        
       
    }
       
    
}
