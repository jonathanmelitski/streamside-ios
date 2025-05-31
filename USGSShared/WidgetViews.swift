//
//  WidgetViews.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import SwiftUI
import Charts

public struct SmallWidgetView: View {
    public let data: USGSData
    
    public init(data: USGSData) {
        self.data = data
    }
    
    public var body: some View {
        if let cfs = USGSDataSeries.cfs.getCurrentValueString(from: data),
           let temp = USGSDataSeries.temp.getCurrentValueString(from: data, modifier: USGSDataSeries.CtoFconversion),
           let loc = data.locationName,
           let locShort = loc.split(separator: " ").first {
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
                    Chart(USGSDataSeries.cfs.getAllValues(from: data) ?? []) { point in
                        if let val = Double(point.value) {
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Value", val)
                            )
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .frame(height: 40)
                }
                
                VStack {
                    HStack(spacing: 24) {
                        VStack(spacing: 2) {
                            Text(temp)
                                .font(.title2)
                                .bold()
                                .shadow(radius: 8)
                            Text("TEMP")
                                .font(.caption)
                                .bold()
                                .shadow(radius: 4)
                        }
                        
                        VStack(spacing: 2) {
                            Text(cfs)
                                .font(.title2)
                                .bold()
                                .shadow(radius: 8)
                            Text("CFS")
                                .font(.caption)
                                .bold()
                                .shadow(radius: 4)
                        }
                    }
                }
            }
        }
    }
}

public struct MediumWidgetView: View {
    public let data: USGSData
    
    public init(data: USGSData) {
        self.data = data
    }
    
    public var body: some View {
        if let cfs = USGSDataSeries.cfs.getCurrentValueString(from: data),
           let temp = USGSDataSeries.temp.getCurrentValueString(from: data, modifier: USGSDataSeries.CtoFconversion),
           let loc = data.locationName {
            ZStack {
                VStack {
                    Text(loc
                        .uppercased())
                        .font(.caption)
                        .bold()
                        .shadow(radius: 4)
                        .foregroundStyle(.white)
                        .padding()
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    Chart {
                        ForEach(data.settings.graphSettings.series) { series in
                            ForEach(series.usgsGraphedElement.getAllValues(from: data) ?? []) { point in
                                if let val = Double(point.value) {
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Value", val),
                                        series: .value("Value", series.usgsGraphedElement.rawValue)
                                    )
                                    .foregroundStyle(series.graphForegroundColor.toSwiftUIColor)
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
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                                .foregroundStyle(Color("GraphAxisForeground"))
                            AxisTick(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                                .foregroundStyle(Color("GraphAxisForeground"))
                        }
                    }
                    .frame(height: 75)
                }
                
                HStack(spacing: 32) {
                    VStack(spacing: 2) {
                        Text(temp)
                            .font(.largeTitle)
                            .bold()
                            .shadow(radius: 8)
                        Text("TEMP")
                            .font(.caption)
                            .bold()
                            .shadow(radius: 4)
                    }
                    
                    VStack(spacing: 2) {
                        Text(cfs)
                            .font(.largeTitle)
                            .bold()
                            .shadow(radius: 8)
                        Text("CFS")
                            .font(.caption)
                            .bold()
                            .shadow(radius: 4)
                    }
                }
                .foregroundStyle(.white)
                
            }
        } else {
            Text("Unable to fetch data")
        }
        
    }
}

#Preview("Medium") {
    MediumWidgetView(data: USGSData.sampleData)
        .padding()
        .frame(height: 150)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
        }
        .padding()
        .shadow(radius: 8)
}
