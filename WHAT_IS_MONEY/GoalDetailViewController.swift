//
//  GoalDetailViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/18.
//

import UIKit
class GoalDetailViewController: UIViewController {
    
    
    @IBOutlet weak var kebapButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let recordviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") else {return}
        let showrecords = UIAction(title: "기록 보기", handler: { _ in self.navigationController?.pushViewController(recordviewcontroller, animated: true)})
        let addrecord = UIAction(title: "기록 추가하기", handler: { _ in print("기록 추가하기") })
        let editgoal = UIAction(title: "목표 수정하기", handler: { _ in print("목표 수정하기") })
        let deletegoal = UIAction(title: "목표 삭제하기", handler: { _ in print("목표 삭제하기") })
        let buttonMenu = UIMenu(title: "메뉴 타이틀", children: [showrecords, addrecord, editgoal, deletegoal])
       kebapButton.menu = buttonMenu
        
        
    }
    
    
    
}
