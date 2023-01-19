//
//  GoalEditViewController.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/19/23.
//

import UIKit

protocol ImagePickerDelegate : AnyObject {
    func clickButton()
}

class GoalEditViewController: UIViewController {

 
    @IBOutlet weak var ImgLabel: UILabel!
    @IBOutlet weak var GoalNameTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var InitPriceTextField: UITextField!
    @IBOutlet weak var CompleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imagePicker = ImagePicker()
        self.view.addSubview(imagePicker)
        imagePicker.translatesAutoresizingMaskIntoConstraints = false
        imagePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        NSLayoutConstraint.activate(
             [imagePicker.topAnchor.constraint(equalTo: self.ImgLabel.topAnchor, constant: 36),
             imagePicker.heightAnchor.constraint(equalToConstant: 90),
             imagePicker.widthAnchor.constraint(equalToConstant: 90)])
    }

}
class ImagePicker  : UIView {
    weak var delegate : ImagePickerDelegate?
    var image : UIImageView!
    var button : UIButton!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setView()
    }
    convenience init () {
        self.init(frame:.zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView() {
        backgroundColor = .clear
        createImage()
        createButton()
    }
    func createImage() {
            image = UIImageView()
            image.clipsToBounds = true
            image.image = UIImage(named : "image1")
            image.layer.cornerRadius = 8
            image.layer.borderWidth = 0.5
            image.layer.borderColor = UIColor(red: 0.587, green: 0.587, blue: 0.587, alpha: 1).cgColor
            image.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.frame = CGRect(x:0, y:0, width: 90, height: 90)
        }
  
    func createButton() {
            button = UIButton()
            button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
            button.imageView?.tintColor = .black
            button.layer.cornerRadius = 10
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [button.topAnchor.constraint(equalTo: topAnchor, constant: -5),
                 button.heightAnchor.constraint(equalToConstant: 18),
                 button.widthAnchor.constraint(equalToConstant: 18),
                 button.rightAnchor.constraint(equalTo: rightAnchor,constant: 5)])
            
            button.addTarget(self, action: #selector(click), for: .touchDown)
        }
    @objc func click() {
        delegate?.clickButton()

    }
}
