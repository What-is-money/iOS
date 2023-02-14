//
//  WriteRecordViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/12.
//

import UIKit
import DropDown

struct Addcategory: Codable {
    let userIdx: Int
    let flag: Int
    let category_name: String

}

struct result: Codable {
    let userIdx: Int
    let category_name: String
    let flag: Int

}

struct categoryresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: result
    
}

struct categoryresultdetail: Codable {
    let categoryIdx: Int
    let category_name: String
    let flag: Int
}

struct categoryresult: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [categoryresultdetail]
    
}



class WriteRecordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var RegisterCellDatePicker: UIDatePicker!
   
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var ConsumeButton: UIButton!
    
    @IBOutlet weak var MoneyTextField: UITextField!
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    var resultlist: [categoryresultdetail] = []
    // DropDown 아이템 리스트
    var itemList0: [String] = []
    var itemList1: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
        loadcategory()
        setDropdown()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.setDropdown()
        self.diaryDate = RegisterCellDatePicker.date
        MoneyTextField.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    private var diaryDate: Date? // 2. 현 화면에서 정보를 담을 각 변수 있는지 확인!
    private var recordtype: String?
    private var categorytype: String?
    private var categoryname: String?
    private var moneyAmount: String?
    private var categoryId: Int?
    private var flag: Int?
    private var recorddateString: String?
    var goalIdx: Int?
    
        @IBOutlet weak var dropView: UIView!
        
        @IBOutlet weak var tfInput: UITextField!
        
        @IBOutlet weak var ivIcon: UIImageView!
        
        @IBOutlet weak var btnSelect: UIButton!
        
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
    
    func loadcategory(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/category/\(userIdx)/\(flag ?? 0)"){
            
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
                            //print("*******")
                            //print(self.resultlist)
                            //print("*******")
                            observeresultlist()
                           // print(itemList0)
                            //print(itemList1)
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
        }
        
    }
    
    func postRecord() {
        
        // 넣는 순서도 순서대로여야 하는 것 같다.
        let record = Record(userIdx: UserDefaults.standard.integer(forKey: "userIdx"), goalIdx: goalIdx!, date: diaryDate?.toString() ?? "0000", category: findcategoryid(categoryname: self.categoryname!), amount: MoneyTextField.text ?? "0")
        guard let uploadData = try? JSONEncoder().encode(record)
        else {return}
        
        // URL 객체 정의
        let url = URL(string: "https://www.pigmoney.xyz/records")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        request.httpBody = uploadData
        
        print(String(data: uploadData, encoding: .utf8)!)
        
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
                    
                    print("**************응답데이터*****************")
                    print(String(data: data, encoding: .utf8)!)
                    print("**************응답데이터*****************")
                    
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                        print("Error: HTTP request failed")
                        return
                    }
                    
                    // data
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(responseP.self, from: data) {
                        print(json.message)
                    }
                
                // POST 전송
                }.resume()
            }
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
        
        request.httpBody = uploadData
        print(String(data: uploadData, encoding: .utf8)!)
        
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
                    // guard let data = data else { return }
                    
                    // data
                    
                    
                    
                    // POST 전송
                }.resume()
                
            }
        }
            
        
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
                dropdown.dataSource = itemList0 } else {
                    
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
                self!.categoryname = self!.tfInput.text
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
            self.ivIcon.image = UIImage.init(named: "DropDownDown")
            dropdown.show() // 아이템 팝업을 보여준다.
              // 아이콘 이미지를 변경하여 DropDown이 펼쳐진 것을 표현
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
    
    
    @IBAction func DatePickerValueChanged(_ sender: UIDatePicker) {
        diaryDate = sender.date
    }
    
    @IBAction func filledtextfieldcategory(_ sender: UITextField) {
        
        categorytype = sender.text
    }
    
    
    @IBAction func tapRegisterButton(_ sender: UIButton) { // 4. 각 변수들을 상수로 만들고 그 상수들을 record(각자 화면의 정보를 담을 구조체) 객체화 시킨 다음
        MoneyTextField.endEditing(true)
        moneyAmount = MoneyTextField.text ?? nil
        
        if moneyAmount?.isEmpty ?? true || categorytype?.isEmpty ?? true {
            print(moneyAmount?.isEmpty as Any)
            print(categorytype?.isEmpty as Any)
            let sheet = UIAlertController(title: "경고", message: "모든 입력칸에 올바르게 입력하였는지 확인해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
            return
        }
        
        
        self.postRecord()
        if flag == 1 {
            
            guard let consumeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConsumeViewController") as? ConsumeViewController else {return}
            consumeViewController.goalIdx = self.goalIdx
            consumeViewController.recordDate = self.RegisterCellDatePicker.date.toString()
            self.navigationController?.pushViewController(consumeViewController, animated: true)
            
        } else {
            self.navigationController?.popViewController(animated: true) //6. 이전 화면으로 화면 전환
        }
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
    
    
  
      
    
    }

    

extension String {
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
