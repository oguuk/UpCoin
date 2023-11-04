//
//  UpCoinWidget.swift
//  UpCoinWidget
//
//  Created by oguuk on 2023/09/07.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), bitcoinPrice: 48000000, color: .green)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        getPrice { ticker in
            let color: Color = ticker.signedChangePrice > 0.0 ? .green : (ticker.signedChangePrice == 0.0 ? .gray : .pink)
            let entry = SimpleEntry(date: Date(), bitcoinPrice: ticker.tradePrice, color: color)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            getPrice { ticker in
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let color: Color = ticker.signedChangePrice > 0.0 ? .green : (ticker.signedChangePrice == 0.0 ? .gray : .pink)
                let entry = SimpleEntry(date: entryDate, bitcoinPrice: ticker.tradePrice, color: color)
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    private func getPrice(_ completion: @escaping (TickerResponse) -> ()) {
        guard let url = URL(string: "https://api.upbit.com/v1/ticker?markets=KRW-BTC") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let ticker = try? JSONDecoder().decode([TickerResponse].self, from: data) else { return }
            completion(ticker.first!)
        }
        .resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct UpCoinWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct UpCoinWidget: Widget {
    let kind: String = "UpCoinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            UpCoinWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct UpCoinWidget_Previews: PreviewProvider {
    static var previews: some View {
        UpCoinWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
