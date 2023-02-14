//
//  ChartViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/11/23.
//

import UIKit
import SwiftUI

class ChartViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBSegueAction func showChartView(_ coder: NSCoder) -> UIViewController? {

        return UIHostingController(coder: coder, rootView: ChartView().environmentObject(Network()))
    }
    
   
}


