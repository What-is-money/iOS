//
//  AlertViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/27/23.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var touchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchButton.addTarget(self, action: #selector(goAlert), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goAlert(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        //self.navigationController?.pushViewController(vc, animated: true)
        //present(vc, animated: true, completion: nil)
        //vc.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: true)
    }
    
  
}
