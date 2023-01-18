//
//  FixedRecordDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/17.
//

import UIKit
import DropDown

protocol FixedRecordViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
    
}


class FixedRecordViewController: UIViewController {
    
    @IBOutlet weak var RecordDatePicker: UIDatePicker!
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var ConsumeButton: UIButton!
    
    @IBOutlet weak var MoneyTextField: UITextField!
    
    
    weak var delegate: FixedRecordViewDelegate?

    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var tfInput: UITextField!
    
    @IBOutlet weak var ivIcon: UIImageView!
    
    @IBOutlet weak var btnSelect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.setDropdown()
        self.configureView()
    }
    
    var record: Record?
    var indexPath: IndexPath?
    
    private var diaryDate: Date? 
    private var recordtype: String?
    private var categorytype: String?
    private var moneyAmount: String?
    
    
    private func configureView() {
        guard let record = self.record else {return}
        self.RecordDatePicker.date = record.diaryDate
        if record.recordtype == "save" {
            tapSaveOrConsume(SaveButton)
        } else {
            tapSaveOrConsume(ConsumeButton)
        }
        self.tfInput.text = record.categorytype
        self.MoneyTextField.text = record.moneyAmount
        
    }
    
    
    
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
    
    @objc func editRecordNotification(_ notification: Notification) {
        guard let record = notification.object as? Record else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else {return}
        self.record = record
        self.configureView()
    }
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "WriteRecordViewController") as? WriteRecordViewController else {return}
        guard let indexPath = self.indexPath else {return}
        guard let record = self.record else {return}
        viewcontroller.recordEditorMode = .edit(indexPath, record)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editRecordNotification(_:)),
            name: NSNotification.Name("editRecord"),
            object: nil
        )
        self.navigationController?.pushViewController(viewcontroller, animated: true)
        
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {return}
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
