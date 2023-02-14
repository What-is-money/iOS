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


class GoalAddViewController: UIViewController, UINavigationControllerDelegate & UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var ImgUI: UIButton!
    @IBOutlet weak var GoalTextField: UITextField!
    @IBOutlet weak var GoalPriceTextField: UITextField!
    @IBOutlet weak var InitPriceTextField: UITextField!
    @IBOutlet weak var CompleteButtton: UIButton!
    
    var goalIdx: Int?
    let picker = UIImagePickerController()
    var imageData : NSData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        GoalTextField.delegate = self
        GoalPriceTextField.delegate = self
        InitPriceTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
    
    
    // MARK: - [URL Session Post 멀티 파트 사진 데이터 업로드]
       func requestPOST() {
           
           // MARK: [사진 파일 파라미터 이름 정의 실시]
           let file = "image"
           
           let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
           let accessToken = UserDefaults.standard.string(forKey: "accessToken")
           
           
           // MARK: [전송할 데이터 파라미터 정의 실시]
           var reqestParam : Dictionary<String, Any> = [String : Any]()
           //reqestParam["userIdx"] = userIdx // 일반 파라미터
           reqestParam["\(file)"] = self.imageData // 사진 파일
           
           // MARK: [URL 지정 실시]
           let urlComponents = URLComponents(string: "https://www.pigmoney.xyz/goal/uploadGoalImage/\(goalIdx!)/\(userIdx)")
           print("\n\n\n여기가 마지막 보루다!!:", urlComponents as Any)
           // [boundary 설정 : 바운더리 라인 구분 필요 위함]
           let boundary = "Boundary-\(UUID().uuidString)" // 고유값 지정
           
           print("")
           print("====================================")
           print("[A_Image >> requestPOST() :: 바운더리 라인 구분 확인 실시]")
           print("boundary :: ", boundary)
           print("====================================")
           print("")
           
           
           // [http 통신 타입 및 헤더 지정 실시]
           var requestURL = URLRequest(url: (urlComponents?.url)!) // url 주소 지정
           requestURL.httpMethod = "POST" // POST 방식
           requestURL.setValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
           requestURL.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type") // 멀티 파트 타입
           print("header!!!",requestURL.allHTTPHeaderFields as Any)
           
           // [서버로 전송할 uploadData 데이터 형식 설정]
           var uploadData = Data()
           let boundaryPrefix = "--\(boundary)\r\n"
           
           
           
           // [멀티 파트 전송 파라미터 삽입 : 딕셔너리 for 문 수행]
           for (key, value) in reqestParam {
               if "\(key)" == "\(file)" { // MARK: [사진 파일 인 경우]
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 멀티 파트 전송 파라미터 확인 실시]")
                   print("타입 :: ", "사진 파일")
                   print("key :: ", key)
                   print("value :: ", value)
                   print("====================================")
                   print("")
                   
                   uploadData.append(boundaryPrefix.data(using: .utf8)!)
                   uploadData.append("Content-Disposition: form-data; name=\"\(file)\"; filename=\"\(file)\"\r\n".data(using: .utf8)!) // [파라미터 key 지정]
                   uploadData.append("Content-Type: \("image/jpg")\r\n\r\n".data(using: .utf8)!) // [전체 이미지 타입 설정]
                   uploadData.append(value as! Data) // [사진 파일 삽입]
                   uploadData.append("\r\n".data(using: .utf8)!)
                   uploadData.append("--\(boundary)--".data(using: .utf8)!)
               }
               else { // MARK: [일반 파라미터인 경우]
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 멀티 파트 전송 파라미터 확인 실시]")
                   print("타입 :: ", "일반 파라미터")
                   print("key :: ", key)
                   print("value :: ", value)
                   print("====================================")
                   print("")
                   
                   uploadData.append(boundaryPrefix.data(using: .utf8)!)
                   uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!) // [파라미터 key 지정]
                   uploadData.append("\(value)\r\n".data(using: .utf8)!) // [value 삽입]
               }
           }

           
           
           // [http 요쳥을 위한 URLSessionDataTask 생성]
           print("")
           print("====================================")
           print("[A_Image >> requestPOST() :: 사진 업로드 요청 실시]")
           print("url :: ", requestURL)
           print("uploadData :: ", uploadData)
           print("====================================")
           print("")
           
           // MARK: [URLSession uploadTask 수행 실시]
           let dataTask = URLSession(configuration: .default)
           dataTask.configuration.timeoutIntervalForRequest = TimeInterval(20)
           dataTask.configuration.timeoutIntervalForResource = TimeInterval(20)
           dataTask.uploadTask(with: requestURL, from: uploadData) { (data: Data?, response: URLResponse?, error: Error?) in

               // [error가 존재하면 종료]
               guard error == nil else {
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 사진 업로드 요청 실패]")
                   print("fail : ", error?.localizedDescription ?? "")
                   print("====================================")
                   print("")
                   return
               }

               // [status 코드 체크 실시]
               let successsRange = 200..<300
               guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
               else {
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                   print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                   print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                   print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                   print("====================================")
                   print("")
                   return
               }

               // [response 데이터 획득, json 형태로 변환]
               let resultCode = (response as? HTTPURLResponse)?.statusCode ?? 0
               let resultLen = data! // 데이터 길이
               do {
                   guard let jsonConvert = try JSONSerialization.jsonObject(with: data!) as? [String: Any] else {
                       print("")
                       print("====================================")
                       print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                       print("error : ", "json 형식 데이터 convert 에러")
                       print("====================================")
                       print("")
                       return
                   }
                   guard let JsonResponse = try? JSONSerialization.data(withJSONObject: jsonConvert, options: .prettyPrinted) else {
                       print("")
                       print("====================================")
                       print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                       print("error : ", "json 형식 데이터 변환 에러")
                       print("====================================")
                       print("")
                       return
                   }
                   guard let resultString = String(data: JsonResponse, encoding: .utf8) else {
                       print("")
                       print("====================================")
                       print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                       print("error : ", "json 형식 데이터 >> String 변환 에러")
                       print("====================================")
                       print("")
                       return
                   }
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 사진 업로드 요청 성공]")
                   print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                   print("resultCode : ", resultCode)
                   print("resultLen : ", resultLen)
                   print("resultString : ", resultString)
                   print("====================================")
                   print("")
               } catch {
                   print("")
                   print("====================================")
                   print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                   print("error : ", "Trying to convert JSON data to string")
                   print("====================================")
                   print("")
                   return
               }
           }.resume()
       }


    
    
    func postGoal(){
        
        // 넣는 순서도 순서대로여야 하는 것 같다.
        let goal = Goal(goal_amount: Int(GoalPriceTextField.text ?? "0")!, init_amount: Int(InitPriceTextField.text ?? "0")!, category_name: GoalTextField.text ?? "디폴트 골", date: Date().toString())
        
        print(goal)
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
        
        
        //let semaphore = DispatchSemaphore(value: 0)
        
        // URLSession 객체를 통해 전송, 응답값 처리
                
       URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            
            // 서버가 응답이 없거나 통신이 실패
            if let e = error {
                NSLog("An error has occured: \(e.localizedDescription)")
                return
            }
            // 응답 처리 로직
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            // data
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(responseP.self, from: data) {
                // DispatchQueue.main.async {
                
                self.goalIdx = json.result.goalIdx
                print("goalIdx:" , self.goalIdx as Any)
                
                //}
            }
            
            
            
            
            
            
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
            if var img = info[UIImagePickerController.InfoKey.originalImage]{
                //img = img.resized(toWidth: 90.0) ?? img
                // [앨범에서 선택한 사진 정보 확인]
                print("")
                print("====================================")
                print("[A_Image >> imagePickerController() :: 앨범에서 선택한 사진 정보 확인 및 사진 표시 실시]")
                print("[사진 정보 :: ", info)
                print("====================================")
                print("")
                
                img = (img as? UIImage)!.resized(toWidth: 240.0) ?? img
                let newimg = (img as? UIImage)!.resized(toWidth: 90.0) ?? img
                ImgUI.layer.cornerRadius = ImgUI.layer.frame.size.width / 2
                ImgUI.setImage(newimg as? UIImage, for: .normal)
                // [이미지 뷰에 앨범에서 선택한 사진 표시 실시]
                //self.imageView.image = img as? UIImage
                //imagepickButton.setImage((img as! UIImage), for: .normal)
                
                // [이미지 데이터에 선택한 이미지 지정 실시]
                self.imageData = (img as? UIImage)!.jpegData(compressionQuality: 0.8) as NSData? // jpeg 압축 품질 설정
                
                
                // [멀티파트 서버에 사진 업로드 수행]
               /* DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // [1초 후에 동작 실시]
                    self.requestPOST()
                } */
            }
            // [이미지 파커 닫기 수행]
            dismiss(animated: true, completion: nil)
        }
        
        
    
    
    @IBAction func tapRegisterButton(_ sender: UIButton) {
        
        let goaltext = GoalTextField.text
        let goalpricetext = GoalPriceTextField.text
        let initpricetext = InitPriceTextField.text
        
        
        if ImgUI.currentImage == UIImage(named: "plus") || goaltext?.isEmpty ?? true || goalpricetext?.isEmpty ?? true || initpricetext?.isEmpty ?? true {
            print(ImgUI.currentImage == UIImage(named: "plus"))
            print(goaltext?.isEmpty as Any)
            print(goalpricetext?.isEmpty as Any)
            print(initpricetext?.isEmpty as Any)
            let sheet = UIAlertController(title: "경고", message: "모든 입력칸에 올바르게 입력하였는지 확인해주세요", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in print("빈 입력칸 확인") }))
            present(sheet, animated: true)
            return
        }
        
        
        
        postGoal()
        
        self.progressStart(onView: self.view)
               
               
               // [일정 시간 후 작업 수행 : 로딩 프로그레스 종료 호출]
         DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // [6초 후에 동작 실시]
                   print("")
                   print("===============================")
                   print("[ViewController >> viewDidLoad() :: 시간 만료]")
                   print("===============================")
                   print("")
                   self.progressStop()
               }

      
        
        print("goalIdx는 이거다!!: ", goalIdx as Any)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3){
            self.requestPOST()
            self.navigationController?.popViewController(animated: true)
        }
    
        
    }
 
  
    
}


    

