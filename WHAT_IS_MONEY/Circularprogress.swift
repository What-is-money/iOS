//
//  Circularprogress.swift
//  WHAT_IS_MONEY
//
//  Created by jinyong yun on 2023/02/07.
//

import Foundation
import UIKit


// MARK: - [전역 변수 선언 실시]
var vProgress : UIView?



// MARK: - [extension 정의 실시 : 뷰 컨트롤러]
extension UIViewController {
    
    // MARK: [원형 프로그레스 시작 메소드]
    // [호출 방법 : self.progressStart(onView: self.view)]
    func progressStart(onView : UIView) {
        print("")
        print("===============================")
        print("[S_Extension >> progressStart() :: 로딩 프로그레스 시작 실시]")
        print("===============================")
        print("")
        // [프로그레스를 담는 부모 뷰 : 검정색]
        let progressView = UIView.init(frame: onView.bounds)
        progressView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        // [Indicator : 원형 프로그레스 생성 실시]
        let activityIndicator = UIActivityIndicatorView()
        
        // [사이즈 지정 실시]
        //activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        
        // [위치 지정 실시]
        activityIndicator.center = progressView.center
        
        // [색상 지정 실시]
        activityIndicator.color = UIColor.red
    
        // [hidden 시 애니메이션 종료 여부 지정]
        activityIndicator.hidesWhenStopped = true
        
        // [스타일 지정 실시]
        activityIndicator.style = UIActivityIndicatorView.Style.white
    
        // [애니메이션 시작 수행]
        activityIndicator.startAnimating()
        
        // [비동기 ui 처리 수행 실시]
        DispatchQueue.main.async {
            progressView.addSubview(activityIndicator) // 부모에 Indicator 자식 추가
            onView.addSubview(progressView) // 뷰컨트롤러에 부모 추가
        }
        vProgress = progressView
    }
    
    
    
    // MARK: [원형 프로그레스 종료 메소드]
    // [호출 방법 : self.progressStop()]
    func progressStop() {
        print("")
        print("===============================")
        print("[S_Extension >> progressStop() :: 로딩 프로그레스 종료 실시]")
        print("===============================")
        print("")
        DispatchQueue.main.async {
            vProgress?.removeFromSuperview() // 뷰에서 제거 실시
            vProgress = nil
        }
    }
}
