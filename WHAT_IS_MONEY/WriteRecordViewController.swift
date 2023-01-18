//
//  WriteRecordViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/12.
//

import UIKit
import DropDown

enum RecordEditorMode {
    case new
    case edit(IndexPath, Record)
    
}

protocol WriteRecordViewDelegate: AnyObject {
    func didSelectRegister(record: Record)
    
} // 1. to ios 이 프로토콜 작성!!

class WriteRecordViewController: UIViewController {
    
    @IBOutlet weak var RegisterCellDatePicker: UIDatePicker!
   
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var ConsumeButton: UIButton!
    
    @IBOutlet weak var MoneyTextField: UITextField!
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.setDropdown()
        self.configureEditorMode()
        self.diaryDate = RegisterCellDatePicker.date
    }
    
    private var diaryDate: Date? // 2. 현 화면에서 정보를 담을 각 변수 있는지 확인!
    private var recordtype: String?
    private var categorytype: String?
    private var moneyAmount: String?
    weak var delegate: WriteRecordViewDelegate? // 3.delegate 객체 작성! (위에 있는 프로토콜을 객체화 한 것!! 객체화 해야 넘겨줄 수 있으니까)
    var recordEditorMode: RecordEditorMode = .new
    
        @IBOutlet weak var dropView: UIView!
        
        @IBOutlet weak var tfInput: UITextField!
        
        @IBOutlet weak var ivIcon: UIImageView!
        
        @IBOutlet weak var btnSelect: UIButton!
        
        
        
        let dropdown = DropDown()

        // DropDown 아이템 리스트
    var itemList = ["용돈", "적금", "월급", "의복", "식재", "배달음식", "교통비", "고정지출"]
        
        
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
            dropdown.show() // 아이템 팝업을 보여준다.
              // 아이콘 이미지를 변경하여 DropDown이 펼쳐진 것을 표현
              self.ivIcon.image = UIImage.init(named: "DropDownDown")
        }
    
    
    
    @IBAction func tapSaveOrConsume(_ sender: UIButton) {
        if sender == self.SaveButton {
            self.changeButtonalpha(color: .red)
            recordtype = "save"
        } else if sender == self.ConsumeButton {
            self.changeButtonalpha(color: .systemMint)
            recordtype = "consume"
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
    
    @IBAction func enrollmoney(_ sender: UIButton) {
        moneyAmount = MoneyTextField.text ?? "0"
    }
    
    @IBAction func tapRegisterButton(_ sender: UIButton) { // 4. 각 변수들을 상수로 만들고 그 상수들을 record(각자 화면의 정보를 담을 구조체) 객체화 시킨 다음
        
        guard let diaryDate = self.diaryDate else {return}
        guard let recordtype = self.recordtype else {return}
        guard let categorytype = self.categorytype else {return}
        guard let moneyAmount = self.moneyAmount else {return}
        let record = Record(diaryDate: diaryDate, recordtype: recordtype, categorytype: categorytype, moneyAmount: moneyAmount)
        
        switch self.recordEditorMode {
        case .new:
            self.delegate?.didSelectRegister(record: record)
        case let .edit(indexPath, _):
            NotificationCenter.default.post(
                name: NSNotification.Name("editRecord"),
                object: record,
                userInfo: [
                    "indexPath.row": indexPath.row
                ]
            
            )
            
            
        }
        
        self.delegate?.didSelectRegister(record: record) // 5. 위에 프로토콜에서 만들어준 함수에 그 객체를 넣기(이 함수는 셀 정보를 넘겨줄 뷰 컨트롤러에 정의됨
        print(diaryDate)
        print(recordtype)
        print(categorytype)
        print(moneyAmount)
        self.navigationController?.popViewController(animated: true) //6. 이전 화면으로 화면 전환
        
    }
    
    @IBAction func AddCategory(_ sender: UIButton) {
        let alert = UIAlertController(title: "카테고리 추가", message: "원하시는 항목을 새로 넣어주세요!", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField()
        let addAction = UIAlertAction(title: "추가", style: .default) { (action) in
            self.itemList.append(alert.textFields?[0].text ?? "")
            self.setDropdown()
                }
        
        alert.addAction(addAction)
        present(alert, animated: false, completion: nil)
        
    }
    
    
    private func configureEditorMode() {
        switch self.recordEditorMode {
        case let .edit(_, record):
            self.RegisterCellDatePicker.date = record.diaryDate
            if record.recordtype == "save" {
                self.tapSaveOrConsume(self.SaveButton)
            } else {
                self.tapSaveOrConsume(self.ConsumeButton)
                
            }
            self.tfInput.text = record.categorytype
            self.MoneyTextField.text = record.moneyAmount
            self.RegisterButton.setTitle("수정", for: .normal)
            
        default:
            break
        }
    }
      
    
    }

    

