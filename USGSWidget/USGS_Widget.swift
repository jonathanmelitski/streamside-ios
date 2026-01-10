//
//  USGS_Widget.swift
//  USGS Widget
//
//  Created by Jonathan Melitski on 5/26/25.
//

import WidgetKit
import SwiftUI
import USGSShared

//struct Provider: AppIntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), data: nil)
//    }
//
//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//        SimpleEntry(date: Date(), data: configuration.location)
//    }
//
//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//        await SharedViewModel.shared.refreshData()
//        let fetchedData = SharedViewModel.shared.locationData[configuration.location?.id ?? ""]
//        let currentDate = Date()
//        let entry = SimpleEntry(date: currentDate, data: fetchedData)
//        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
//
//        return Timeline(entries: [entry], policy: .after(nextRefresh))
//    }
//}

struct Provider: AppIntentTimelineProvider {
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return SimpleEntry(date: Date(), data: Location.sampleData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        await withCheckedContinuation { cont in
            SharedViewModel.shared.resetState {
                cont.resume()
            }
        }
        
        let fetchedData = SharedViewModel.shared.locationData[configuration.location?.id ?? ""]
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, data: fetchedData)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!

        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: nil)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: Location?
}

struct USGS_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    var body: some View {
        if let data = entry.data {
            switch family {
            case .systemMedium:
                MediumWidgetView(data: data)
                    .widgetURL(URL(string: "usgswidget://open-conditions?id=\(data.id)")!)
            case .systemSmall:
                SmallWidgetView(data: data)
                    .widgetURL(URL(string: "usgswidget://open-conditions?id=\(data.id)")!)
            default:
                Text("Invalid Widget Format")
            }
                
        } else {
            VStack(alignment: .center) {
                Text("No Gage")
                    .bold()
                    .font(.title2)
                Divider()
                Text("Select the widget location in this widget's settings.")
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
        }
    }
}

struct USGS_Widget: Widget {
    let kind: String = "USGS_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            USGS_WidgetEntryView(entry: entry)
                .containerBackground(.linearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom), for: .widget)
                
        }
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}
