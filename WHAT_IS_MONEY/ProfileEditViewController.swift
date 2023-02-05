//
//  ProfileEditViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/04.
//

import UIKit

class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var imagepickButton: UIButton!
    
    @IBOutlet weak var UserNameLabel: UILabel!
    
    @IBOutlet weak var UserIDLabel: UILabel!
    
    @IBOutlet weak var ChangeIDView: UIView!
    
    @IBOutlet weak var ChangeSNView: UIView!
    
    let picker = UIImagePickerController()
    var imageData : NSData? = nil
    
    
     
    override func viewWillAppear(_ animated: Bool) {
        TokenClass.handlingToken()
        getUserInfo()
    }

     
     
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(ProfileEditViewController.goChangeID(sender:)))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(ProfileEditViewController.goChangeSN(sender:)))
       
        self.ChangeIDView.addGestureRecognizer(gesture2)
        self.ChangeSNView.addGestureRecognizer(gesture3)
        
    }
    
    func getUserInfo() {
        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        print(useridx)
        guard let url = URL(string: "https://www.pigmoney.xyz/users/profile/\(useridx)") else {
                print("Error: cannot create URL")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling GET")
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Error: Did not receive data")
                    return
                }

                print(String(data: data, encoding: .utf8)!)
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return
                }
                DispatchQueue.main.async {
                    do {
                        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            print("Error: Cannot convert data to JSON object")
                            return
                        }
                        guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                            print("Error: Cannot convert JSON object to Pretty JSON data")
                            return
                        }
                        guard String(data: prettyJsonData, encoding: .utf8) != nil else {
                            print("Error: Couldn't print JSON in String")
                            return
                        }

                       
                    guard let result = jsonObject ["result"] as? [String: Any]
                        else { return }
                        let name = result ["name"] as? String
                        let id = result ["userId"] as? String
                        let image = result ["image"] as? String
                        print(result)
                        if (image?.count == 0 || image == nil) {
                            self.imagepickButton.setImage(UIImage(named: "jinperson2"), for: .normal)
                            //self.ProfileImg.image = UIImage(named: "jinperson")
                            
                        } else {
                            if let data = Data(base64Encoded: image!, options: .ignoreUnknownCharacters) {
                                let decodedImg = UIImage(data: data)
                                self.imagepickButton.layer.cornerRadius = self.imagepickButton.frame.height/2
                                self.imagepickButton.layer.borderWidth = 1
                                self.imagepickButton.layer.borderColor = UIColor.clear.cgColor
                                // 뷰의 경계에 맞춰준다
                                self.imagepickButton.clipsToBounds = true
                                self.imagepickButton.setImage(decodedImg, for: .normal)
                                
                            }
                        }
                        self.UserNameLabel.text = name
                        self.UserIDLabel.text = id
                     

                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
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
        let alert =  UIAlertController(title: "프로필 사진 설정", message: "사진 선택", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
        self.openCamera()
        }
//        let delete = UIAlertAction(title: "삭제", style: .destructive){
//            (action) -> Void in
//            self.requestPOST()
//            self.imagepickButton.setImage(UIImage(named: "jinperson"), for: .normal)
//                }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
//        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - [URL Session Post 멀티 파트 사진 데이터 업로드]
       func requestPOST() {
           
           // MARK: [사진 파일 파라미터 이름 정의 실시]
           let file = "image"
           
           let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
           let accessToken = UserDefaults.standard.string(forKey: "accessToken")
           
           
           // MARK: [전송할 데이터 파라미터 정의 실시]
           var reqestParam : Dictionary<String, Any> = [String : Any]()
           reqestParam["userIdx"] = userIdx // 일반 파라미터
           reqestParam["\(file)"] = self.imageData // 사진 파일
           
           // MARK: [URL 지정 실시]
           let urlComponents = URLComponents(string: "https://www.pigmoney.xyz/users/profile")
           
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
           
           let sheet = UIAlertController(title: "사진 업로드 에러", message: "다시 시도해주세요", preferredStyle: .alert)
           sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
           let sheet2 = UIAlertController(title: "사진 업로드 성공", message: "프로필사진 설정 완료", preferredStyle: .alert)
           sheet2.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
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
                   DispatchQueue.main.async {
                       self.present(sheet, animated: true)
                       print("")
                       print("====================================")
                       print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                       print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                       print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                       print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                       print("====================================")
                       print("")
                       
                     
                   }
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
                   DispatchQueue.main.async {
                       self.present(sheet2, animated: true)
                       print("")
                       print("====================================")
                       print("[A_Image >> requestPOST() :: 사진 업로드 요청 성공]")
                       print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                       print("resultCode : ", resultCode)
                       print("resultLen : ", resultLen)
                       print("resultString : ", resultString)
                       print("====================================")
                       print("")
                   }
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

       

   } // [클래스 종료]


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
   // MARK: [앨범 선택한 이미지 정보를 확인 하기 위한 딜리게이트 선언]
extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: [사진, 비디오 선택을 했을 때 호출되는 메소드]
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
            
            img = (img as? UIImage)!.resized(toWidth: 90.0) ?? img
            imagepickButton.layer.cornerRadius = imagepickButton.layer.frame.size.width / 2
            imagepickButton.setImage(img as? UIImage, for: .normal)
            // [이미지 뷰에 앨범에서 선택한 사진 표시 실시]
            //self.imageView.image = img as? UIImage
            //imagepickButton.setImage((img as! UIImage), for: .normal)
            
            // [이미지 데이터에 선택한 이미지 지정 실시]
            self.imageData = (img as? UIImage)!.jpegData(compressionQuality: 0.8) as NSData? // jpeg 압축 품질 설정
            
            
            // [멀티파트 서버에 사진 업로드 수행]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // [1초 후에 동작 실시]
                self.requestPOST()
            }
        }
        // [이미지 파커 닫기 수행]
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: [사진, 비디오 선택을 취소했을 때 호출되는 메소드]
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("")
        print("===============================")
        print("[A_Image >> imagePickerControllerDidCancel() :: 사진, 비디오 선택 취소 수행 실시]")
        print("===============================")
        print("")
        
        // [이미지 파커 닫기 수행]
        self.dismiss(animated: true, completion: nil)
    }
}








