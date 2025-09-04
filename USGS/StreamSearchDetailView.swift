//
//  StreamSearchDetailView().swift
//  USGS
//
//  Created by Jonathan Melitski on 7/12/25.
//

import SwiftUI
import USGSShared

struct StreamSearchDetailView: View {
    let locations: [Location]?
    
    var body: some View {
        if let locations {
            Text("Hello")
        } else {
            VStack {
                Text("No locations")
                    .font(.title)
                    .bold()
                Text("Begin by searching a region of the map.")
            }
        }
    }
}
