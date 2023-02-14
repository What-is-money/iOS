//
//  FindIdPwViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/8/23.
//

import UIKit

class FindIdPwViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var IdInput: UITextField!
    @IBOutlet weak var EmailInputForPw: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailInput.delegate = self
        IdInput.delegate = self
        EmailInputForPw.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    @IBAction func findIDclicked(_ sender: UIButton) {
        guard let email = EmailInput.text else {return}
        func isValidEmail(testStr:String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: testStr)
        }
        if !isValidEmail(testStr: email) {
            let sheet = UIAlertController(title: "경고", message: "이메일 형식이 올바르지 않습니다", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("이메일 확인") }))
            
            present(sheet, animated: true)
        }
        
        guard let url = URL(string: "https://www.pigmoney.xyz/users/findUserId") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let email: String
        }
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        // Add data to the model
        let uploadDataModel = UploadData(email: email)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData

        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling POST")
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
                
                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        
                        if isSuccess == true {
      
                            let sheet = UIAlertController(title: "안내", message: "메일 발송 완료", preferredStyle: .alert)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            vc.modalPresentationStyle = .fullScreen
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                self.navigationController?.popToRootViewController(animated: true) }))
                            self.present(sheet, animated: true)
                            
                        } else {
                            let sheet = UIAlertController(title: "경고", message: "이메일이 올바르지 않습니다", preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("이메일 확인") }))
                            self.present(sheet, animated: true)
                        }
                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }
                
            }.resume()
            
        }
    }
    

    @IBAction func findPwClicked(_ sender: Any) {
        
        guard let id = IdInput.text else {return}
        guard let email = EmailInputForPw.text else {return}
        func isValidEmail(testStr:String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: testStr)
        }
        if !isValidEmail(testStr: email) {
            let sheet = UIAlertController(title: "경고", message: "이메일 형식이 올바르지 않습니다", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("이메일 확인") }))
            present(sheet, animated: true)
        }
        
        guard let url = URL(string: "https://www.pigmoney.xyz/users/findPassword") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let userId: String
            let email: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(userId: id, email: email)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData

        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling POST")
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
                        
                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        if isSuccess == true {
                   
                            let sheet = UIAlertController(title: "안내", message: "메일 발송 완료", preferredStyle: .alert)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            vc.modalPresentationStyle = .fullScreen
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                self.navigationController?.popToRootViewController(animated: true) }))
                            self.present(sheet, animated: true)
                            
                        } else {
                            let sheet = UIAlertController(title: "경고", message: "이메일 또는 아이디가 올바르지 않습니다", preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("비번정보 오류") }))
                            self.present(sheet, animated: true)
                        }
                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }
                
            }.resume()
        }
        
    }
}
