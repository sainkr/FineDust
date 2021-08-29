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
    FineDustView(request: entry.finedust)
  }
}

struct FineDustView: View {
  let request: FineDustRequest
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8){
      Text("\(request.locationName)")
        .font(.system(size: 20))
        .fontWeight(.bold)
        .padding(.leading, 5)
      
      HStack(spacing: 0){
        Text("\(request.fineDust.fineDustValue)")
          .fontWeight(.bold)
          .font(.system(size: 17))
          .foregroundColor(.white)
          .frame(width: 43, height: 43, alignment: .center)
          .background(Color(request.fineDust.fineDustColor))
          .cornerRadius(5)
          .padding(.trailing,10)
        
        VStack(alignment: .leading, spacing: 2){
          Text("미세먼지")
            .fontWeight(.bold)
            .font(.system(size: 17))
            .padding(.bottom, 3)
          Text("\(request.fineDust.fineDustState)")
            .fontWeight(.bold)
            .font(.system(size: 16))
            .foregroundColor(Color(request.fineDust.fineDustColor))
        }
      }
      
      HStack(spacing: 0){
        Text("\(request.ultraFineDust.ultraFineDustValue)")
          .fontWeight(.bold)
          .font(.system(size: 18))
          .foregroundColor(.white)
          .frame(width: 43, height: 43, alignment: .center)
          .background(Color(request.ultraFineDust.ultraFineDustColor))
          .cornerRadius(5)
          .padding(.trailing,10)
        
        
        VStack(alignment: .leading, spacing: 2){
          Text("초미세먼지")
            .fontWeight(.bold)
            .font(.system(size: 17))
            .padding(.bottom, 3)
          Text("\(request.ultraFineDust.ultraFineDustState)")
            .fontWeight(.bold)
            .font(.system(size: 16))
            .foregroundColor(Color(request.ultraFineDust.ultraFineDustColor))
        }
      }
    }.padding(.top, 15)
    .padding(.bottom, 15)
  }
}

struct FineDustView_Previews: PreviewProvider {
  static var previews: some View {
    let fineDustViewModel = FineDustViewModel()
    FineDustView(request: FineDustRequest(
                  locationName: "원주시 태장동",
                  fineDust: fineDustViewModel.fineDust("150"),
                  ultraFineDust: fineDustViewModel.ultraFineDust("15")))
  }
}
