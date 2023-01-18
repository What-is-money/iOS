//
//  RecordDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/11.
//

import UIKit

class RecordDetailViewController: UIViewController {
    
    @IBOutlet weak var DateTextField: UITextField!
    
    @IBOutlet weak var DateButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    private var recordList = [Record]() //7. 구조체를 담을 배열 있나 확인!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editRecordNotification(_:)),
            name: NSNotification.Name("editRecord"),
            object: nil
                )
    }
    
    @objc func editRecordNotification(_ notification: Notification){
        guard let record = notification.object as? Record else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.recordList[row] = record
        self.recordList = self.recordList.sorted(by: {
            $0.diaryDate.compare($1.diaryDate) == .orderedDescending
        })
        self.tableView?.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeRecordViewController = segue.destination as? WriteRecordViewController {
            writeRecordViewController.delegate = self
        }
    } // 8. 셀 정보를 넘겨주는 뷰 컨트롤러로 화면 전환을 segue로 구현했으니 이걸 이용해 셀 정보를 넘겨주는 뷰 컨트롤러 객체를 가져와서 delegate를 연결
    
    
    @IBAction func TapDateButton(_ sender: UIButton) {
        datePicker.isHidden = false

    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss EEE"
        DateTextField.text = formatter.string(from: datePickerView.date)
        datePickerView.isHidden = true
        
    }
    
    
    
    
    @IBAction func TapCellEditButton(_ sender: UIButton) {
    }
    
    
}

extension RecordDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fixedRecordViewController = self.storyboard?.instantiateViewController(withIdentifier: "FixedRecordViewController") as? FixedRecordViewController else {return}
        let record = self.recordList[indexPath.row]
        fixedRecordViewController.record = record
        fixedRecordViewController.indexPath = indexPath
        fixedRecordViewController.delegate = self
        self.navigationController?.pushViewController(fixedRecordViewController, animated: true)
    }
    
    
}

extension RecordDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailTableViewCell", for: indexPath) as? RecordDetailTableViewCell else { return UITableViewCell() }
        let record = self.recordList[indexPath.row]
        if record.recordtype == "save" {
            cell.CellKindLabel.text = "저축"
            cell.CellKindLabel.textColor = UIColor(named: "red")
            
        } else {
            cell.CellKindLabel.text = "지출"
            cell.CellKindLabel.textColor = UIColor(named: "SystemMint")
        }
        
        cell.CategoryLabel.text = record.categorytype
        cell.CostLabel.text = record.moneyAmount
        self.datePicker.date = record.diaryDate
        return cell
    }
    
    
}


extension RecordDetailViewController: WriteRecordViewDelegate {
    func didSelectRegister(record: Record) {
        self.recordList.append(record)
        self.recordList = self.recordList.sorted(by: {
            $0.diaryDate.compare($1.diaryDate) == .orderedDescending
        })
        self.tableView.reloadData()// 9.아까 전에 화면에서 구현해줬던 프로토콜 안에 있던 함수 드디어 구현, 여기서 구조체 배열에 이전 화면 구조체 객체 첨가
    }
    
}

extension RecordDetailViewController: FixedRecordViewDelegate {
    func didSelectDelete(indexPath: IndexPath) {
        self.recordList.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
}
