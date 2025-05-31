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
        if let cfs = data.cfs, let temp = data.tempF, let cfsDateStr = data.cfsDateStr, let tempDateStr = data.tempDateStr, let loc = data.locationName, let locShort = loc.split(separator: " ").first {
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
                    Chart(data.cfsAllValues) { point in
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
        if let cfs = data.cfs, let temp = data.tempF, let loc = data.locationName {
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
                    Chart(data.cfsAllValues) { point in
                        if let val = Double(point.value) {
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Value", val)
                            )
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .chartYAxis(.hidden)
                    .chartXAxis(.visible)
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
