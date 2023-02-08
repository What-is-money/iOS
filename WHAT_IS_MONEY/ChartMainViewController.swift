//
//  ChartMainViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 2/8/23.
//

import UIKit
import SwiftUI

class ChartMainViewController: UIViewController {

    @IBOutlet weak var SwitchBtn: UISwitch!
    @IBOutlet weak var PigImage: UIImageView!
    @IBOutlet weak var SwitchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwitchBtn.isOn = true
        SwitchBtn.tintColor = UIColor(named: "NPeach")
        SwitchBtn.layer.cornerRadius = SwitchBtn.frame.height / 2.0
        SwitchBtn.backgroundColor = UIColor(named: "NPeach")
        SwitchBtn.clipsToBounds = true
        
       
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SwitchClicked(_ sender: UISwitch) {
        print(SwitchBtn.isOn)
        if SwitchBtn.isOn != true {
            PigImage.image = UIImage(named: "chartOff")
            SwitchLabel.text = "다크 모드"
        } else {
            PigImage.image = UIImage(named: "chartOn")
            SwitchLabel.text = "라이트 모드"
        }
    }
    
   

}
