//
//  DashboardSectionView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared

struct DashboardSectionView: View {
    let section: DashboardDisplaySection
    @Binding var location: Location
    
    init(_ section: DashboardDisplaySection, loc location: Binding<Location>) {
        self.section = section
        self._location = location
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThickMaterial)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: section.icon)
                    Text(section.title.uppercased())
                    Spacer()
                }
                .foregroundStyle(Color(UIColor.systemGray))
                .font(.caption)
                Divider()
                ForEach(section.blocks, id: \.self) { block in
                    let sortedSubblocks = block.subblocks.sorted(by: { $0.index < $1.index })
                    HStack {
                        if let first = sortedSubblocks.first {
                            DashboardComponentBlockView(block: first, loc: $location, metric: section.metric)
                        }
                        if block.subblocks.count > 1 {
                            ForEach(sortedSubblocks.dropFirst(), id: \.id) { subblock in
                                Divider()
                                DashboardComponentBlockView(block: subblock, loc: $location, metric: section.metric)
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
