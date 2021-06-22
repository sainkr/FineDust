//
//  FineDustEntryView.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/20.
//

import WidgetKit
import SwiftUI
import Intents

// Widget 꾸미기
struct FineDustWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        FineDustView(finedust: entry.finedust)
    }
}

struct FineDustView: View {
    let finedust: FineDustRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text("\(finedust.location)")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .padding(.leading, 5)
            
            HStack(spacing: 0){
                Text("\(finedust.finedustValue)")
                    .fontWeight(.bold)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 43, height: 43, alignment: .center)
                    .background(Color(finedust.finedustColor))
                    .cornerRadius(5)
                    .padding(.trailing,10)
                
                VStack(alignment: .leading, spacing: 2){
                    Text("미세먼지")
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.bottom, 3)
                    Text("\(finedust.finedustState)")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .foregroundColor(Color(finedust.finedustColor))
                }
            }
            
            HStack(spacing: 0){
                Text("\(finedust.ultrafinedustValue)")
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 43, height: 43, alignment: .center)
                    .background(Color(finedust.ultrafinedustColor))
                    .cornerRadius(5)
                    .padding(.trailing,10)

                
                VStack(alignment: .leading, spacing: 2){
                    Text("초미세먼지")
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.bottom, 3)
                    Text("\(finedust.ultrafinedustState)")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .foregroundColor(Color(finedust.ultrafinedustColor))
                }
            }
        }.padding(.top, 15)
        .padding(.bottom, 15)
    }
}

struct FineDustView_Previews: PreviewProvider {
    static var previews: some View {
        FineDustView(finedust: FineDustRequest(location: "원주시 태장동", finedustValue: "150", finedustState: "좋음", finedustColor: #colorLiteral(red: 0.1309628189, green: 0.6049023867, blue: 1, alpha: 1), ultrafinedustValue: "10", ultrafinedustState: "보통", ultrafinedustColor: #colorLiteral(red: 0.08792158216, green: 0.7761771083, blue: 0.2295451164, alpha: 1)))
    }
}
