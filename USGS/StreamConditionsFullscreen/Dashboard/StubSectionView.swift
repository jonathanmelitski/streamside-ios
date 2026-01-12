//
//  StubSectionView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared

struct StubSectionView: View {
    let location: Location
    let completion: (DashboardDisplaySection) -> ()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThickMaterial)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "number")
                    Text("New Section".uppercased())
                    Spacer()
                }
                .foregroundStyle(Color(UIColor.systemGray))
                .font(.caption)
                Divider()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Metric:")
                        .font(.title2)
                        .bold()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(location.metrics.compactMap({ $0.descriptor }), id: \.code) { desc in
                                if let name = desc.name {
                                    Button {
                                        let newSection = DashboardDisplaySection(metric: desc)
                                        completion(newSection)
                                    } label: {
                                        HStack {
                                            Text(name)
                                            Spacer()
                                        }
                                    }
                                    Divider()
                                }
                                
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
                
                
            }
            .padding()
            
        }
        .transition(.push(from: .bottom))
    }
}
