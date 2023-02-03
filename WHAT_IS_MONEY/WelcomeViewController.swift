//
//  WelcomeViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/03.
//

import UIKit
import SwiftUI

class WelcomeViewController: UIViewController {

    @IBOutlet weak var IntroLabel: UILabel!
    @IBOutlet weak var ProfileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      navigationController?.isNavigationBarHidden = true // 뷰 컨트롤러가 나타날 때 숨기기
        TokenClass.handlingToken()
    }

    func getUser() {
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
                
                            let image = result ["image"] as! String
                            print(result)
                            
                            let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters) ?? Data()
                            var decodeImg = UIImage(data: data)
                            decodeImg = decodeImg?.resized(toWidth: 90.0) ?? decodeImg
                            self.ProfileImg.image = decodeImg
                        self.IntroLabel.text = "\(name ?? "머니뭐니")님, 어서오세요!"

                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }

            }.resume()
    }
    
    

   
}
