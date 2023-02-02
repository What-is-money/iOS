//
//  GoalEditViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/20.
//

import UIKit




protocol ImagePickerDelegate : AnyObject {
    func clickButton()
}

struct patchgoal: Codable {
    let amount: Int
    let category_name: String
    let image: String
    let goal_amount: Int
    
}

struct goallistresponseone: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: goalresult
    
    
}

struct goalpatchresponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    
}


class GoalEditViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate {

 
    @IBOutlet weak var ImgLabel: UILabel!
    @IBOutlet weak var ImgUI: UIButton!
    @IBOutlet weak var GoalNameTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var PriceTextField: UITextField!
    @IBOutlet weak var CompleteButton: UIButton!
    
    let picker = UIImagePickerController()
    var goalresult: goalresult?
        var goalIdx: Int?
    var patchgoalone: patchgoal?
    var oldImage: String?
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillappear")
        print(goalIdx as Any)
        self.loadgoal()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary // 앨범에서 가져옴
        picker.allowsEditing = true
    }
    
    
    func configureView(){
        ImgLabel.text = "사진수정"
        let data = Data(base64Encoded: goalresult!.image, options: .ignoreUnknownCharacters) ?? Data()
        var decodeImg = UIImage(data: data)
        decodeImg = decodeImg?.resized(toWidth: 90.0) ?? decodeImg
        self.ImgUI.setImage(decodeImg, for: .normal)
        GoalNameTextField.text = goalresult?.category_name
        GoalPriceTextField.text = String(goalresult?.goal_amount ?? 0)
        PriceTextField.text = String(goalresult?.amount ?? 0)
        
        
    }
    
    /*
     image = image.resized(toWidth: 90.0) ?? image
     ImgUI.setImage(image, for: .normal)
     imagebase64 = convertImageToBase64(image: image)
     */
    
    func loadgoal(){
            let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
            if let url = URL(string: "https://www.pigmoney.xyz/goal/getGoal/\(goalIdx!)/\(userIdx)"){
                
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
                
                DispatchQueue.global().async {
                    do {
                        
                        URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                            
                            guard let data = data else {
                                print("Error: Did not receive data")
                                return
                            }
                            
                            print(String(data: data, encoding: .utf8)!)
                            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                                print("Error: HTTP request failed")
                                return
                            }
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(goallistresponseone.self, from: data) {
                                self.goalresult =  json.result
                                self.oldImage = json.result.image
                                DispatchQueue.main.async {
                                    self.configureView()
                                }
                                
                            }
                            
                        }.resume() //URLSession - end
                        
                        
                    }
                }
            }
            
        }
        
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters) }
        
    
    
        func patchGoal() {
            // 넣는 순서도 순서대로여야 하는 것 같다.
            print("\n\n\n\n\n\n")
            print("여기 꼭 확인해라 좋은 말 할 때")
            print(oldImage == self.convertImageToBase64(image: ImgUI.currentImage!))
            print(convertImageToBase64(image: ImgUI.currentImage!))
            print(GoalPriceTextField.text as Any)
            print(PriceTextField.text as Any)
            print(GoalNameTextField.text as Any)
            print("확인 끝")
            print("\n\n\n\n\n\n")
            
            
            let patchgoal = patchgoal(amount: Int(PriceTextField.text ?? "5") ?? 5, category_name: GoalNameTextField.text ?? "알 수 없음", image: convertImageToBase64(image: ImgUI.currentImage!), goal_amount: Int(GoalPriceTextField.text ?? "5") ?? 5)
            /*let patchgoal = patchgoal(image: convertImageToBase64(image: ImgUI.currentImage!), goal_amount: Int(GoalPriceTextField.text ?? "5") ?? 5, init_amount: Int(InitPriceTextField.text ?? "5") ?? 5, category_name: GoalNameTextField.text ?? "알 수 없음")*/
            
            print("\n\n\n\n\n")
            print("=================")
            print("여기도 확인")
            print(oldImage == self.convertImageToBase64(image: ImgUI.currentImage!))
            print(patchgoal)
            print("=================")
            print("\n\n\n\n\n")
                                      
            guard let uploadData = try? JSONEncoder().encode(patchgoal) else {return}
            
            print("\n\n\n\n\n")
            print("=================")
            print("업로드 데이터")
            print(uploadData.self)
            print("=================")
            print("\n\n\n\n\n")
            
            
            // URL 객체 정의
            let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
            let url = URL(string: "https://www.pigmoney.xyz/goal/modifyGoal/\(goalIdx!)/\(userIdx)")

            
            // URLRequest 객체를 정의
            var request = URLRequest(url: url!)
            request.httpMethod = "PATCH"
            // HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            request.httpBody = uploadData
            print("###############업로드 데이터다###################")
            print(String(data: uploadData, encoding: .utf8)!)
    
                    // URLSession 객체를 통해 전송, 응답값 처리
                    URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return
                        }
                        
                        print("**************응답데이터*****************")
                        print(String(data: data, encoding: .utf8)!)
                        print("**************응답데이터*****************")
                        
                        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                            print("Error: HTTP request failed")
                            return
                        }
                        
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(goalpatchresponse.self, from: data) {
                            print(json.message)
                            
                        }
                        // POST 전송
                    }.resume()
               
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
            (action) in self.ImgUI.setImage(UIImage(named: "defaultImage")?.resized(toWidth: 90), for: .normal)
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

                }

        dismiss(animated: true, completion: nil)
    }
  
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        self.PriceTextField.endEditing(true)
        patchGoal()
        guard let GoalDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoalDetailViewController") as? GoalDetailViewController else {return}
        GoalDetailViewController.goalIdx = goalIdx!
        print(GoalDetailViewController.goalIdx)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
