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
//        let contentView = ChartView().environmentObject(Network())
//
//        if let windowScene = scene as? UIWindowScene {
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = UIHostingController(rootView: contentView)
//            self.window = window
//            window.makeKeyAndVisible()
//        }
        return UIHostingController(coder: coder, rootView: ChartView().environmentObject(Network()))
    }
    
   
}


