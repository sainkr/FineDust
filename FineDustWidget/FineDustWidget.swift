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
// TimelineProvider : Widget의 디스플레이를 업데이트 할 시기를 WidgetKit에 알려주는 타입
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
        
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry: SimpleEntry =  SimpleEntry(date: Date(), configuration: configuration)
        
        if context.isPreview{ // 추가 할 때 미리보기
            
        }
        
        // context.family : widget 크기
        
        // context.environmentVariants.colorScheme
        
        completion(entry)
    }

    // 위젯 미리 업데이트 시키기
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        // atEnd : 타임라인의 마지막 날짜가 지난 후 WidgetKit이 새 타임라인을 요청하도록 지정하는 policy
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date // 필수적으로 요구 ..

    let configuration: ConfigurationIntent
}

// Widget 꾸미기
struct FineDustWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily

    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            Text("systemSmall")
        case .systemMedium:
            Text("systemMedium")
        case .systemLarge:
            Text("systemLarge")
        @unknown default:
            Text(entry.date, style: .time)
        }
       
    }
}

@main
struct FineDustWidget: Widget {
    let kind: String = "FineDustWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FineDustWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("미세먼지") // 사용자가 위젯을 추가/편집 할 때 위젯에 표시되는 이름을 설정하는 메소드입니다.
        .description("") // 사용자가 위젯을 추가/편집할 때 위젯에 표시되는 설명을 설정하는 메소드입니다.
        .supportedFamilies([.systemSmall, .systemLarge, .systemMedium])
        
    }
}

struct FineDustWidget_Previews: PreviewProvider {
    static var previews: some View {
        FineDustWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
