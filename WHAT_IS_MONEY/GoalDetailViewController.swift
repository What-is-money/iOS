//
//  GoalDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/18.
//

import UIKit
import Gifu
import AVFoundation


struct goalresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: goalresult

}

struct goaldeleteresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
}

class GoalDetailViewController: UIViewController {

    @IBOutlet weak var gifImageView: GIFImageView!
    
    @IBOutlet weak var gifImageView2: GIFImageView!
    
    @IBOutlet weak var kebapButton: UIButton!

    @IBOutlet weak var goalnameLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progresspercentageLabel: UILabel!
    
    @IBOutlet weak var goalamountlabel: UILabel!
    
    @IBOutlet weak var currentamountlabel: UILabel!
    
    @IBOutlet weak var initialamountLabel: UILabel!
    
    @IBOutlet weak var goalImageView: UIImageView!
    
    
    var goalIdx: Int = 0
    var goaldetail: goalresult?
    var goaldeleteresponse: goaldeleteresponse?
    
    var audioPlayer: AVAudioPlayer?
    let url = Bundle.main.url(forResource: "아기돼지공사배경", withExtension: "mp3")!
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillappear")
        TokenClass.handlingToken()
        print(goalIdx)
        getGoal()
        do {
             try audioPlayer = AVAudioPlayer(contentsOf: url)
             }catch {
                fatalError()
             }
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 5)
        gifImageView.animate(withGIFNamed: "목표화면배경3")
        gifImageView2.animate(withGIFNamed: "돼지뚝딱")
        getGoal()
        print(goaldetail?.category_name as Any)
        configureView()
      
        let showrecords = UIAction(title: "기록 보기", handler: { _ in
            guard let recordViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as? RecordViewController else {return}
            let goalIdx = self.goalIdx
           recordViewController.goalIdx = goalIdx
            print(recordViewController.goalIdx as Any)
           
            self.navigationController?.pushViewController(recordViewController, animated: true)})
        
        let addrecord = UIAction(title: "기록 추가하기", handler: { [self] _ in
            guard let writerecordViewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteRecordViewController") as? WriteRecordViewController else {return}
            let goalIdx = self.goalIdx
           writerecordViewController.goalIdx = goalIdx
            
            self.navigationController?.pushViewController(writerecordViewController, animated: true)})
 
        let editgoal = UIAction(title: "목표 수정하기", handler: { _ in
            
            guard let goalEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoalEditViewController") as? GoalEditViewController else {return}
            let goalIdx = self.goalIdx
            
            print(self.goalIdx)
            
           goalEditViewController.goalIdx = goalIdx
            
            print(goalEditViewController.goalIdx as Any)
            
            self.navigationController?.pushViewController(goalEditViewController, animated: true)
        })
        let deletegoal = UIAction(title: "목표 삭제하기", handler: { _ in
            
            self.deleteGoal()
            self.navigationController?.popViewController(animated: true)
            
            
            
        })
        let buttonMenu = UIMenu(title: "메뉴 타이틀", children: [showrecords, addrecord, editgoal, deletegoal])
       kebapButton.menu = buttonMenu
        
        
    }
    
    func getGoal(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/getGoal/\(goalIdx)/\(userIdx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return
                        }
                        
                        print("getgoall:" ,String(data: data, encoding: .utf8)!)
                        
                        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                            print("Error: HTTP request failed")
                            return
                        }
                        
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(goalresponse.self, from: data) {
                            self.goaldetail =  json.result
                            print(goaldetail as Any)
                            DispatchQueue.main.async {
                                self.configureView()
                            }
                            print("goaldetail!!!", goaldetail as Any)
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
            
            
        }
        
    }
    
    func deleteGoal(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/deleteGoal/\(goalIdx)/\(userIdx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "DELETE"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    
                    URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return
                        }
                        /*print("\n\n\n\n\n\n\n\n")
                        print("삭제왜안돼")
                        print(String(data: data, encoding: .utf8)!)
                        print("\n\n\n\n\n\n\n\n")*/
                        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                            print("Error: HTTP request failed")
                            return
                        }
                        
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(goalresponse.self, from: data) {
                            print(json.message)
                        }
                        
                    }.resume() //URLSession - end
                    
                    }
                }
            
        }
        
    }
    
    func configureView(){
        goalnameLabel.text = goaldetail?.category_name
        let data = Data(base64Encoded: goaldetail?.image ?? "알 수 없음", options: .ignoreUnknownCharacters) ?? Data()
        let decodeImg = UIImage(data: data)?.resized(toWidth: 143)
        goalImageView.image = decodeImg
        //goalImageView.alpha = CGFloat((goaldetail?.progress ?? 0.0) / 100)
        //progressView.progress = Float(goaldetail?.progress ?? 0.0)
        progressView.setProgress((goaldetail?.progress ?? 0.0)/100 , animated: true)
        progresspercentageLabel.text = "\(String(goaldetail?.progress ?? 0.0))%"
        goalamountlabel.text = String(goaldetail?.goal_amount ?? 0)
        currentamountlabel.text = String(goaldetail?.amount ?? 0)
        initialamountLabel.text = String(goaldetail?.init_amount ?? 0)
        
    }
    
}
