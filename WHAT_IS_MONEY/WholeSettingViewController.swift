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
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserIDLabel: UILabel!
    
    @IBOutlet weak var ProfileImg: UIImageView!
    
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
        TokenClass.handlingToken()
        getUserInfo()
    }

    func getUserInfo() {
        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        print(useridx)
        guard let url = URL(string: "https://www.pigmoney.xyz/users/profile/\(useridx)") else {
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

                print(String(data: data, encoding: .utf8)!)
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

                       
                    guard let result = jsonObject ["result"] as? [String: Any]
                        else { return }
                        let name = result ["name"] as? String
                        let id = result ["userId"] as? String
                        let image = result ["image"] as? String
                      
                        print(result)
                    
                        if (image?.count == 0 || image == nil) {
                            self.ProfileImg.image = UIImage(named: "jinperson")
                            
                        } else {
                            if let data = Data(base64Encoded: image!, options: .ignoreUnknownCharacters) {
                                let decodedImg = UIImage(data: data)
                                self.ProfileImg.layer.cornerRadius = self.ProfileImg.frame.height/2
                                self.ProfileImg.layer.borderWidth = 1
                                self.ProfileImg.layer.borderColor = UIColor.clear.cgColor
                                // 뷰의 경계에 맞춰준다
                                self.ProfileImg.clipsToBounds = true
                                self.ProfileImg.image = decodedImg
                                print("img attached")
                                
                            }
                        }
                        self.UserNameLabel.text = name
                        self.UserIDLabel.text = id
                     

                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }

            }.resume()
    }
    
    @objc func goProfileEdit(sender:UIGestureRecognizer){
           let storyboard  = UIStoryboard(name: "Main", bundle: nil)
           let profileEditViewController = storyboard.instantiateViewController(withIdentifier:"ProfileEditViewController")
           self.navigationController!.pushViewController(profileEditViewController, animated: true)
       }
 
    @IBAction func toggleClicked(_ sender: UISwitch) {
        print(AlertSwitch.isOn)
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        guard let url = URL(string: "https://www.pigmoney.xyz/users/alarm") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let userIdx: Int
            let alarm: Bool
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(userIdx: userIdx, alarm: AlertSwitch.isOn)
        
        
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
                        print(prettyPrintedJson)
                        
                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        let result = jsonObject["result"] as? String
                        if isSuccess == true {
                            let sheet = UIAlertController(title: "안내", message: result, preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                                print("알림설정") }))
                            self.present(sheet, animated: true)
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
    
    @objc func goQuestion(sender:UIGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let QuestionViewController = storyboard.instantiateViewController(withIdentifier: "QuestionViewController")
        self.navigationController!.pushViewController(QuestionViewController, animated: true)
        
    }
    
    @objc func showSIAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "개인정보 처리방침", message: "동의서 열람\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.autoresizesSubviews = true
        let textView = UITextView()
        alert.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false

        let leadConstraint = NSLayoutConstraint (item: alert.view!, attribute: .leading, relatedBy: .equal, toItem: textView, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailConstraint = NSLayoutConstraint (item: alert.view!, attribute: .trailing, relatedBy: .equal, toItem: textView, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let topConstraint = NSLayoutConstraint (item: alert.view!, attribute: .top, relatedBy: .equal, toItem: textView, attribute: .top, multiplier: 1.0, constant: -64.0)
        let bottomConstraint = NSLayoutConstraint (item: alert.view!, attribute: .bottom, relatedBy: .equal, toItem: textView, attribute: .bottom, multiplier: 1.0, constant: 64.0)

        textView.text = """
        1. 입력받는 정보
            * 가.정보항목
               * 이름, 사용자가 입력한 아이디와 비밀번호, 사용자가 직접 입력한 지출과 저축 내역, 업로드된 사진
            * 나.입력방법 사용자가 컨텐츠 내 텍스트 필드에 직접 입력
        2. 개인정보의 이용목적과 수집 및 제공 정보
            * 가.이용 목적
                * 서비스(회원가입, ID/PW찾기 등)이용을 위한 본인인증
                * 이전달과 이번달의 금융내역 비교 활용
                    * 지출과 저축 내역 파악 및 정리
            * 나. 수집 및 제공하는 정보
                * IP주소, 사용자 월별 소비 및 저축 내역
        3. 개인정보의 보유 및 이용기간
         이용자의 개인정보는 원칙적으로 개인정보의 수집 및 이용목적이 달성되면 지체없이 파기합니다. 회원탈퇴 시 즉각적으로 가입자의 정보가 파기됩니다.
        """
        
        NSLayoutConstraint.activate([leadConstraint, trailConstraint, topConstraint, bottomConstraint])

        let Done = UIAlertAction(title: "확인", style: .default) { (action:UIAlertAction) in
            NSLog("%@", textView.text)
        }
        alert.addAction(Done)

        self.present(alert, animated: true, completion: nil)
           
    }
    
    @objc func showLogoutAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "로그아웃", style: .destructive, handler: {(_) -> Void in
            print("Ok button tapped")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")
            let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
            
            guard let url = URL(string: "https://www.pigmoney.xyz/users/logout") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct UploadData: Codable {
                let accessToken: String
                let refreshToken: String
            }
            
            // Add data to the model
            let uploadDataModel = UploadData(accessToken: accessToken!, refreshToken: refreshToken!)
            
            
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
                            print(prettyPrintedJson)
                            
                            let isSuccess = jsonObject["isSuccess"] as? Bool
                            
                            if isSuccess == true {
                                print("로그아웃 완료")
                                UserDefaults.standard.removeObject(forKey: "userIdx") //제거
                                UserDefaults.standard.removeObject(forKey: "accessToken") //제거
                                UserDefaults.standard.removeObject(forKey: "refreshToken") //제거
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                vc.modalPresentationStyle = .fullScreen
                                print(UserDefaults.standard.dictionaryRepresentation())
                                self.present(vc, animated: true)
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
        
        })

        let close = UIAlertAction(title: "안나갈래요", style: .default, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
                                    
    @objc func showWDAlert(sender:UIGestureRecognizer){

        let attributedString = NSAttributedString(string: "그동안 열심히 노력하신 목표와 여러분의 일꾼 아기돼지들을 다신 볼 수 없습니다. \n 그래도 탈퇴하시겠습니까?", attributes: [
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                    NSAttributedString.Key.foregroundColor : UIColor.red
                ])
        let alert = UIAlertController(title: "경고", message: "그동안 열심히 노력하신 목표와 여러분의 일꾼 아기돼지들을 다신 볼 수 없습니다. 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedMessage")
        let confirm = UIAlertAction(title: "탈퇴", style: .destructive, handler: {(_) -> Void in
            print("Ok button tapped")
            let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")
    
            
            guard let url = URL(string: "https://www.pigmoney.xyz/users/deleteUser") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct UploadData: Codable {
                let userIdx: Int
            }
            
            // Add data to the model
            let uploadDataModel = UploadData(userIdx: userIdx)
            
            
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
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
                            print(prettyPrintedJson)
                            
                            let isSuccess = jsonObject["isSuccess"] as? Bool
                            
                            if isSuccess == true {
                                print("회원탈퇴 완료")
                                UserDefaults.standard.removeObject(forKey: "userIdx") //제거
                                UserDefaults.standard.removeObject(forKey: "accessToken") //제거
                                UserDefaults.standard.removeObject(forKey: "refreshToken") //제거
                                let sheet = UIAlertController(title: "안내", message: "안전하게 회원탈퇴 되었습니다", preferredStyle: .alert)
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                vc.modalPresentationStyle = .fullScreen
                                sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                    self.present(vc, animated: true) }))
                                self.present(sheet, animated: true)
                                print(UserDefaults.standard.dictionaryRepresentation())
                                
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
        
        })
        let close = UIAlertAction(title: "안할래요", style: .default, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
  }
  

