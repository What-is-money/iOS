//
//  GoalAddViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/20.
//

import UIKit


struct responseP: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    var result: Result
}

struct Result: Codable {
    let goalIdx: Int
    
}


class GoalAddViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate {
    
    @IBOutlet weak var ImgUI: UIButton!
    @IBOutlet weak var GoalTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var InitPriceTextField: UITextField!
    @IBOutlet weak var CompleteButtton: UIButton!
    
    
    let picker = UIImagePickerController()
    
    var imagebase64: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
    }
    
    func postGoal() {
        
        // 넣는 순서도 순서대로여야 하는 것 같다.
        let goal = Goal(image: imagebase64 ?? "디폴트이미지", goal_amount: Int(GoalPriceTextField.text ?? "0")!, init_amount: Int(InitPriceTextField.text ?? "0")!, category_name: GoalTextField.text ?? "디폴트 골", date: Date().toString())
        
        /*Goal(userIdx: 1, init_amount: Int(InitPriceTextField.text ?? "0")!, goal_amount: Int(GoalPriceTextField.text ?? "0")!, GoalName: GoalTextField.text ?? "디폴트 골", GoalImage: imagebase64 ?? "디폴트이미지")*/
        guard let uploadData = try? JSONEncoder().encode(goal)
        else {return}
        
        // URL 객체 정의
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        let url = URL(string: "https://www.pigmoney.xyz/goal/createGoal/\(userIdx)")
        
        // URLRequest 객체를 정의
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        // HTTP 메시지 헤더
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
        
        request.httpBody = uploadData
        print(String(data: uploadData, encoding: .utf8)!)
        
        // URLSession 객체를 통해 전송, 응답값 처리
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            
            // 서버가 응답이 없거나 통신이 실패
            if let e = error {
                NSLog("An error has occured: \(e.localizedDescription)")
                return
            }
            // 응답 처리 로직
            guard let data = data else { return }
            
            // data
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(responseP.self, from: data) {
                print(json.message)
            }
        }
            // POST 전송
            task.resume()
        
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
        
        
        func convertImageToBase64(image: UIImage) -> String {
            let imageData = image.pngData()!
            return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) }
        
        
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                image = image.resized(toWidth: 90.0) ?? image
                ImgUI.setImage(image, for: .normal)
                imagebase64 = convertImageToBase64(image: image)
                
            }
            
            dismiss(animated: true, completion: nil)
        }
        
    
    
    @IBAction func tapRegisterButton(_ sender: UIButton) {
        postGoal()
        self.navigationController?.popViewController(animated: true)
        
    }
 
  
    
}


    

