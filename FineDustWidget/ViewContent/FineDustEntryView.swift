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
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.all, 10)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.trailing,10)
                
                VStack(alignment: .leading, spacing: 2){
                    Text("미세먼지")
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.bottom, 3)
                    Text("\(finedust.finedustState)")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
            }
            
            HStack(spacing: 0){
                Text("\(finedust.ultrafinedustValue)")
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.all, 10)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.trailing,10)
                
                VStack(alignment: .leading, spacing: 2){
                    Text("초미세먼지")
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.bottom, 3)
                    Text("\(finedust.ultrafinedustState)")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
            }
        }.padding(.top, 15)
        .padding(.bottom, 15)
    }
}

struct FineDustView_Previews: PreviewProvider {
    static var previews: some View {
        FineDustView(finedust: FineDustRequest(location: "원주시 태장동", finedustValue: "20", finedustState: "보통", ultrafinedustValue: "10", ultrafinedustState: "좋음"))
    }
}
