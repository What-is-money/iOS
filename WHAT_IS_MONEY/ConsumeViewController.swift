//
//  ConsumeViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/02/08.
//

import UIKit
import Gifu

class ConsumeViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: GIFImageView!
    
    
    var recordDate: String?
    var goalIdx: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("늑대2\n\n\n\n", goalIdx as Any)
        gifImageView.animate(withGIFNamed: "늑대배경")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // [6초 후에 동작 실시]
            guard let recordViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as? RecordViewController else {return}
            let goalIdx = self.goalIdx
           recordViewController.goalIdx = goalIdx
            print(recordViewController.goalIdx as Any)
            self.navigationController?.pushViewController(recordViewController, animated: true)
              }
        
        
    }
    
    @IBAction func TapSkipButton(_ sender: UIButton) {
        guard let recordViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as? RecordViewController else {return}
        let goalIdx = self.goalIdx
       recordViewController.goalIdx = goalIdx
        print(recordViewController.goalIdx as Any)
        self.navigationController?.pushViewController(recordViewController, animated: true)
        
    }
    
}
