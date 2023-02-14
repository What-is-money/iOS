//
//  WholeSettingViewController.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/01/03.
//

import UIKit


class WholeSettingViewController: UIViewController {

    @IBOutlet weak var ProfileView: UIView!
    
    @IBOutlet weak var AlertSwitch: UISwitch!
    
    @IBOutlet weak var QuestionView: UIView!
    
    @IBOutlet weak var PrivateInfView: UIView!
    
    @IBOutlet weak var LogoutView: UIView!
    
    @IBOutlet weak var WithDrawalView: UIView!
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserIDLabel: UILabel!
    
    @IBOutlet weak var ProfileImg: UIImageView!
    
    override func viewDidLoad() {
    super.viewDidLoad()

        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.goProfileEdit(sender:)))
    self.ProfileView.addGestureRecognizer(gesture1)
        let gesture4 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.goQuestion(sender:)))
        self.QuestionView.addGestureRecognizer(gesture4)
        let gesturealert1 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showSIAlert(sender:)))
        self.PrivateInfView.addGestureRecognizer(gesturealert1)
        let gesturealert2 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showLogoutAlert(sender:)))
        self.LogoutView.addGestureRecognizer(gesturealert2)
        let gesturealert3 = UITapGestureRecognizer(target: self, action: #selector(WholeSettingViewController.showWDAlert(sender:)))
        self.WithDrawalView.addGestureRecognizer(gesturealert3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        TokenClass.handlingToken()
        getUserInfo()
    }

    func getUserInfo() {
        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

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
                      
                    
                        if (image?.count == 0 || image == nil) {
                            self.ProfileImg.image = UIImage(named: "jinperson")
                            
                        } else {
                            if let data = Data(base64Encoded: image!, options: .ignoreUnknownCharacters) {
                                let decodedImg = UIImage(data: data)
                                self.ProfileImg.layer.cornerRadius = self.ProfileImg.frame.height/2
                                self.ProfileImg.layer.borderWidth = 1
                                self.ProfileImg.layer.borderColor = UIColor.clear.cgColor
                                // 뷰의 경계에 맞춰준다
                                self.ProfileImg.clipsToBounds = true
                                self.ProfileImg.image = decodedImg
                                
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
    
    @objc func goProfileEdit(sender:UIGestureRecognizer){
           let storyboard  = UIStoryboard(name: "Main", bundle: nil)
           let profileEditViewController = storyboard.instantiateViewController(withIdentifier:"ProfileEditViewController")
           self.navigationController!.pushViewController(profileEditViewController, animated: true)
       }
 
    @IBAction func toggleClicked(_ sender: UISwitch) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
        guard let url = URL(string: "https://www.pigmoney.xyz/users/alarm") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let userIdx: Int
            let alarm: Bool
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(userIdx: userIdx, alarm: AlertSwitch.isOn)
        
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData

        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling POST")
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Error: Did not receive data")
                    return
                }
 
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
                        guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                            print("Error: Couldn't print JSON in String")
                            return
                        }
                        
                        let isSuccess = jsonObject["isSuccess"] as? Bool
                        let result = jsonObject["result"] as? String
                        if isSuccess == true {
                            let sheet = UIAlertController(title: "안내", message: result, preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                                print("알림설정") }))
                            self.present(sheet, animated: true)
                        } else {
                          print("오류 발생")
                        }
                    } catch {
                        print("Error: Trying to convert JSON data to string")
                        return
                    }
                }
                
            }.resume()
        }
        
    }
    
    @objc func goQuestion(sender:UIGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let QuestionViewController = storyboard.instantiateViewController(withIdentifier: "QuestionViewController")
        self.navigationController!.pushViewController(QuestionViewController, animated: true)
        
    }
    
    @objc func showSIAlert(sender:UIGestureRecognizer){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        let messageText = NSMutableAttributedString(
            string: """
        
        < 머니뭐니 >('https://www.pigmoney.xyz/'이하 '머니뭐니')은(는) 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.

        ○ 이 개인정보처리방침은 2023년 1월 1부터 적용됩니다.


        제1조(개인정보의 처리 목적)

        < 머니뭐니 >('https://www.pigmoney.xyz/'이하 '머니뭐니')은(는) 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며 이용 목적이 변경되는 경우에는 「개인정보 보호법」 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

        1. 홈페이지 회원가입 및 관리

        회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지, 만14세 미만 아동의 개인정보 처리 시 법정대리인의 동의여부 확인, 각종 고지·통지, 고충처리 목적으로 개인정보를 처리합니다.


        2. 민원사무 처리

        민원사항 확인, 처리결과 통보 목적으로 개인정보를 처리합니다.


        3. 재화 또는 서비스 제공

        맞춤서비스 제공을 목적으로 개인정보를 처리합니다.




        제2조(개인정보의 처리 및 보유 기간)

        ① < 머니뭐니 >은(는) 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

        ② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.

        1.<홈페이지 회원가입 및 관리>
        <홈페이지 회원가입 및 관리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<회원탈퇴시까지>까지 위 이용목적을 위하여 보유.이용됩니다.
        보유근거 : 법령
        관련법령 : 1)신용정보의 수집/처리 및 이용 등에 관한 기록 : 3년
        2) 소비자의 불만 또는 분쟁처리에 관한 기록 : 3년
        예외사유 :


        제3조(처리하는 개인정보의 항목)

        ① < 머니뭐니 >은(는) 다음의 개인정보 항목을 처리하고 있습니다.

        1< 홈페이지 회원가입 및 관리 >
        필수항목 : 이메일, 비밀번호, 로그인ID, 이름, 서비스 이용 기록, 개인저축소비정보
        선택항목 :


        제4조(만 14세 미만 아동의 개인정보 처리에 관한 사항)



        ① <개인정보처리자명>은(는) 만 14세 미만 아동에 대해 개인정보를 수집할 때 법정대리인의 동의를 얻어 해당 서비스 수행에 필요한 최소한의 개인정보를 수집합니다.

        • 필수항목 : 법정 대리인의 성명, 관계, 연락처

        ② 또한, <개인정보처리자명>의 <처리목적> 관련 홍보를 위해 아동의 개인정보를 수집할 경우에는 법정대리인으로부터 별도의 동의를 얻습니다.

        ③ <개인정보처리자명>은(는) 만 1 4세 미만 아동의 개인정보를 수집할 때에는 아동에게 법정대리인의 성명, 연락처와 같이 최소한의 정보를 요구할 수 있으며, 다음 중 하나의 방법으로 적법한 법정대리인이 동의하였는지를 확인합니다.

        • 동의 내용을 게재한 인터넷 사이트에 법정대리인이 동의 여부를 표시하도록 하고 개인정보처리자가 그 동의 표시를 확인했음을 법정대리인의 휴대전화 문자 메시지로 알리는 방법

        • 동의 내용을 게재한 인터넷 사이트에 법정대리인이 동의 여부를 표시하도록 하고 법정대리인의 신용카드·직불카드 등의 카드정보를 제공받는 방법

        • 동의 내용을 게재한 인터넷 사이트에 법정대리인이 동의 여부를 표시하도록 하고 법정대리인의 휴대전화 본인인증 등을 통해 본인 여부를 확인하는 방법

        • 동의 내용이 적힌 서면을 법정대리인에게 직접 발급하거나, 우편 또는 팩스를 통하여 전달하고 법정대리인이 동의 내용에 대하여 서명날인 후 제출하도록 하는 방법

        • 동의 내용이 적힌 전자우편을 발송하여 법정대리인으로부터 동의의 의사표시가 적힌 전자우편을 전송받는 방법

        • 전화를 통하여 동의 내용을 법정대리인에게 알리고 동의를 얻거나 인터넷주소 등 동의 내용을 확인할 수 있는 방법을 안내하고 재차 전화 통화를 통하여 동의를 얻는 방법

        • 그 밖에 위와 준하는 방법으로 법정대리인에게 동의 내용을 알리고 동의의 의사표시를 확인하는 방법



        제5조(개인정보의 파기절차 및 파기방법)


        ① < 머니뭐니 > 은(는) 개인정보 보유기간의 경과(보유기간 0일), 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

        ② 정보주체로부터 동의받은 개인정보 보유기간이 경과하거나 처리목적이 달성되었음에도 불구하고 다른 법령에 따라 개인정보를 계속 보존하여야 하는 경우에는, 해당 개인정보를 별도의 데이터베이스(DB)로 옮기거나 보관장소를 달리하여 보존합니다.
        1. 법령 근거 :
        2. 보존하는 개인정보 항목 : 계좌정보, 거래날짜

        ③ 개인정보 파기의 절차 및 방법은 다음과 같습니다.
        1. 파기절차
        < 머니뭐니 > 은(는) 파기 사유가 발생한 개인정보를 선정하고, < 머니뭐니 > 의 개인정보 보호책임자의 승인을 받아 개인정보를 파기합니다.



        제6조(미이용자의 개인정보 파기 등에 관한 조치)



        ① <개인정보처리자명>은(는) 1년간 서비스를 이용하지 않은 이용자의 정보를 파기하고 있습니다. 다만, 다른 법령에서 정한 보존기간이 경과할 때까지 다른 이용자의 개인정보와 분리하여 별도로 저장·관리할 수 있습니다.
        ② 개인정보의 파기를 원하지 않으시는 경우, 기간 만료 전 서비스 로그인을 하시면 됩니다.


        제7조(정보주체와 법정대리인의 권리·의무 및 그 행사방법에 관한 사항)



        ① 정보주체는 머니뭐니에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.

        ② 제1항에 따른 권리 행사는머니뭐니에 대해 「개인정보 보호법」 시행령 제41조제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 머니뭐니은(는) 이에 대해 지체 없이 조치하겠습니다.

        ③ 제1항에 따른 권리 행사는 정보주체의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다.이 경우 “개인정보 처리 방법에 관한 고시(제2020-7호)” 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.

        ④ 개인정보 열람 및 처리정지 요구는 「개인정보 보호법」 제35조 제4항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.

        ⑤ 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.

        ⑥ 머니뭐니은(는) 정보주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인인지를 확인합니다.



        제8조(개인정보의 안전성 확보조치에 관한 사항)

        < 머니뭐니 >은(는) 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.

        1. 개인정보 취급 직원의 최소화 및 교육
        개인정보를 취급하는 직원을 지정하고 담당자에 한정시켜 최소화 하여 개인정보를 관리하는 대책을 시행하고 있습니다.

        2. 개인정보에 대한 접근 제한
        개인정보를 처리하는 데이터베이스시스템에 대한 접근권한의 부여,변경,말소를 통하여 개인정보에 대한 접근통제를 위하여 필요한 조치를 하고 있으며 침입차단시스템을 이용하여 외부로부터의 무단 접근을 통제하고 있습니다.




        제9조(개인정보를 자동으로 수집하는 장치의 설치·운영 및 그 거부에 관한 사항)



        머니뭐니 은(는) 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키(cookie)’를 사용하지 않습니다.


        제10조(행태정보의 수집·이용·제공 및 거부 등에 관한 사항)



        ① <개인정보처리자>은(는) 서비스 이용과정에서 정보주체에게 최적화된 맞춤형 서비스 및 혜택, 온라인 맞춤형 광고 등을 제공하기 위하여 행태정보를 수집·이용하고 있습니다.

        ② <개인정보처리자>은(는) 다음과 같이 행태정보를 수집합니다.

        10. 행태정보의 수집·이용·제공 및 거부 등에 관한 사항 제공을 위해 수집하는 행태정보의 항목, 행태정보 수집 방법, 행태정보 수집 목적, 보유·이용기간 및 이후 정보처리 방법을 입력하기 위한 표입니다.
        수집하는 행태정보의 항목    행태정보 수집 방법    행태정보 수집 목적    보유·이용기간 및 이후 정보처리 방법
        이옹자 아이디, 비밀번호, 이메일 주소, 저축 금액, 저축 항목, 저축 일자, 소비 금액, 소비 항목, 소비 일자    이용자가 직접 입력    이용자의 해당 앱 이용    수집일로부터 회원 탈퇴시까지 유지
        <온라인 맞춤형 광고 등을 위해 제3자(온라인 광고사업자 등)가 이용자의 행태정보를 수집·처리할수 있도록 허용한 경우>
        ③ <개인정보처리자>은(는) 다음과 같이 온라인 맞춤형 광고 사업자가 행태정보를 수집·처리하도록 허용하고 있습니다.

        - 행태정보를 수집 및 처리하려는 광고 사업자 : ○○○, ○○○, ○○○, ○○○,

        - 행태정보 수집 방법 : 이용자가 당사 웹사이트를 방문하거나 앱을 실행할 때 자동 수집 및 전송

        - 수집·처리되는 행태정보 항목 : 이용자의 웹/앱 방문이력, 검색이력, 구매이력

        - 보유·이용기간 : 00일

        ④ <개인정보처리자>은(는) 온라인 맞춤형 광고 등에 필요한 최소한의 행태정보만을 수집하며, 사상, 신념, 가족 및 친인척관계, 학력·병력, 기타 사회활동 경력 등 개인의 권리·이익이나 사생활을 뚜렷하게 침해할 우려가 있는 민감한 행태정보를 수집하지 않습니다.
        ⑤ <개인정보처리자>은(는) 만 14세 미만임을 알고 있는 아동이나 만14세 미만의 아동을 주 이용자로 하는 온라인 서비스로부터 맞춤형 광고 목적의 행태정보를 수집하지 않고, 만 14세 미만임을 알고 있는 아동에게는 맞춤형 광고를 제공하지 않습니다.

        ⑥ <개인정보처리자>은(는) 모바일 앱에서 온라인 맞춤형 광고를 위하여 광고식별자를 수집·이용합니다. 정보주체는 모바일 단말기의 설정 변경을 통해 앱의 맞춤형 광고를 차단·허용할 수 있습니다.

        ‣ 스마트폰의 광고식별자 차단/허용

        (1) (안드로이드) ① 설정 → ② 개인정보보호 → ③ 광고 → ③ 광고 ID 재설정 또는 광고ID 삭제

        (2) (아이폰) ① 설정 → ② 개인정보보호 → ③ 추적 → ④ 앱이 추적을 요청하도록 허용 끔

        ※ 모바일 OS 버전에 따라 메뉴 및 방법이 다소 상이할 수 있습니다.

        ⑦ 정보주체는 웹브라우저의 쿠키 설정 변경 등을 통해 온라인 맞춤형 광고를 일괄적으로 차단·허용할 수 있습니다. 다만, 쿠키 설정 변경은 웹사이트 자동로그인 등 일부 서비스의 이용에 영향을 미칠 수 있습니다.

        ‣ 웹브라우저를 통한 맞춤형 광고 차단/허용

        (1) 인터넷 익스플로러(Windows 10용 Internet Explorer 11)

        - Internet Explorer에서 도구 버튼을 선택한 다음 인터넷 옵션을 선택

        - 개인 정보 탭을 선택하고 설정에서 고급을 선택한 다음 쿠키의 차단 또는 허용을 선택

        (2) Microsoft Edge

        - Edge에서 오른쪽 상단 ‘…’ 표시를 클릭한 후, 설정을 클릭합니다.

        - 설정 페이지 좌측의 ‘개인정보, 검색 및 서비스’를 클릭 후 「추적방지」 섹션에서 ‘추적방지’ 여부 및 수준을 선택합니다.

        - ‘InPrivate를 검색할 때 항상 ""엄격"" 추적 방지 사용’ 여부를 선택합니다.

        - 아래 「개인정보」 섹션에서 ‘추적 안함 요청보내기’ 여부를 선택합니다.

        (3) 크롬 브라우저

        - Chrome에서 오른쪽 상단 ‘⋮’ 표시(chrome 맞춤설정 및 제어)를 클릭한 후, 설정 표시를 클릭합니다.

        - 설정 페이지 하단에 ‘고급 설정 표시’를 클릭하고 「개인정보」 섹션에서 콘텐츠 설정을 클릭합니다.

        - 쿠키 섹션에서 ‘타사 쿠키 및 사이트 데이터 차단’의 체크박스를 선택합니다.

        52 | 개인정보 처리방침 작성지침 일반

        ⑧ 정보주체는 아래의 연락처로 행태정보와 관련하여 궁금한 사항과 거부권 행사, 피해 신고 접수 등을 문의할 수 있습니다.

        ‣ 개인정보 보호 담당부서

        부서명 : ○○○ 팀

        담당자 : ○○○

        연락처 : <전화번호>, <이메일>, <팩스번호>



        제11조(추가적인 이용·제공 판단기준)

        < 머니뭐니 > 은(는) ｢개인정보 보호법｣ 제15조제3항 및 제17조제4항에 따라 ｢개인정보 보호법 시행령｣ 제14조의2에 따른 사항을 고려하여 정보주체의 동의 없이 개인정보를 추가적으로 이용·제공할 수 있습니다.
        이에 따라 < 머니뭐니 > 가(이) 정보주체의 동의 없이 추가적인 이용·제공을 하기 위해서 다음과 같은 사항을 고려하였습니다.
        ▶ 개인정보를 추가적으로 이용·제공하려는 목적이 당초 수집 목적과 관련성이 있는지 여부

        ▶ 개인정보를 수집한 정황 또는 처리 관행에 비추어 볼 때 추가적인 이용·제공에 대한 예측 가능성이 있는지 여부

        ▶ 개인정보의 추가적인 이용·제공이 정보주체의 이익을 부당하게 침해하는지 여부

        ▶ 가명처리 또는 암호화 등 안전성 확보에 필요한 조치를 하였는지 여부

        ※ 추가적인 이용·제공 시 고려사항에 대한 판단기준은 사업자/단체 스스로 자율적으로 판단하여 작성·공개함



        제12조(가명정보를 처리하는 경우 가명정보 처리에 관한 사항)

        < 머니뭐니 > 은(는) 다음과 같은 목적으로 가명정보를 처리하고 있습니다.

        ▶ 가명정보의 처리 목적

        - 직접작성 가능합니다.

        ▶ 가명정보의 처리 및 보유기간

        - 직접작성 가능합니다.

        ▶ 가명정보의 제3자 제공에 관한 사항(해당되는 경우에만 작성)

        - 직접작성 가능합니다.

        ▶ 가명정보 처리의 위탁에 관한 사항(해당되는 경우에만 작성)

        - 직접작성 가능합니다.

        ▶ 가명처리하는 개인정보의 항목

        - 직접작성 가능합니다.

        ▶ 법 제28조의4(가명정보에 대한 안전조치 의무 등)에 따른 가명정보의 안전성 확보조치에 관한 사항

        - 직접작성 가능합니다.

        제13조 (개인정보 보호책임자에 관한 사항)

        ① 머니뭐니 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.

        ▶ 개인정보 보호책임자
        성명 :윤진용
        직책 :PM
        직급 :PM
        연락처 :01025106462, dbswlsdyd730@naver.com,
        ※ 개인정보 보호 담당부서로 연결됩니다.


        ▶ 개인정보 보호 담당부서
        부서명 :머니뭐니서버팀
        담당자 :정두원
        연락처 :01071738238, ,
        ② 정보주체께서는 머니뭐니 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. 머니뭐니 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.

        제14조(개인정보의 열람청구를 접수·처리하는 부서)
        정보주체는 ｢개인정보 보호법｣ 제35조에 따른 개인정보의 열람 청구를 아래의 부서에 할 수 있습니다.
        < 머니뭐니 >은(는) 정보주체의 개인정보 열람청구가 신속하게 처리되도록 노력하겠습니다.

        ▶ 개인정보 열람청구 접수·처리 부서
        부서명 : 머니뭐니서버팀
        담당자 : 정두원
        연락처 : 01071738238, ,


        제15조(정보주체의 권익침해에 대한 구제방법)



        정보주체는 개인정보침해로 인한 구제를 받기 위하여 개인정보분쟁조정위원회, 한국인터넷진흥원 개인정보침해신고센터 등에 분쟁해결이나 상담 등을 신청할 수 있습니다. 이 밖에 기타 개인정보침해의 신고, 상담에 대하여는 아래의 기관에 문의하시기 바랍니다.

        1. 개인정보분쟁조정위원회 : (국번없이) 1833-6972 (www.kopico.go.kr)
        2. 개인정보침해신고센터 : (국번없이) 118 (privacy.kisa.or.kr)
        3. 대검찰청 : (국번없이) 1301 (www.spo.go.kr)
        4. 경찰청 : (국번없이) 182 (ecrm.cyber.go.kr)

        「개인정보보호법」제35조(개인정보의 열람), 제36조(개인정보의 정정·삭제), 제37조(개인정보의 처리정지 등)의 규정에 의한 요구에 대 하여 공공기관의 장이 행한 처분 또는 부작위로 인하여 권리 또는 이익의 침해를 받은 자는 행정심판법이 정하는 바에 따라 행정심판을 청구할 수 있습니다.

        ※ 행정심판에 대해 자세한 사항은 중앙행정심판위원회(www.simpan.go.kr) 홈페이지를 참고하시기 바랍니다.

        제16조(개인정보 처리방침 변경)


        ① 이 개인정보처리방침은 2023년 1월 1부터 적용됩니다.
        
        """,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )

        

        let alert = UIAlertController(title: "개인정보 처리방침", message: "", preferredStyle: .alert)
        alert.setValue(messageText, forKey: "attributedMessage")


        let Done = UIAlertAction(title: "확인", style: .default) { (action:UIAlertAction) in
            print("done")
        }
        alert.addAction(Done)

        self.present(alert, animated: true, completion: nil)
           
    }
    
    @objc func showLogoutAlert(sender:UIGestureRecognizer){
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "로그아웃", style: .destructive, handler: {(_) -> Void in

            let accessToken = UserDefaults.standard.string(forKey: "accessToken")
            let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
            
            guard let url = URL(string: "https://www.pigmoney.xyz/users/logout") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct UploadData: Codable {
                let accessToken: String
                let refreshToken: String
            }
            
            // Add data to the model
            let uploadDataModel = UploadData(accessToken: accessToken!, refreshToken: refreshToken!)
            
            
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
            request.httpBody = jsonData
            print(String(data: jsonData, encoding: .utf8)!)
            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil else {
                        print("Error: error calling POST")
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
                            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                                print("Error: Couldn't print JSON in String")
                                return
                            }
    
                     
                            let isSuccess = jsonObject["isSuccess"] as? Bool
                            
                            if isSuccess == true {
                                UserDefaults.standard.removeObject(forKey: "userIdx") //제거
                                UserDefaults.standard.removeObject(forKey: "accessToken") //제거
                                UserDefaults.standard.removeObject(forKey: "refreshToken") //제거
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                vc.modalPresentationStyle = .fullScreen
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                              print("오류 발생")
                            }
                        } catch {
                            print("Error: Trying to convert JSON data to string")
                            return
                        }
                    }
                    
                }.resume()
            }
        
        })

        let close = UIAlertAction(title: "안나갈래요", style: .default, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
                                    
    @objc func showWDAlert(sender:UIGestureRecognizer){

        let attributedString = NSAttributedString(string: "그동안 열심히 노력하신 목표와 여러분의 일꾼 아기돼지들을 다신 볼 수 없습니다. \n 그래도 탈퇴하시겠습니까?", attributes: [
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                    NSAttributedString.Key.foregroundColor : UIColor.red
                ])
        let alert = UIAlertController(title: "경고", message: "그동안 열심히 노력하신 목표와 여러분의 일꾼 아기돼지들을 다신 볼 수 없습니다. 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedMessage")
        let confirm = UIAlertAction(title: "탈퇴", style: .destructive, handler: {(_) -> Void in

            let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")
    
            
            guard let url = URL(string: "https://www.pigmoney.xyz/users/deleteUser/\(userIdx)") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct UploadData: Codable {
                let userIdx: Int
            }
            
            // Add data to the model
            let uploadDataModel = UploadData(userIdx: userIdx)
            
            
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue(accessToken!, forHTTPHeaderField: "X-ACCESS-TOKEN")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
            request.httpBody = jsonData

            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil else {
                        print("Error: error calling POST")
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
                            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                                print("Error: Couldn't print JSON in String")
                                return
                            }
     
                            
                            let isSuccess = jsonObject["isSuccess"] as? Bool
                            
                            if isSuccess == true {
                                UserDefaults.standard.removeObject(forKey: "userIdx") //제거
                                UserDefaults.standard.removeObject(forKey: "accessToken") //제거
                                UserDefaults.standard.removeObject(forKey: "refreshToken") //제거
                                let sheet = UIAlertController(title: "안내", message: "안전하게 회원탈퇴 되었습니다", preferredStyle: .alert)
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                vc.modalPresentationStyle = .fullScreen
                                sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ -> Void in
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                }))
                                self.present(sheet, animated: true)
   
                                
                            } else {
                              print("오류 발생")
                            }
                        } catch {
                            print("Error: Trying to convert JSON data to string")
                            return
                        }
                    }
                    
                }.resume()
            }
        
        })
        let close = UIAlertAction(title: "안할래요", style: .default, handler: nil)
        alert.addAction(confirm)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
  }
  

