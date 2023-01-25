//
//  ProfileEditViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class ProfileEditViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imagepickButton: UIButton!
    
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var ID: UILabel!
    
    @IBOutlet weak var ChangeIDView: UIView!
    
    @IBOutlet weak var ChangeSNView: UIView!
    
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(ProfileEditViewController.goChangeID(sender:)))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(ProfileEditViewController.goChangeSN(sender:)))
       
        self.ChangeIDView.addGestureRecognizer(gesture2)
        self.ChangeSNView.addGestureRecognizer(gesture3)
        
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
    
    
    @objc func goChangeID(sender:UIGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let changeIDViewController = storyboard.instantiateViewController(withIdentifier: "ChangeIDViewController")
        self.navigationController!.pushViewController(changeIDViewController, animated: true)
        
    }
    
    @objc func goChangeSN(sender:UIGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let changeSNViewController = storyboard.instantiateViewController(withIdentifier: "ChangeSNViewController")
        self.navigationController!.pushViewController(changeSNViewController, animated: true)
        
    }
    
    
    
    @IBAction func TapPickImageButton(_ sender: UIButton) {
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
            imagepickButton.setImage(image, for: .normal)
            print(info)

                }

                dismiss(animated: true, completion: nil)
    }
  
    
    
    
}





extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: width)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
