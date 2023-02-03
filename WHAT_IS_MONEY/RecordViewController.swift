//
//  RecordViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/10/23.
//

import UIKit

/*struct recordData {
    var date = String()
    var records = [recordforaday]()
    
}
struct recordforaday {
    var sort = String()
    var category = String()
    var price = String()
}*/


struct recordresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [resultone]
    
}

struct resultone: Codable {
    
    let records: [records]
    let date: String
}

struct records: Codable {
    let recordIdx: Int
    let type: Int
    let category: String
    let amount: Int
    
}



class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var goalIdx: Int?
    var type: Bool = false
    

    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var RecordTableView: UITableView!

    var recordViewData : [resultone] = []
    
    /*[resultone(date: "2023.01.06", records: [recordforaday(sort: "지출", category: "쇼핑", price: "37,720"),recordforaday(sort: "지출", category: "교통", price: "17,720"),recordforaday(sort: "저축", category: "용돈", price: "15,020")]),recordData(date: "2023.01.07", records: [recordforaday(sort: "지출", category: "쇼핑", price: "37,720"),recordforaday(sort: "지출", category: "식비", price: "17,720"),recordforaday(sort: "저축", category: "용돈", price: "15,020")]),recordData(date: "2023.01.08", records: [recordforaday(sort: "지출", category: "쇼핑", price: "37,720"),recordforaday(sort: "지출", category: "식비", price: "17,720"),recordforaday(sort: "저축", category: "용돈", price: "15,020")]),recordData(date: "2023.01.10", records: [recordforaday(sort: "지출", category: "쇼핑", price: "37,720"),recordforaday(sort: "지출", category: "식비", price: "17,720"),recordforaday(sort: "저축", category: "용돈", price: "15,020")])]*/
   
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
        print(goalIdx as Any)
        self.loadrecordlist()
        RecordTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadrecordlist()
        let recent = UIAction(title: "최신순", handler: { _ in
            self.type = false
            self.loadrecordlist()
            
        })
        let old = UIAction(title: "오랜순", handler: { _ in
            self.type = true
            self.loadrecordlist()
        })
        typeButton.menu = UIMenu(title: "title입니다",
                                 identifier: nil,
                                 options: .displayInline,
                                 children: [recent, old])
        
        let nib = UINib(nibName: "RecordTableViewCell", bundle: nil)
        RecordTableView.register(nib, forCellReuseIdentifier: "RecordTableViewCell")
        RecordTableView.delegate = self
        RecordTableView.dataSource = self
        
    }
    
    
    func loadrecordlist(){
       let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/records/\(useridx)/\(goalIdx!)?type=\(type)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    
                    URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return}
                        
                    print("뭐가문제야\n\n\n\n")
                    print(String(data: data, encoding: .utf8)!)
                        
                        
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return}

                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(recordresponse.self, from: data) {
                            self.recordViewData =  json.result
                            DispatchQueue.main.async {
                                self.RecordTableView.reloadData()
                            }
                        }
                        
                    }.resume() //URLSession - end
                    
                }
            }
            
            
        }
        
    }
    
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as? RecordDetailViewController
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
        let recorddata = self.recordViewData[indexPath.row]
        cell.DateCell.text = recorddata.date
        
        if recorddata.records.count == 3 {
            if recorddata.records[0].type == 0 {
                cell.firstSortLabel.text = "저축"
            } else {
                cell.firstSortLabel.text = "지출"
            }
            cell.firstCategoryLabel.text = recorddata.records[0].category
            cell.firstPriceLabel.text = String(recorddata.records[0].amount)
            if recorddata.records[1].type == 0 {
                cell.secondSortLabel.text = "저축"
            } else {
                cell.secondSortLabel.text = "지출"
            }
            cell.secondCategoryLabel.text = recorddata.records[1].category
            cell.secondPriceLabel.text = String(recorddata.records[1].amount)
            if recorddata.records[2].type == 0 {
                cell.thirdSortLabel.text = "저축"
            } else {
                cell.thirdSortLabel.text = "지출"
            }
            cell.thirdCategoryLabel.text = recorddata.records[2].category
            cell.thirdPriceLabel.text = String(recorddata.records[2].amount)
            
            //cell.delegate = self
            //cell.arrowButton.tag = indexPath.row
            //cell.arrowButton.addTarget(self, action: #selector(arrowClicked), for: .touchUpInside)
            
            return cell
            
        }
        
        else if recorddata.records.count == 2 {
            if recorddata.records[0].type == 0 {
                cell.firstSortLabel.text = "저축"
            } else {
                cell.firstSortLabel.text = "지출"
            }
            cell.firstCategoryLabel.text = recorddata.records[0].category
            cell.firstPriceLabel.text = String(recorddata.records[0].amount)
            if recorddata.records[1].type == 0 {
                cell.secondSortLabel.text = "저축"
            } else {
                cell.secondSortLabel.text = "지출"
            }
            cell.secondCategoryLabel.text = recorddata.records[1].category
            cell.secondPriceLabel.text = String(recorddata.records[1].amount)
            //cell.delegate = self
            //cell.arrowButton.tag = indexPath.row
            //cell.arrowButton.addTarget(self, action: #selector(arrowClicked), for: .touchUpInside)
            
            
                cell.thirdSortLabel.isHidden = true
                cell.thirdCategoryLabel.isHidden = true
                cell.thirdPriceLabel.isHidden = true
            
            return cell
            
        }
        
       else if recorddata.records.count == 1 {
            if recorddata.records[0].type == 0 {
                cell.firstSortLabel.text = "저축"
            } else {
                cell.firstSortLabel.text = "지출"
            }
            cell.firstCategoryLabel.text = recorddata.records[0].category
            cell.firstPriceLabel.text = String(recorddata.records[0].amount)
           

           
                   cell.secondSortLabel.isHidden = true
                cell.secondCategoryLabel.isHidden = true
                cell.secondPriceLabel.isHidden = true
                
                
                cell.thirdSortLabel.isHidden = true
                cell.thirdCategoryLabel.isHidden = true
                cell.thirdPriceLabel.isHidden = true
           
            
            
            return cell
            
        }
        
       else if recorddata.records.count == 0 {
            
          /*
                cell.firstSortLabel.isHidden = true
                cell.firstCategoryLabel.isHidden = true
                cell.firstPriceLabel.isHidden = true
                
                
                cell.secondSortLabel.isHidden = true
                cell.secondCategoryLabel.isHidden = true
                cell.secondPriceLabel.isHidden = true
                
                
                cell.thirdSortLabel.isHidden = true
                cell.thirdCategoryLabel.isHidden = true
                cell.thirdPriceLabel.isHidden = true */
               
           
            return cell
            
        }
        
        else { return cell }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            
           // tableView.deselectRow(at: indexPath, animated: true)
        guard let recordDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordDetailViewController") as? RecordDetailViewController else {return}
        let goalIdx = self.goalIdx
       recordDetailViewController.goalIdx = goalIdx
        print(recordDetailViewController.goalIdx as Any)
        recordDetailViewController.recordDate = recordViewData[indexPath.row].date
        print(recordDetailViewController.recordDate as Any)
        self.navigationController?.pushViewController(recordDetailViewController, animated: true)
//            let vc = RecordDetailViewController(nibName: "RecordDetailViewController", bundle: nil)
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
        }
   
    

    
    
}
//extension RecordViewController: ArrowClickedDelegate {
//    func presentToRecordDetailViewController() {
//         let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordDetailViewController") as? RecordDetailViewController
//
//        self.navigationController?.pushViewController(vc!, animated: true)
//
//
//
//    }
//}
