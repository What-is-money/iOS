//
//  ChangeIDViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class ChangeIDViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentIdLabel: UILabel!
    @IBOutlet weak var newId: UITextField!
    @IBOutlet weak var IdCheckBtn: UIButton!
    
    @IBOutlet weak var IdCheckLabel: UILabel!
    
    var isIdChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newId.delegate = self
        getUserID()
        self.newId.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
    }

    @objc func textFieldDidChange(_ sender: Any?) {
        self.IdCheckBtn.isEnabled = true
    }
    func getUserID() {
        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        guard let url = URL(string: "https://www.pigmoney.xyz/users/\(useridx)") else {
                print("Error: cannot create URL")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
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
                        
                        self.currentIdLabel.text = result

                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }

            }.resume()
    }
    @IBAction func checkIDValidation(_ sender: UIButton) {
        guard let id = newId.text, !id.isEmpty else { return }
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
                            self.IdCheckLabel?.text = "사용가능한 아이디입니다."
                            self.IdCheckBtn.isEnabled = false
                            self.isIdChecked = true
                            print("사용가능한 아이디입니다.")
                        } else if result == "이미 사용중인 아이디입니다." {
                            self.IdCheckLabel?.text = "이미 사용중인 아이디입니다."
                            print("이미 사용중인 아이디입니다.")
                        } else {
                            self.IdCheckLabel?.text = "아이디 형식이 올바르지 않습니다."
                        }
                        
                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }
                
            }.resume()
    }
    
    @IBAction func changeIDCompleted(_ sender: UIButton) {
        guard let id = newId.text, !id.isEmpty else { return }
        if isIdChecked == false {
            let sheet = UIAlertController(title: "경고", message: "아이디 중복확인을 진행해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("아이디중복 확인") }))
            present(sheet, animated: true)
        }
        
        // Create model
        struct UploadData: Codable {
            let userIdx: Int
            let newUserId: String
            let idCheck: Bool
        }
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        let uploadDataModel = UploadData(userIdx: userIdx, newUserId: id, idCheck: true)
        
        guard let url = URL(string: "https://www.pigmoney.xyz/users/modifyUserId") else {
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
    
                            let sheet = UIAlertController(title: "안내", message: "아이디 변경 완료", preferredStyle: .alert)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            vc.modalPresentationStyle = .fullScreen
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                //self.navigationController?.pushViewController(vc, animated: true)
                                self.navigationController?.popToRootViewController(animated: true)
                                
                            }))
                            self.present(sheet, animated: true)
                            
                        } else {
                            let sheet = UIAlertController(title: "경고", message: "아이디 변경 오류", preferredStyle: .alert)
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

