//
//  GoalListViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/17.
//

import UIKit
import DropDown

class GoalListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var kebapButton: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    @IBOutlet weak var tfInput: UITextField!
    
    @IBOutlet weak var ivIcon: UIImageView!
    
    @IBOutlet weak var btnSelect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurenavigationbar()
        self.initUI()
        self.setDropdown()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    
    func configurenavigationbar(){
        let addgoal = UIAction(title: "목표 추가하기", handler: { _ in
            guard let goaladdviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "GoalAddViewController") else {return}
            self.navigationController?.pushViewController(goaladdviewcontroller, animated: true) })
        let deletegoal = UIAction(title: "목표 삭제하기", handler: { _ in print("목표 삭제하기") })
        let buttonMenu = UIMenu(title: "메뉴 타이틀", children: [addgoal, deletegoal])
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
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GoalListCell", for: indexPath) as? GoalListCell else {
            return UITableViewCell()}
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}
