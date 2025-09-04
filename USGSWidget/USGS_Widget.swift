//
//  USGS_Widget.swift
//  USGS Widget
//
//  Created by Jonathan Melitski on 5/26/25.
//

import WidgetKit
import SwiftUI
import USGSShared

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), data: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let fetchedData = try? await SharedViewModel.shared.fetchLocationData(configuration.location?.id ?? "")
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, data: fetchedData)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!

        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
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
            Text("Unable to fetch data")
        }
    }
}

struct USGS_Widget: Widget {
    let kind: String = "USGS_Widget"
    let id: String
    init() {
        self.id = ""
    }
    
    init(_ id: String) {
        self.id = id
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            USGS_WidgetEntryView(entry: entry)
                .containerBackground(.linearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom), for: .widget)
                
        }
        .configurationDisplayName(id)
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}
