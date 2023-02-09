//
//  FixedRecordDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/17.
//

import UIKit
import DropDown

struct existresponse: Codable {
    
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: existresult
    
}

struct existresult: Codable {
    let goalIdx: Int
    let date: String
    let type: Int
    let category: String
    let amount: Int
    
    
}

struct patchrecord: Codable {
    let userIdx: Int
    let recordIdx: Int
    let date: String
    let categoryIdx: Int
    let amount: Int
    
}

class FixedRecordViewController: UIViewController {
    
    @IBOutlet weak var RecordDatePicker: UIDatePicker!
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var ConsumeButton: UIButton!
    
    @IBOutlet weak var MoneyTextField: UITextField!
    

    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var tfInput: UITextField!
    
    @IBOutlet weak var ivIcon: UIImageView!
    
    @IBOutlet weak var btnSelect: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillappear")
        TokenClass.handlingToken()
        self.getRecord()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadcategory()
        self.getRecord()
        self.initUI()
        self.setDropdown()
    }
    
    var recordIdx: Int?
    var goalIdx: Int?
    
    var resultlist: [categoryresultdetail] = []
    // DropDown 아이템 리스트
    var itemList0: [String] = []
    var itemList1: [String] = []
    
    var flag: Int?
    var existresult1: existresult?
    
    private var diaryDate: Date? 
    private var recordtype: String?
    private var categorytype: String?
    private var moneyAmount: String?
    private var categoryname: String?
    
    func observeresultlist(){
        
        itemList0.removeAll()
        itemList1.removeAll()
        
        for resultone in resultlist {
            if resultone.flag == 0 {
                itemList0.append(resultone.category_name)
                
            } else {
                
                itemList1.append(resultone.category_name)
                
            }
            
            
        }
        
    }
    
    func findcategoryid(categoryname: String) -> Int {
        for resultlistone in resultlist {
            if resultlistone.category_name == categoryname {
                return resultlistone.categoryIdx
            }
        }
        return 0
    }
        
    func patchRecord() {
        
        // 넣는 순서도 순서대로여야 하는 것 같다.
        let patchrecord = patchrecord(userIdx: UserDefaults.standard.integer(forKey: "userIdx"), recordIdx: recordIdx!, date: self.RecordDatePicker.date.toString(), categoryIdx: self.findcategoryid(categoryname: categoryname ?? "알 수 없음"), amount: Int(MoneyTextField.text ?? "0" ) ?? 0)
        
        guard let uploadData = try? JSONEncoder().encode(patchrecord)
        else {return}
        
        // URL 객체 정의
        let url = URL(string: "https://www.pigmoney.xyz/records")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "PATCH"
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        
        DispatchQueue.global().async {
            do {
                // URLSession 객체를 통해 전송, 응답값 처리
                URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
                    
                    // 서버가 응답이 없거나 통신이 실패
                    if let e = error {
                        NSLog("An error has occured: \(e.localizedDescription)")
                        return
                    }
                       // 응답 처리 로직
                     guard let data = data else {
                         print("Error: Did not receive data")
                         return
                     }
                     
                    // print(String(data: data, encoding: .utf8)!)
                     guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                         print("Error: HTTP request failed")
                         return
                     }
                     /*
                     // data
                     let decoder = JSONDecoder()
                     if let json = try? decoder.decode(responseP.self, from: data) {
                     print(json.result.goalIdx)
                     }
                     
                     */
                    // POST 전송
                }.resume()
            }
        }
        }
        
        
        
    
    func loadcategory(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/category/\(userIdx)/\(flag!)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    
                    URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                        
                        guard let data = data else {
                                                  print("Error: Did not receive data")
                                                  return
                                              }
                                              
                                             // print(String(data: data, encoding: .utf8)!)
                                              
                                              
                                              
                                              guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                                                  print("Error: HTTP request failed")
                                                  return
                                              }

                        
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(categoryresult.self, from: data) {
                            self.resultlist =  json.result
                            observeresultlist()
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
        }
        
    }
    
    func getRecord() {
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/records/isol/\(userIdx)/\(recordIdx!)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                
                guard let data = data else {return}
                
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(existresponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.RecordDatePicker.date =  json.result.date.toDate() ?? Date()
                        self.goalIdx = json.result.goalIdx
                        if json.result.type == 0 {
                            self.tapSaveOrConsume(self.SaveButton)
                        } else {
                            self.tapSaveOrConsume(self.ConsumeButton)
                        }
                        self.tfInput.text = json.result.category
                        self.MoneyTextField.text = String(json.result.amount)
                    }
                    
                }
                
            }.resume() //URLSession - end
            
            
            
        }
        
    }
    
    
    func postcategory(newcategoryname: String) {
        
        // 넣는 순서도 순서대로여야 하는 것 같다.
        let addcategory = Addcategory(userIdx: UserDefaults.standard.integer(forKey: "userIdx"), flag: flag ?? 0, category_name: newcategoryname)
        guard let uploadData = try? JSONEncoder().encode(addcategory)
        else {return}
        
        // URL 객체 정의
        let url = URL(string: "https://www.pigmoney.xyz/category")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "POST" //GET이라고 써있는데 이해 안 됨
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        
        
        // URLSession 객체를 통해 전송, 응답값 처리
        URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            
            // 서버가 응답이 없거나 통신이 실패
            if let e = error {
                NSLog("An error has occured: \(e.localizedDescription)")
                return
            }
            // 응답 처리 로직
            // guard let data = data else { return }
            
            // data
            
            
            
            
            // POST 전송
        }.resume()
        
        self.loadcategory()
        
    }
    
    let dropdown = DropDown()

    
    func initUI() {
        // DropDown View의 배경
        dropView.backgroundColor = UIColor.init(named: "#F1F1F1")
        dropView.layer.cornerRadius = 8
        
        DropDown.appearance().textColor = UIColor.black // 아이템 텍스트 색상
        DropDown.appearance().selectedTextColor = UIColor.red // 선택된 아이템 텍스트 색상
        DropDown.appearance().backgroundColor = UIColor.white // 아이템 팝업 배경 색상
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray // 선택한 아이템 배경 색상
        DropDown.appearance().setupCornerRadius(8)
        dropdown.dismissMode = .automatic // 팝업을 닫을 모드 설정
            
        tfInput.text = "선택해주세요." // 힌트 텍스트
            
        ivIcon.tintColor = UIColor.gray
    }

    func setDropdown() {
        // dataSource로 ItemList를 연결
        if flag == 0 {
            
            dropdown.dataSource = itemList0
        } else {
            
            dropdown.dataSource = itemList1
        }
            
        // anchorView를 통해 UI와 연결
        dropdown.anchorView = self.dropView
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropdown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item 선택 시 처리
        dropdown.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.tfInput.text = item
            self!.categoryname = item
            self!.categorytype = item
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
        
        // 취소 시 처리
        dropdown.cancelAction = { [weak self] in
            //빈 화면 터치 시 DropDown이 사라지고 아이콘을 원래대로 변경
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
    }
    
    @IBAction func dropdownClicked(_ sender: UIButton) {
        self.loadcategory()
        self.setDropdown()
          // 아이콘 이미지를 변경하여 DropDown이 펼쳐진 것을 표현
          self.ivIcon.image = UIImage.init(named: "DropDownDown")
        dropdown.show()
    }
    
    @IBAction func tapSaveOrConsume(_ sender: UIButton) {
        if sender == self.SaveButton {
            self.changeButtonalpha(color: .red)
            recordtype = "save"
            flag = 0
            self.loadcategory()
            self.setDropdown()
        } else if sender == self.ConsumeButton {
            self.changeButtonalpha(color: .systemMint)
            recordtype = "consume"
            flag = 1
            self.loadcategory()
            self.setDropdown()
        }
        
    }
    
    private func changeButtonalpha(color: UIColor){
        self.SaveButton.alpha = color == UIColor.red ? 1 : 0.2
        self.ConsumeButton.alpha = color == UIColor.systemMint ? 1 : 0.2
    }
    
    
    @IBAction func AddCategory(_ sender: UIButton) {
        let alert = UIAlertController(title: "카테고리 추가", message: "원하시는 항목을 새로 넣어주세요!", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField()
        let addAction = UIAlertAction(title: "추가", style: .default) { (action) in
            self.postcategory(newcategoryname: alert.textFields?[0].text ?? "알 수 없음")
            self.setDropdown()
                }
        let cancelAction = UIAlertAction(title: "삭제", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: false, completion: nil)
        
    }
    
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        self.patchRecord()
        
        if flag == 1 {
            guard let consumeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConsumeViewController") as? ConsumeViewController else {return}
            consumeViewController.goalIdx = self.goalIdx
            consumeViewController.recordDate = self.RecordDatePicker.date.toString()
            self.navigationController?.pushViewController(consumeViewController, animated: true)
            
        } else {
            self.navigationController?.popViewController(animated: true) //6. 이전 화면으로 화면 전환
        }
        
    }
    
    
    
    
}


/*extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}
*/
