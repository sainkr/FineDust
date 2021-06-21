//
//  FineDustWidget.swift
//  FineDustWidget
//
//  Created by 홍승아 on 2021/06/19.
//

import WidgetKit
import SwiftUI
import Intents

// 1. Configuration. 위젯을 식별하며, 위젯의 Content를 표시하면 SwiftUI View를 정의.
// 2. Timeline provider. 시간이 지남에 따라 위젯 View를 업데이트하는 프로세스를 주도.
// 3. SwiftUI View. WidgetKit에서 위젯을 표시하는데 사용하는 View.

// provider : 위젯을 새로고침할 타임라인을 결정하는 객체입니다.

@main
struct FineDustWidget: Widget {
    let kind: String = "FineDustWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FineDustWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("미세먼지") // 사용자가 위젯을 추가/편집 할 때 위젯에 표시되는 이름을 설정하는 메소드입니다.
        .description("") // 사용자가 위젯을 추가/편집할 때 위젯에 표시되는 설명을 설정하는 메소드입니다.
        .supportedFamilies([.systemSmall])
        
    }
}

struct FineDustWidget_Previews: PreviewProvider {
    static var previews: some View {
        FineDustWidgetEntryView(entry: SimpleEntry(date: Date(), finedust: FineDustRequest(location: "원주시 태장동", finedustValue: "30", finedustState: "보통", finedustColor: .black, ultrafinedustValue: "13", ultrafinedustState: "보통", ultrafinedustColor: .black), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
