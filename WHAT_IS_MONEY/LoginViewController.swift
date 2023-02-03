//
//  LoginViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/8/23.
//

import UIKit
import Foundation

final class UserModel {
    struct User : Codable {
        var userId: String
        var password: String
    }
    
//    var users: [User] = [
//        User(email: "abc1234@naver.com", password: "qwerty1234"),
//        User(email: "dazzlynnnn@gmail.com", password: "asdfasdf5678")
//    ]
//
    
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
final class ResponseModel {
    struct UserData : Codable {
        var refreshToken: String
        var accessToken: String
        var userIdx: Int
        var accessTokenExpirationTime: Date
    }
}
struct UserStorage : Codable {
    static let userIdx = 0
    static let refreshToken = ""
    static let accessToken = ""
}
struct ResultData: Codable {
    static let userIdx = 0
    static let refreshToken = "".self
    static let accessToken = ""
}
//struct ResponseData : Codable {
//     let message: String
//   let result: AnyObject
//    let code: Int
//     let isSuccess: Bool
//}
final class TokenClass {
    class func handlingToken() {
        // AccessToken의 만료 기간이 지나거나, 30초 미만으로 남았거나 응답코드가 401에러면, Reissue 요청
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        let accessTokenExpirationTime = UserDefaults.standard.object(forKey: "accessTokenExpirationTime") as? Date ?? Date()
        let refreshTokenExpirationTime = UserDefaults.standard.object(forKey: "refreshTokenExpirationTime") as? Date ?? Date()
        let now = Date()
        let before30sec = accessTokenExpirationTime - 30 // 만료시간 30초 전
//        print("현재 시간, 만료시간, refresh만료시간", now, accessTokenExpirationTime, refreshTokenExpirationTime)
//        print(now>accessTokenExpirationTime, now>before30sec)
        if now > refreshTokenExpirationTime - 30 {
            print("로그인 유효기간 만료")
            UserDefaults.standard.removeObject(forKey: "userIdx") //제거
            UserDefaults.standard.removeObject(forKey: "accessToken") //제거
            UserDefaults.standard.removeObject(forKey: "refreshToken") //제거
            let loginVC = UIStoryboard(name: "LoginViewController", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.present(loginVC, animated: true)
        }
//        now > accessTokenExpirationTime ||
        // 만료 시간 30초전에 reissue post
        if now > before30sec {
            guard let url = URL(string: "https://www.pigmoney.xyz/users/reissue") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct TokenData: Codable {
                let accessToken : String
                let refreshToken : String
            }

            // Add data to the model
            let tokenDataModel = TokenData(accessToken: accessToken!, refreshToken: refreshToken!)
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(tokenDataModel) else {
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
            print("리이슈 요청 바디",String(data: jsonData, encoding: .utf8)!)
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
                            print("reissue pretty json",prettyPrintedJson)

                            let isSuccess = jsonObject["isSuccess"] as? Bool

                            if isSuccess == true {
                                print("reissue 성공")

                                guard let result = jsonObject ["result"] as? [String: Any],
                                      let newAccessToken = result ["newAccessToken"] as? String,
                                      let accessTokenExpirationTime = result ["accessTokenExpirationTime"] as? Double
                                else { return }
                                print("result, newAccessToken, accessTokenExpirationTime", result, newAccessToken, accessTokenExpirationTime)
                                let exTimeToSec = accessTokenExpirationTime / 1000 // change ms to s

                                let expireTime = Date().addingTimeInterval(exTimeToSec) // 현시간 + 토큰 만료시간 (최종만료시간 계산)

                                // new access token, expire time update
                                UserDefaults.standard.set(newAccessToken, forKey: "accessToken")
                                UserDefaults.standard.set(expireTime, forKey: "accessTokenExpirationTime")

                                print("new UserDefaults set",UserDefaults.standard.dictionaryRepresentation())

                            } else {
                                print("reissue error")
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
}
class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var IDInput: UITextField!
    @IBOutlet weak var PWInput: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    
    var successed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func popStartScreen() {
        let start = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        start.modalPresentationStyle = .overFullScreen
        present(start, animated: true, completion: nil)
        
    }
    
    @IBAction func LoginClicked(_ sender: UIButton) {
        guard let id = IDInput.text else {return}
        guard let password = PWInput.text else {return}
        let uploadDataModel = UserModel.User(userId: id, password: password)
        
        if id.isEmpty || password.isEmpty {
            let sheet = UIAlertController(title: "경고", message: "아이디 또는 비밀번호를 입력해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
        }
        guard let url = URL(string: "https://www.pigmoney.xyz/users/login") else {
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
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "X-ACCESS-TOKEN")
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
                        self.successed = true
                        if isSuccess == true {
                            print("로그인 성공")
                            self.successed = true
                            
                            
                            guard let result = jsonObject ["result"] as? [String: Any],
                                  let userIdx = result ["userIdx"] as? Int,
                                  let tokenDto = result ["tokenDto"] as? [String: Any],
                                  let refreshToken = tokenDto ["refreshToken"] as? String,
                                  let accessToken = tokenDto ["accessToken"] as? String,
                                  let accessTokenExpirationTime = tokenDto["accessTokenExpirationTime"] as? Double,
                                  let refreshTokenExpirationTime = tokenDto["refreshTokenExpirationTime"] as? Double
                                    
                            else { return }
                            
                            let exTimeToSec = accessTokenExpirationTime / 1000 // change ms to s
                            let refTimeToSec = refreshTokenExpirationTime / 1000
                            let now = Date()
                            let expireTime = Date().addingTimeInterval(exTimeToSec) // 현시간 + 토큰 만료시간 (최종만료시간 계산)
                            let refreshExpireTime = Date().addingTimeInterval(refTimeToSec)
                            print("만료시간:", expireTime)
                            print("refresh만료시간", refreshExpireTime)
                            print("현재시간:", now)

                            
                            let Response = ResponseModel.UserData(refreshToken: refreshToken, accessToken: accessToken, userIdx: userIdx, accessTokenExpirationTime: expireTime)
                            print(Response)
                            print(Response.userIdx, Response.refreshToken)
                            
                            let defaults = UserDefaults.standard
                            func putData() {
                                defaults.set(Response.userIdx, forKey: "userIdx")
                                defaults.set(Response.accessToken, forKey: "accessToken")
                                defaults.set(Response.refreshToken, forKey: "refreshToken")
                                defaults.set(Response.accessTokenExpirationTime, forKey: "accessTokenExpirationTime")
                            }
                            putData()
                            UserDefaults.standard.set(expireTime, forKey: "accessTokenExpirationTime")
                            UserDefaults.standard.set(refreshExpireTime, forKey: "refreshTokenExpirationTime")
                            print(UserDefaults.standard.dictionaryRepresentation())
                            
                            
                            self.popStartScreen()
                        } else {
                            let sheet = UIAlertController(title: "경고", message: "아이디 또는 비밀번호가 올바르지 않습니다", preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("형식 확인") }))
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
