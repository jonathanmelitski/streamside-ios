//
//  StreamConditionsFullscreenView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/29/25.
//

import SwiftUI
import USGSShared

struct StreamConditionsFullscreenView: View {
    @EnvironmentObject var vm: SharedViewModel
    
    static let mainDimension: CGFloat = 140
    
    var body: some View {
        // Two-way body with divider. ultra thick
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    if let loc = vm.usgsData.first(where: { $0.key == vm.selectedLocation }),
                       let value = loc.value {
                        if let temp = USGSDataSeries.temp.getCurrentValueString(from: value, modifier: USGSDataSeries.CtoFconversion) {
                            HighlightedDataPointView(primary: temp, subtitle: "Water Temp (°F)")
                                .frame(width: Self.mainDimension, height: Self.mainDimension)
                            Spacer()
                        }
                        Divider()
                        if let cfs = USGSDataSeries.cfs.getCurrentValueString(from: value) {
                            Spacer()
                            HighlightedDataPointView(primary: cfs, subtitle: "Flow Rate (cfs)")
                                .frame(width: Self.mainDimension, height: Self.mainDimension)
                        }
                    }
                        
                    Spacer()
                }
                .frame(height: Self.mainDimension)
                .padding(.vertical)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.thinMaterial)
                }
                .padding()
            }
            
        }
        .ignoresSafeArea()
    }
}

struct HighlightedDataPointView: View {
    let primary: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            Text(primary)
                .font(.system(size: 56))
                .bold()
            VStack {
                Spacer()
                Text(subtitle.uppercased())
                    .multilineTextAlignment(.center)
                    .font(.headline)
            }
        }
        
        .foregroundStyle(.white)
    }
}


