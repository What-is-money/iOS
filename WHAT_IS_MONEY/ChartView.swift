//
//  ChartView.swift
//  WHAT_IS_MONEY
//
//  Created by 이예나 on 1/11/23.
//

//import UIKit
import SwiftUI

struct responseData: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [resultArray]
    
}
struct resultArray: Codable {
    let category_name: String
    let total_amount: Int
}

struct PieChartCell: Shape {
    let startAngle: Angle
    let endAngle: Angle
   func path(in rect: CGRect) -> Path {
        let center = CGPoint.init(x: (rect.origin.x + rect.width)/2, y: (rect.origin.y + rect.height)/2)
    let radii = min(center.x, center.y)
        let path = Path { p in
            p.addArc(center: center,
                     radius: radii,
                     startAngle: startAngle,
                     endAngle: endAngle,
                     clockwise: true)
            p.addLine(to: center)
        }
        return path
   }
}
struct PieChart: View {
    @State private var selectedCell: UUID = UUID()
    @EnvironmentObject var network: Network
    
    let dataModel: LastChartDataModel
    
    let onTap: (ChartCellModel?) -> ()
  
    
    var body: some View {

            ZStack {
                ForEach(dataModel.chartCellModel) { dataSet in
                    PieChartCell(startAngle: self.dataModel.angle(for: CGFloat(dataSet.value)), endAngle: self.dataModel.startingAngle)
                        .foregroundColor(dataSet.color)
                       .onTapGesture {
                         withAnimation {
                            if self.selectedCell == dataSet.id {
                                self.onTap(nil)
                                self.selectedCell = UUID()
                            } else {
                                self.selectedCell = dataSet.id
                                self.onTap(dataSet)
                            }
                        }
                    }.scaleEffect((self.selectedCell == dataSet.id) ? 1.05 : 1.0)
                }
            }
    }

    
   
}
struct ThisPieChart: View {
    @State private var selectedCell: UUID = UUID()
    @EnvironmentObject var network: Network
    
    let dataModel: ThisChartDataModel
    
    let onTap: (ChartCellModel?) -> ()
  
    
    var body: some View {

            ZStack {
                ForEach(dataModel.chartCellModel) { dataSet in
                    PieChartCell(startAngle: self.dataModel.angle(for: CGFloat(dataSet.value)), endAngle: self.dataModel.startingAngle)
                        .foregroundColor(dataSet.color)
                       .onTapGesture {
                         withAnimation {
                            if self.selectedCell == dataSet.id {
                                self.onTap(nil)
                                self.selectedCell = UUID()
                            } else {
                                self.selectedCell = dataSet.id
                                self.onTap(dataSet)
                            }
                        }
                    }.scaleEffect((self.selectedCell == dataSet.id) ? 1.05 : 1.0)
                }
            }
    }

    
   
}


struct ChartView: View {
    @State var selectedPie: String = ""
    @State var thisSelectedPie: String = ""
    @EnvironmentObject var network: Network 
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                Text("저번달")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(.top, 20)
                    .padding(.leading, 30)
                if network.lastMonth.count == 0 {
                    VStack(alignment: .center) {
                        Text("📊저번달 지출내역이 없습니다📊")
                            .frame(alignment: .center)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(20)
                        
                    }
                }
                HStack(spacing: 20){
                    
                    PieChart(dataModel: LastChartDataModel.init(dataModel: network.lastMonth), onTap: {
                        dataModel in
                        if let dataModel = dataModel {
                            self.selectedPie = "종류: \(dataModel.name)\n비율: \(dataModel.value)%"
                        } else {
                            self.selectedPie = ""
                        }
                        
                        
                    })
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding(30)
                    Text(selectedPie)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                Spacer()
                
                HStack(alignment: .center) {
                    
                    ForEach(network.lastMonth) { dataSet in
                        HStack {
                            Rectangle().foregroundColor(dataSet.color).frame(width: 10, height: 10)
                            Text(dataSet.name).font(.footnote)
                        }
                    }
                    
                    
                }.padding(.leading, 30)
            }.padding(.bottom, 20)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text("이번달")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(.top, 30)
                    .padding(.leading, 30)
                
                if network.thisMonth.count == 0 {
                    VStack(alignment: .center) {
                        Text("📊이번달 지출내역이 없습니다📊")
                            .frame(alignment: .center)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(20)

                    }
                }
                    
                    HStack(spacing: 20){
                        ThisPieChart(dataModel: ThisChartDataModel.init(dataModel: network.thisMonth), onTap: {
                            dataModel in
                            if let dataModel = dataModel {
                                self.thisSelectedPie = "종류: \(dataModel.name)\n비율: \(dataModel.value)%"
                            } else {
                                self.thisSelectedPie = ""
                            }
                            
                        })
                        .frame(width: 150, height: 150, alignment: .center)
                        .padding(30)
                        Text(thisSelectedPie)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    Spacer()
                    HStack(alignment: .center) {
                        ForEach(network.thisMonth) { dataSet in
                            HStack {
                                Rectangle().foregroundColor(dataSet.color).frame(width: 10, height: 10)
                                Text(dataSet.name).font(.footnote)
                            }
                        }
                    }.padding(.leading, 30)
                }
            }.onAppear {
                DispatchQueue.main.async {
                    network.loadLastChartData()
                    network.loadThisChartData()
                }
            }
        }
    


}
struct ChartCellModel: Identifiable {
    let id = UUID()
    let color: Color
    let value: Int
    let name: String
}

var lastChartViewData : [resultArray] = []
var thisChartViewData : [resultArray] = []

class Network: ObservableObject {
    @Published var lastMonth: [ChartCellModel] = []
    @Published var thisMonth: [ChartCellModel] = []
    @Published var sum : Int = 0
    @Published var new_val: Float = 0
    @Published var this_sum: Int = 0
    @Published var this_new_val: Float = 0
    
    func loadLastChartData() {

        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/chart/last/\(useridx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    
                    URLSession.shared.dataTask(with: request){ [self] (data, response, error) in
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return}
                        
                    print("last month: ", String(data: data, encoding: .utf8)!)
                        
                        
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return}

                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(responseData.self, from: data) {
                            lastChartViewData =  json.result
                        }
                        print("last month's Chart Data.result :",lastChartViewData)
                        lastMonth = []
                        for (idx, res) in lastChartViewData.enumerated(){
                            self.sum += res.total_amount
                            print("idx, res", idx, Color_Cat[idx],res.category_name, res.total_amount)
                            print("AllTotal", self.sum)
                           
                        }
                        for (idx, res) in lastChartViewData.enumerated(){
                            new_val = Float(Double(res.total_amount) / Double(self.sum) * 100)
                            self.lastMonth.append(ChartCellModel(color: Color(Color_Cat[idx]), value: Int(new_val), name: res.category_name))

                        }
                    }.resume() //URLSession - end
                }
            }
        }
    }
    
    func loadThisChartData() {

        let useridx = UserDefaults.standard.integer(forKey: "userIdx")
        if let url = URL(string: "https://www.pigmoney.xyz/chart/\(useridx)"){
            
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue( UserDefaults.standard.string(forKey: "accessToken") ?? "0", forHTTPHeaderField: "X-ACCESS-TOKEN")
            
            DispatchQueue.global().async {
                do {
                    
                    URLSession.shared.dataTask(with: request){ [] (data, response, error) in
                        
                        guard let data = data else {
                            print("Error: Did not receive data")
                            return}
                        
                    print("this month: ",String(data: data, encoding: .utf8)!)
                        
                        
                    guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return}

                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(responseData.self, from: data) {
                            thisChartViewData =  json.result
                        }
                        print("this month's Chart Data.result :",thisChartViewData)
                        //chartViewData <= sampleArray
                        self.thisMonth = []
                        for (idx, res) in thisChartViewData.enumerated(){
                            self.this_sum += res.total_amount
                            print("idx, res", idx, Color_Cat[idx],res.category_name, res.total_amount)
                            print("AllTotal", self.this_sum)
                           
                        }
                        
                        for (idx, res) in thisChartViewData.enumerated(){
                            print(self.this_sum, res.total_amount, res.total_amount/self.this_sum)
                            self.this_new_val = Float(Double(res.total_amount) / Double(self.this_sum) * 100)
                            self.thisMonth.append(ChartCellModel(color: Color(Color_Cat[idx]), value: Int(self.this_new_val), name: res.category_name))

                        }
                        print("thisMonth:",self.thisMonth)
                       
                        
                    }.resume() //URLSession - end
                    
                }
            }
        }
    }
}
final class LastChartDataModel: ObservableObject {
    
    @EnvironmentObject var network: Network
    var chartCellModel: [ChartCellModel]
    var startingAngle = Angle(degrees: 0)
    private var lastBarEndAngle = Angle(degrees: 0)
     
  
    
    init(dataModel: [ChartCellModel]) {
        chartCellModel = dataModel
     
    }
     
    var totalValue: CGFloat {
        return CGFloat((chartCellModel.reduce(0) { (result, data) -> Int in
            Int(result) + data.value
          
        }))
    }
     
    func angle(for value: CGFloat) -> Angle {
        if startingAngle != lastBarEndAngle {
            startingAngle = lastBarEndAngle
        }
        lastBarEndAngle += Angle(degrees: Double(value / totalValue) * 360 )
//        print("lastBarAngle", lastBarEndAngle)
        return lastBarEndAngle
    }
}
final class ThisChartDataModel: ObservableObject {
    
    @EnvironmentObject var network: Network
    var chartCellModel: [ChartCellModel]
    var startingAngle = Angle(degrees: 0)
    private var lastBarEndAngle = Angle(degrees: 0)
     
  
    
    init(dataModel: [ChartCellModel]) {
        chartCellModel = dataModel
     
    }
     
    var totalValue: CGFloat {
        return CGFloat((chartCellModel.reduce(0) { (result, data) -> Int in
            Int(result) + data.value
          
        }))
    }
     
    func angle(for value: CGFloat) -> Angle {
        if startingAngle != lastBarEndAngle {
            startingAngle = lastBarEndAngle
        }
        lastBarEndAngle += Angle(degrees: Double(value / totalValue) * 360 )
//        print("lastBarAngle", lastBarEndAngle)
        return lastBarEndAngle
    }
}

let Color_Cat = ["NPeach", "NOrange", "NYellow", "NGreen", "NBlue"]

//var sample = [ ChartCellModel(color: Color(Color_Cat[0]), value: 2000, name: "고정지출"),
//               ChartCellModel(color: Color(Color_Cat[1]), value: 1000, name: "배달음식"),
//               ChartCellModel(color: Color(Color_Cat[2]), value: 2000, name: "의류"),
//               ChartCellModel(color: Color(Color_Cat[3]), value: 1000, name: "식재료"),
//               ChartCellModel(color: Color(Color_Cat[4]), value: 20, name: "교통")]
//
//
//let lastArray = [
//    resultArray(category_name: "category1", total_amount: 2000),
//    resultArray(category_name: "category2", total_amount: 1000),
//    resultArray(category_name: "category3", total_amount: 2500),
//    resultArray(category_name: "car", total_amount: 1500)
//]
//let thisArray = [
//    resultArray(category_name: "category11", total_amount: 20),
//    resultArray(category_name: "category22", total_amount: 10),
//    resultArray(category_name: "category33", total_amount: 25),
//    resultArray(category_name: "carrrr", total_amount: 15)
//]


//let sample = [ ChartCellModel(color: Color("NPeach"), value: chartViewData[0].total_amount, name: chartViewData[0].category_name),
//               ChartCellModel(color: Color("NOrange"), value: chartViewData[1].total_amount, name: chartViewData[1].category_name),
//               ChartCellModel(color: Color("NYellow"), value: chartViewData[2].total_amount, name: chartViewData[2].category_name),
//               ChartCellModel(color: Color("NGreen"), value: chartViewData[3].total_amount, name: chartViewData[3].category_name),
//               ChartCellModel(color: Color("NBlue"), value: chartViewData[4].total_amount, name: chartViewData[4].category_name)]
//

struct ChartView_Previews: PreviewProvider{
    static var previews: some View {
        ChartView().environmentObject(Network())
    }
}
