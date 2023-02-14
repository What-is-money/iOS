//
//  QuestionViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class QuestionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    let textViewPlaceHolder = ""
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var ContentsTextField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailTextField.delegate = self
        ContentsTextField.delegate = self
        questionView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        questionView.layer.borderWidth = 0.5
        questionView.layer.cornerRadius = 5.0
        questionView.textContainerInset = UIEdgeInsets(top: 17.0, left: 5.0, bottom: 16.0, right: 16.0)
        questionView.font = .systemFont(ofSize: 12)
        questionView.text = textViewPlaceHolder
        questionView.textColor = UIColor.black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    @IBAction func BtnClicked(_ sender: UIButton) {
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        guard let email = EmailTextField.text else {return}
        guard let content = ContentsTextField.text else  {return}
        let now = Date().toString()
   
        if email.isEmpty || content.isEmpty {
            let sheet = UIAlertController(title: "경고", message: "모든 입력칸에 올바르게 입력하였는지 확인해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
        }
        
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
        
        guard let url = URL(string: "https://www.pigmoney.xyz/users/question") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let userIdx: Int
            let email: String
            let content: String
            let createdAt: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(userIdx: userIdx, email: email, content: content, createdAt: now)
        
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
              
                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        
                        if isSuccess == true {
                            let sheet = UIAlertController(title: "안내", message: "문의사항이 접수되었습니다", preferredStyle: .alert)
                            self.present(sheet, animated: true)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                self.navigationController!.popViewController(animated: true)}))
                            

                            
                        } else {
                          print("오류 발생")
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
