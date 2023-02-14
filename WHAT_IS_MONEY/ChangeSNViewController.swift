//
//  ChangeSNViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class ChangeSNViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPWInput: UITextField!
    @IBOutlet weak var PWConfirmInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        newPWInput.delegate = self
        PWConfirmInput.delegate = self
    
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
    
    @IBAction func changePWCompleted(_ sender: UIButton) {
        guard let pw = newPWInput.text, !pw.isEmpty else { return }
        guard let confirmpw = PWConfirmInput.text else { return }
        if pw.isEmpty || confirmpw.isEmpty {
            let sheet = UIAlertController(title: "경고", message: "모든 입력칸에 올바르게 입력하였는지 확인해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
        }
        
        func isValidPassword(testStr:String) -> Bool {
              let passwordRegEx = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"
              let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
              return passwordTest.evaluate(with: testStr)
        }
        if !isValidPassword(testStr: pw) {
            let sheet = UIAlertController(title: "경고", message: "비밀번호는 8~16자 영문 대 소문자, 숫자, 특수문자를 사용하세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("비밀번호 확인") }))
            present(sheet, animated: true)
        }
        if pw != confirmpw {
            let sheet = UIAlertController(title: "경고", message: "비밀번호가 서로 일치하지 않습니다", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("비밀번호 일치 확인") }))
            print("비밀번호가 서로 일치하지 않습니다.")
            present(sheet, animated: true)
        }
        // Create model
        struct UploadData: Codable {
            let userIdx: Int
            let newPassword: String
            let confirmNewPassword: String
        }
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        let uploadDataModel = UploadData(userIdx: userIdx, newPassword: pw, confirmNewPassword: confirmpw)
        
        guard let url = URL(string: "https://www.pigmoney.xyz/users/modifyPassword") else {
            print("Error: cannot create URL")
            return
        }
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
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
                        guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                            print("Error: Cannot convert JSON object to Pretty JSON data")
                            return
                        }
                        guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                            print("Error: Couldn't print JSON in String")
                            return
                        }

                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        if isSuccess == true {
                            let sheet = UIAlertController(title: "안내", message: "비밀번호 변경 완료", preferredStyle: .alert)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            vc.modalPresentationStyle = .fullScreen
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                self.navigationController?.popToRootViewController(animated: true) }))
                            self.present(sheet, animated: true)
                            
                        } else {
                            let sheet = UIAlertController(title: "경고", message: "비번 변경 오류", preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("변경 오류") }))
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
