//
//  GoalAddViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/20.
//

import UIKit

class GoalAddViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate {

    @IBOutlet weak var ImgUI: UIButton!
    @IBOutlet weak var GoalTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var InitPriceTextField: UITextField!
    @IBOutlet weak var CompleteButtton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    func openLibrary(){

      picker.sourceType = .photoLibrary

      present(picker, animated: false, completion: nil)

    }

    func openCamera(){

        if(UIImagePickerController .isSourceTypeAvailable(.camera)){

        picker.sourceType = .camera

                    present(picker, animated: false, completion: nil)

                }

                else{

                    print("Camera not available")

                }

    }

    @IBAction func TapImgUIButton(_ sender: UIButton) {
       
        let alert =  UIAlertController(title: "원하는 타이틀", message: "원하는 메세지", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in

        self.openCamera()

        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)

        alert.addAction(camera)

        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image = image.resized(toWidth: 90.0) ?? image
            ImgUI.setImage(image, for: .normal)
            print(info)

                }

                dismiss(animated: true, completion: nil)
    }
  
    
}

