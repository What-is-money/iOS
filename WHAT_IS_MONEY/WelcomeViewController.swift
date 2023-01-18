//
//  WelcomeViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/03.
//

import UIKit
import SwiftUI

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
      navigationController?.isNavigationBarHidden = true // 뷰 컨트롤러가 나타날 때 숨기기
    }

}
