//
//  DashboardGraphView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared
import Charts

struct DashboardGraphView: View {
    let configuration: DashboardGraphConfiguration
    let location: Location
    let metric: LocationDataMetricDescriptor
    
    var relevantData: [LocationDataMetricValue] {
        let metricData = location.metrics.first(where: { $0.descriptor == metric })?.descriptorSpecificValues ?? []
        
        return metricData
    }
    
    var relevantMinimum: Double {
        relevantData.compactMap({ Double($0.value) }).min() ?? 0.0
    }
    
    var relevantMaximum: Double {
        relevantData.compactMap({ Double($0.value) }).max() ?? 0.0
    }
    
    var body: some View {
        Chart {
            ForEach(relevantData) { value in
                if let val = Double(value.value) {
                    AreaMark(
                        x: .value("Date", value.date),
                        y: .value("Value", val),
                        series: .value("Metric", metric.name ?? "")
                    )
                    .foregroundStyle(
                        Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.1)])
                    )
                    .alignsMarkStylesWithPlotArea()
                    
                    
                    LineMark(
                        x: .value("Date", value.date),
                        y: .value("Value", val),
                        series: .value("Metric", metric.name ?? ""))
                    .foregroundStyle(.blue)
                }
            }
        }
        .chartYScale(domain: relevantMinimum ... relevantMaximum)
        .chartYAxis(.hidden)
        .chartXAxis(.visible)
        .chartXAxis {
            AxisMarks(values: .stride(by: Calendar.Component.day, count: 1)) {
                AxisValueLabel()
                    .foregroundStyle(Color("GraphAxisForeground"))
                    .font(.system(size: 10))
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                    .foregroundStyle(Color("GraphAxisForeground"))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.2, dash: [3]))
                    .foregroundStyle(Color("GraphAxisForeground"))
            }
        }
        .chartPlotStyle { plot in
            plot
                .clipped()
        }
        .frame(height: 140)
    }
}

