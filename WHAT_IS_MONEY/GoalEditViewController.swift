//
//  GoalEditViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/20.
//

import UIKit

class GoalEditViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate {

 
    @IBOutlet weak var ImgLabel: UILabel!
    @IBOutlet weak var ImgUI: UIButton!
    @IBOutlet weak var GoalNameTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var InitPriceTextField: UITextField!
    @IBOutlet weak var CompleteButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary // 앨범에서 가져옴
        picker.allowsEditing = true
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
       
        let alert =  UIAlertController(title: "사진 수정", message: "", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in

        self.openCamera()

        }
        let delete = UIAlertAction(title: "삭제", style: .destructive){
                    //TODO 추가 이미지 setting (+)
                    (action) in print("")
                }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)

        alert.addAction(camera)
        
        alert.addAction(delete)

        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            image = image.resized(toWidth: 90.0) ?? image
            ImgUI.setImage(image, for: .normal)
            print(image)
            print(info)

                }

        dismiss(animated: true, completion: nil)
    }
  
    

}

