//
//  WidgetViews.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import SwiftUI
import Charts

public struct SmallWidgetView: View {
    public let data: Location
    
    public init(data: Location) {
        self.data = data
    }
    
    public var body: some View {
        if let locShort = data.name.split(separator: " ").first {
            ZStack {
                VStack {
                    Text(locShort.uppercased())
                        .font(.caption)
                        .bold()
                        .shadow(radius: 4)
                    Spacer()
                }
                
                VStack {
                    Spacer()
//                    Chart(USGSDataSeries.cfs.getAllValues(from: data) ?? []) { point in
//                        if let val = Double(point.value) {
//                            LineMark(
//                                x: .value("Date", point.date),
//                                y: .value("Value", val)
//                            )
//                        }
//                    }
//                    .chartYScale(domain: .automatic(includesZero: false))
//                    .chartYAxis(.hidden)
//                    .chartXAxis(.hidden)
//                    .frame(height: 40)
                }
                
                HStack {
                    ForEach(data.metrics, id: \.descriptor.code) { metric in
                        Spacer()
                        if let val = metric.descriptorSpecificCurrentValueString {
                            VStack(spacing: 2) {
                                Text(val)
                                    .font(.title2)
                                    .bold()
                                    .shadow(radius: 8)
                                Text("TEMP")
                                    .font(.caption)
                                    .bold()
                                    .shadow(radius: 4)
                            }
                            Spacer()
                        }
                        
                    }
                }
            }
        }
    }
}

public struct MediumWidgetView: View {
    public let data: Location
    
    public init(data: Location) {
        self.data = data
    }
    
    public var body: some View {
        ZStack {
            VStack {
                Spacer()
                Chart {
                    ForEach(data.settings.graphSettings.series) { series in
                        if let metric = data.metrics.first(where: { $0.descriptor == series.usgsGraphedElement }) {
                            ForEach(metric.descriptorSpecificValues) { value in
                                if let val = Double(value.value) {
                                    LineMark(
                                        x: .value("Date", value.date),
                                        y: .value("Value", val),
                                        series: .value("Metric", metric.descriptor.name ?? ""))
                                        .foregroundStyle(series.graphForegroundColor.toSwiftUIColor)
                                }
                            }
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartYAxis(.hidden)
                .chartXAxis(.visible)
                .chartXAxis {
                    AxisMarks(values: .stride(by: Calendar.Component.day, count: 2)) {
                        AxisValueLabel()
                            .foregroundStyle(Color("GraphAxisForeground"))
                            .font(.system(size: 10))
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                            .foregroundStyle(Color("GraphAxisForeground"))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                            .foregroundStyle(Color("GraphAxisForeground"))
                    }
                }
                .frame(height: 75)
            }
            VStack(alignment: .center) {
                Text(data.name
                    .uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .multilineTextAlignment(.center)
                    .shadow(radius: 4)
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
            }
            HStack {
                ForEach(data.settings.displaySettings.valuesToShow, id: \.code) { descriptor in
                    Spacer()
                    if let metric = data.metrics.first(where: { $0.descriptor.code == descriptor.code }),
                       let val = metric.descriptorSpecificCurrentValueString {
                        VStack(spacing: 2) {
                            Text(val)
                                .font(.system(size: 36, weight: .bold))
                                .shadow(radius: 8)
                            Text(metric.descriptorSpecificLabelShort)
                                .font(.system(size: 12, weight: .bold))
                                .shadow(radius: 4)
                        }
                        Spacer()
                    }
                }
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview("Medium") {
    MediumWidgetView(data: Location.sampleData)
        .padding()
        .frame(height: 150)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
        }
        .padding()
        .shadow(radius: 8)
}
