//
//  RecordDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/11.
//

import UIKit


struct recorddeletepost: Codable {
    let userIdx: Int
    let recordIdx: Int
    
}

struct recordlistpost: Codable {
    let userIdx: Int
    let goalIdx: Int
    let date: String
    
}

struct response1: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: resulttwo
    
}

struct resulttwo: Codable {
    let records: [resultlist]
    let date: String
}

struct resultlist: Codable {
    let recordIdx: Int
    let type: Int
    let category: String
    let amount: Int
}

class RecordDetailViewController: UIViewController {
    
    @IBOutlet weak var DateTextField: UITextField!
    
    @IBOutlet weak var DateButton: UIButton!
    
    @IBOutlet var EditButton: UIButton!
    
    var doneButton: UIButton?
    
    @IBOutlet weak var tableView: UITableView!
    
    var edittapnum: Int = 0
    
    var recordDate: String?
    var goalIdx: Int?
    
    private var recordList = [resultlist]() //
    
    override func viewWillAppear(_ animated: Bool) {
        getrecordList()
        tableView.reloadData()
        DateTextField.text = recordDate
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(recordList)
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    
    func getrecordList(){
        
        let record = recordlistpost(userIdx: UserDefaults.standard.integer(forKey: "userIdx"), goalIdx: goalIdx!, date: recordDate!)
        guard let uploadData = try? JSONEncoder().encode(record)
        else {return}
        
        // URL 객체 정의
        let url = URL(string: "https://www.pigmoney.xyz/daily-records")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        
        request.httpBody = uploadData
        print("업로드 리코드")
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
                    
                    print(String(data: data, encoding: .utf8)!)
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                        print("Error: HTTP request failed")
                        return
                    }
                    
                    // data
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(response1.self, from: data) {
                        self.recordList = json.result.records
                        print("+++++++++++++++++")
                        print(self.recordList)
                        print("+++++++++++++")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                    // POST 전송
                }.resume()
            }
        }
    }
    
    func deleterecordList(recordIdx: Int){
        
        let recorddelete = recorddeletepost(userIdx: UserDefaults.standard.integer(forKey: "userIdx"), recordIdx: recordIdx)
        guard let uploadData = try? JSONEncoder().encode(recorddelete)
        else {return}
        
        // URL 객체 정의
        let url = URL(string: "https://www.pigmoney.xyz/records")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        
        DispatchQueue.main.async {
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
                    print("deleterecordlist")
                    print(String(data: data, encoding: .utf8)!)
                    
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                        print("Error: HTTP request failed")
                        return
                    }
                
                // POST 전송
            }.resume()
        }
    }
        
    }
    

    
    @IBAction func tapEditButton(_ sender: UIButton) {
        if edittapnum == 0 {
            print("edittapnum==0이다")
            guard !self.recordList.isEmpty else {return}
            self.EditButton.titleLabel?.text = "편집끝"
            self.EditButton.titleLabel?.textColor = UIColor.red
            self.tableView.setEditing(true, animated: true)
            edittapnum = edittapnum + 1
        } else {
            print("edittapnum=1이다")
            self.EditButton.titleLabel?.text = "편집"
            self.EditButton.titleLabel?.textColor = UIColor.blue
            self.tableView.setEditing(false, animated: true)
            edittapnum = edittapnum - 1
            getrecordList()
            
        }
    }
    
    
    @IBAction func tapPlusButton(_ sender: UIButton) {
        guard let writerecordViewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteRecordViewController") as? WriteRecordViewController else {return}
        let goalIdx = self.goalIdx
       writerecordViewController.goalIdx = goalIdx
        self.navigationController?.pushViewController(writerecordViewController, animated: true)}
        
    }
    


extension RecordDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fixedRecordViewController = self.storyboard?.instantiateViewController(withIdentifier: "FixedRecordViewController") as? FixedRecordViewController else {return}
        let recordIdx = self.recordList[indexPath.row].recordIdx
        fixedRecordViewController.recordIdx = recordIdx
        fixedRecordViewController.flag = self.recordList[indexPath.row].type
        print(fixedRecordViewController.recordIdx as Any)
        self.navigationController?.pushViewController(fixedRecordViewController, animated: true)
    }
    
    
}

extension RecordDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTableViewCell", for: indexPath) as? RecordDetailTableViewCell else { return UITableViewCell() }
         let record = self.recordList[indexPath.row]
         if record.type == 0 {
            cell.CellKindLabel.text = "저축"
             cell.CellKindLabel.textColor = UIColor.red
            
        } else {
            cell.CellKindLabel.text = "지출"
            cell.CellKindLabel.textColor = UIColor.systemMint
        }
        
        cell.CategoryLabel.text = record.category
        cell.CostLabel.text = String(record.amount)
 
        return cell
    }
    
    
    func tableView(_ tableview: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let record = self.recordList[indexPath.row]
        let recordidx = record.recordIdx
        deleterecordList(recordIdx: recordidx)
        recordList.remove(at: indexPath.row)
        tableview.reloadData()
        
    }
    
}


