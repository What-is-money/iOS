//
//  AgreePrivacyPolicyViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/8/23.
//

import UIKit

class AgreePrivacyPolicyViewController: UIViewController {

    struct RegisterData: Codable {
        let userId: String
        let password: String
        let confirmPassword: String
        let name: String
        let email: String
        let agree: Bool
        let idCheck: Bool
    }

    var userId: String?
    var password: String?
    var confirmPassword: String?
    var name: String?
    var email: String?
    var agree: Bool?
    var idCheck: Bool?
    
    @IBOutlet weak var AgreeBtn: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.AgreeBtn.addTarget(self, action: #selector(self.popAlert), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    @objc func popAlert() {
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        alert.modalPresentationStyle = .overFullScreen
        present(alert, animated: false, completion: nil)
    }
    
    @IBAction func AgreeClicked(_ sender: UIButton) {
        let uploadDataModel = RegisterData(userId: userId!, password: password!, confirmPassword: confirmPassword!, name: name!, email: email!, agree: true, idCheck: true)
        print(uploadDataModel)
        guard let url = URL(string: "https://www.pigmoney.xyz/users/signup") else {
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
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData
        print(String(data: jsonData, encoding: .utf8)!)
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
                print(String(data: data, encoding: .utf8)!)
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return
                }
                
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
                    print(prettyPrintedJson)
                    let isSuccess = jsonObject["isSuccess"] as? Bool
                    if isSuccess == true {
                        print("회원가입 성공")
                        
                    } else {
                        let sheet = UIAlertController(title: "경고", message: "올바른 형식으로 입력하였는지 확인해주세요", preferredStyle: .alert)
                        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("형식 확인") }))
                        self.present(sheet, animated: true)
                    }
                } catch {
                    print("Error: Trying to convert JSON data to string")
                    return
                }
                
                
            }.resume()
            
        }
     
    }
    
}
