//
//  USGS_Widget.swift
//  USGS Widget
//
//  Created by Jonathan Melitski on 5/26/25.
//

import WidgetKit
import SwiftUI
import USGSShared

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), data: Location.sampleData))
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        Task {
            await SharedViewModel.shared.refreshData()
            let fetchedData = SharedViewModel.shared.locationData[SharedViewModel.shared.widgetPreferredLocation ?? ""]
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, data: fetchedData)
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!

            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
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
                Text("No Selected Location")
                    .bold()
                    .font(.title2)
                Divider()
                Text("Select the primary widget location by pressing the crown icon on a location card.")
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            USGS_WidgetEntryView(entry: entry)
                .containerBackground(.linearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom), for: .widget)
                
        }
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}
