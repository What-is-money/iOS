//
//  GoalListViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/17.
//
import Foundation
import UIKit
import DropDown


struct goalresult: Codable {
    let id: Int
    let image: String
    let goal_amount: Int
    let amount: Int
    let progress: Float
    let category_name: String
    let date: String
//
//    init(id: Int, image: String, goal_amount: Int, amount: Int, progress: Float, category_name: String, date: String) {
//        self.id = id
//        self.image = image
//        self.goal_amount = goal_amount
//        self.amount = amount
//        self.progress = progress
//        self.category_name = category_name
//        self.date = date
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case image = "image"
//        case goal_amount = "goal_amount"
//        case amount = "amount"
//        case progress = "progress"
//        case category_name = "category_name"
//        case date = "date"
//           }
    
}

struct goallistresponse: Codable {
    let code: Int
    let isSuccess: Bool
    let result: [goalresult]
    let message: String

//    init(isSuccess: Bool, code: Int, message: String, result: [goalresult]) {
//        self.isSuccess = isSuccess
//        self.code = code
//        self.result = result
//        //self.goal_amount = goalresult.goal_amount
//
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case image = "image"
//        case goal_amount = "goal_amount"
//        case amount = "amount"
//        case progress = "progress"
//        case category_name = "category_name"
//        case date = "date"
//           }

}

class GoalListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var kebapButton: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var tfInput: UITextField!
    
    @IBOutlet weak var ivIcon: UIImageView!
    
    @IBOutlet weak var btnSelect: UIButton!
    
    var goalList: [goalresult] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillappear")
        self.getGoalList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurenavigationbar()
        self.getGoalList()
        self.initUI()
        self.setDropdown()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    /*defaults.set(Response.userIdx, forKey: "userIdx")
    defaults.set(Response.accessToken, forKey: "accessToken")
    defaults.set(Response.refreshToken, forKey: "refreshToken")*/
    
    func getGoalList(){
        
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        
        if let url = URL(string: "https://www.pigmoney.xyz/goal/getGoalList/\(userIdx)"){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
            
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
                    
            
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    
                    guard let data = data else {
                        print("Error: Did not receive data")
                        return
                    }
                    
                    print(String(data: data, encoding: .utf8)!)
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                        print("Error: HTTP request failed")
                        return
                    }
//                    goallistresponse.self
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(goallistresponse.self, from: data) {
                        print("\n\n\njson\n\n\n\n",json)
                        print("\n\n\nmessage!!!!!\n\n\n",json.message)
                        self.goalList = json.result
                        print("goalList!!!!",self.goalList)
                    } else {
                        print("wrong!!!")
                    }
//                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
//                        print("this!!!!",json)
//                        if let id = json["id"] as? Int{
//                            print("id",id)
//                        }
//                    }else {
//                        print("wrong")
//                    }
                        
                }.resume() //URLSession - end
                    
            }//url - end
        
        tableView.reloadData()
    }
    
    func getGoalListsortbyAsc(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/sortGoalByAsc/\(userIdx)"){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
                    
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    guard let data = data else {return}
                    
                    // data
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(goallistresponse.self, from: data) {
                        print(json.message)
                        self.goalList = json.result
                    }
                        
                }.resume() //URLSession - end
                    
            }//url - end
        
        
    }
    
    func getGoalListsortbyDesc(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/sortGoalByDesc/\(userIdx)"){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
            
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
                    
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    guard let data = data else {return}
                    
                    // data
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(goallistresponse.self, from: data) {
                        self.goalList = json.result
                    }
                        
                }.resume() //URLSession - end
                    
            }//url - end
        
        
    }
    
    func deletegoal(goalIdx: Int){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/deleteGoal/\(goalIdx)/\(userIdx)"){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
            
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
                    
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    guard let data = data else {return}
                    
                    // data
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(goallistresponse.self, from: data) {
                        self.goalList = json.result
                    }
                        
                }.resume() //URLSession - end
                    
            }//url - end
        
        
    }
    
    
    
    func configurenavigationbar(){
        
        let addgoal = UIAction(title: "목표 추가하기", handler: { _ in
            guard let goaladdviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "GoalAddViewController") else {return}
            self.navigationController?.pushViewController(goaladdviewcontroller, animated: true) })
        
        
        let donedeletegoal = UIAction(title: "목표 삭제완료", attributes: .hidden, handler: { (action) in
          
            self.tableView.setEditing(false, animated: true)
            
        })
        
        let deletegoal = UIAction(title: "목표 삭제하기", handler: { _ in
            donedeletegoal.attributes = .init()
            self.tableView.setEditing(true, animated: true)
            
        })
        
        
        
        let buttonMenu = UIMenu(title: "메뉴 타이틀", children: [addgoal, deletegoal, donedeletegoal])
        kebapButton.menu = buttonMenu
        
    }
        
  
    
    
    let dropdown = DropDown()

    // DropDown 아이템 리스트
var itemList = ["최신순", "오래된순"]
    
    
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
       
            dropdown.dataSource = itemList
        // anchorView를 통해 UI와 연결
        dropdown.anchorView = self.dropView
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropdown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item 선택 시 처리
        dropdown.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.tfInput.text = item
            if self!.tfInput.text == "최신순" {
                
                self?.getGoalListsortbyAsc()
                
            } else {
                
                self?.getGoalListsortbyDesc()
                
            }
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
        
        // 취소 시 처리
        dropdown.cancelAction = { [weak self] in
            //빈 화면 터치 시 DropDown이 사라지고 아이콘을 원래대로 변경
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
    }
    
    @IBAction func dropdownClicked(_ sender: UIButton) {
        dropdown.show() // 아이템 팝업을 보여준다.
          // 아이콘 이미지를 변경하여 DropDown이 펼쳐진 것을 표현
          self.ivIcon.image = UIImage.init(named: "DropDownDown")
    }
    
    
    
    
    
    
    
    
}

extension GoalListViewController: UITableViewDelegate {
    
    
    
}

extension GoalListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GoalListCell", for: indexPath) as? GoalListCell else {
            return UITableViewCell()}
      
        let data = Data(base64Encoded: goalList[indexPath.row].image, options: .ignoreUnknownCharacters) ?? Data()
            let decodeImg = UIImage(data: data)
            cell.GoalImage.image = decodeImg
        cell.GoalNameLabel.text = goalList[indexPath.row].category_name
        cell.CurrentMoney.text = String(goalList[indexPath.row].amount)
        cell.GoalMoney.text = String(goalList[indexPath.row].goal_amount)
        cell.percentageLabel.text = String(goalList[indexPath.row].progress)
            
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let GoalDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoalDetailViewController") as? GoalDetailViewController else {return}
        guard let goalDetailViewController = self.storyboard?.instantiateViewController(withIdentifier:"GoalDetailViewController")else{return}
       // GoalDetailViewController.goalIdx = goalList[indexPath.row].id
        self.navigationController?.pushViewController(goalDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let goalIdx = self.goalList[indexPath.row].id
        deletegoal(goalIdx: goalIdx)
        getGoalList()
        tableView.reloadData()
    }
    
}
