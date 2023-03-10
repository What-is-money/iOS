import Foundation
import UIKit
import DropDown
import AVFoundation

struct goalresult: Codable {
    let id: Int
    let image: String
    let goal_amount: Int
    let amount: Int
    let init_amount: Int
    let progress: Float
    let category_name: String
    let date: String
        
}

struct goallistresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [goalresult]
    
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
        TokenClass.handlingToken()
        
        //guard let goaldetailviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "GoalDetailViewController") else {return}
        //goaldetailviewcontroller.AudioPlayer.stop()
        getGoalList()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurenavigationbar()
        self.initUI()
        self.setDropdown()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
                    
            DispatchQueue.global().async {
                do {
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
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            print("goalList!!!!",self.goalList)
                           // print(self.goalList.count)
                        } else {
                            print("wrong!!!")
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
                    
            }//url - end
        
    }
    
    func getGoalListsortbyAsc(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/sortGoalByAsc/\(userIdx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            
            DispatchQueue.global().async {
                do {
                    URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return
                        }
                        
                        //print(String(data: data, encoding: .utf8)!)
                        
                        
                        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                            print("Error: HTTP request failed")
                            return
                        }
                        //                    goallistresponse.self
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(goallistresponse.self, from: data) {
                            //print("\n\n\njson\n\n\n\n",json)
                            //print("\n\n\nmessage!!!!!\n\n\n",json.message)
                            self.goalList = json.result
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                             print("goalList!!!!",self.goalList)
                            // print(self.goalList.count)
                        } else {
                            print("wrong!!!")
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
            
        }
    }
    
    func getGoalListsortbyDesc(){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/sortGoalByDesc/\(userIdx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            
            DispatchQueue.global().async {
                do {
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
                           // print("\n\n\njson\n\n\n\n",json)
                            print("\n\n\nmessage!!!!!\n\n\n",json.message)
                            self.goalList = json.result
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            //print("goalList!!!!",self.goalList)
                            //print(self.goalList.count)
                        } else {
                            print("wrong!!!")
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
        }
    }
    
    func deletegoal(goalIdx: Int){
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/goal/deleteGoal/\(goalIdx)/\(userIdx)"){
            print(url)
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "DELETE"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
                    
                   let task = URLSession.shared.dataTask(with: request){[self] (data, response, error) in
                            
                            
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
                                            if let json = try? decoder.decode(goaldeleteresponse.self, from: data) {
                                                print(json.message)
                                            }

                        
                        
                    }
                        task.resume() //URLSession - end
                
        }
    }
    
    
    
    func configurenavigationbar(){
        
        let addgoal = UIAction(title: "?????? ????????????", handler: { _ in
            guard let goaladdviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "GoalAddViewController") else {return}
            self.navigationController?.pushViewController(goaladdviewcontroller, animated: true) })
        
        
        let donedeletegoal = UIAction(title: "?????? ????????????", handler: { (action) in
            
            self.getGoalList()
            self.tableView.setEditing(false, animated: true)
            self.tableView.reloadData()
            
        })
        
        let deletegoal = UIAction(title: "?????? ????????????", attributes: .destructive, handler: { _ in
            self.tableView.setEditing(true, animated: true)
            
        })
        
        
        
        let buttonMenu = UIMenu(title: "?????? ?????????", children: [addgoal, deletegoal, donedeletegoal])
        kebapButton.menu = buttonMenu
        
    }
        
  
    
    
    let dropdown = DropDown()

    // DropDown ????????? ?????????
var itemList = ["?????????", "????????????"]
    
    
    func initUI() {
        // DropDown View??? ??????
        dropView.backgroundColor = UIColor.init(named: "#F1F1F1")
        dropView.layer.cornerRadius = 8
        
        DropDown.appearance().textColor = UIColor.black // ????????? ????????? ??????
        DropDown.appearance().selectedTextColor = UIColor.red // ????????? ????????? ????????? ??????
        DropDown.appearance().backgroundColor = UIColor.white // ????????? ?????? ?????? ??????
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray // ????????? ????????? ?????? ??????
        DropDown.appearance().setupCornerRadius(8)
        dropdown.dismissMode = .automatic // ????????? ?????? ?????? ??????
            
        tfInput.text = "??????????????????." // ?????? ?????????
            
        ivIcon.tintColor = UIColor.gray
    }

    func setDropdown() {
        // dataSource??? ItemList??? ??????
       
            dropdown.dataSource = itemList
        // anchorView??? ?????? UI??? ??????
        dropdown.anchorView = self.dropView
        
        // View??? ????????? ?????? View????????? Item ????????? ????????? ??????
        dropdown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item ?????? ??? ??????
        dropdown.selectionAction = { [weak self] (index, item) in
            //????????? Item??? TextField??? ????????????.
            self!.tfInput.text = item
            if self!.tfInput.text == "?????????" {
                
                self?.getGoalListsortbyAsc()
                
            } else {
                
                self?.getGoalListsortbyDesc()
                
            }
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
        
        // ?????? ??? ??????
        dropdown.cancelAction = { [weak self] in
            //??? ?????? ?????? ??? DropDown??? ???????????? ???????????? ???????????? ??????
            self!.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
    }
    
    @IBAction func dropdownClicked(_ sender: UIButton) {
        dropdown.show() // ????????? ????????? ????????????.
          // ????????? ???????????? ???????????? DropDown??? ????????? ?????? ??????
          self.ivIcon.image = UIImage.init(named: "DropDownDown")
    }
    
    
    
    
    
    
    
    
}

extension GoalListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let GoalDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoalDetailViewController") as? GoalDetailViewController else {return}
        GoalDetailViewController.goalIdx = goalList[indexPath.row].id
        print(goalList[indexPath.row].id)
        self.navigationController?.pushViewController(GoalDetailViewController, animated: true)
    }
    
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
         //let defaultImg = UIImage(named: "defaultimage")
        cell.GoalImage.image = decodeImg?.resized(toWidth: 58)
        cell.GoalNameLabel.text = goalList[indexPath.row].category_name
        cell.CurrentMoney.text = String(goalList[indexPath.row].amount)
        cell.GoalMoney.text = String(goalList[indexPath.row].goal_amount)
        cell.percentageLabel.text = String(goalList[indexPath.row].progress)
         
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let goalIdx = self.goalList[indexPath.row].id
        deletegoal(goalIdx: goalIdx)
        self.goalList.remove(at: indexPath.row)
        self.tableView.reloadData()

    }
    
    
}

