//
//  SymbolOptions.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

public extension UserSavedCoordinate {
    static let allSymbolOptions: [String] = [
        // Note: includes confirmed SF Symbols + proxy suggestions (check SF Symbols app for exact availability)
            // Direct fishing / aquatic
            "figure.fishing",
            "figure.fishing.circle",
            "figure.fishing.circle.fill",
            "fish",
            "fish.fill",
            "fish.circle",
            "fish.circle.fill",
            "oar.2.crossed",
            "oar.2.crossed.circle",
            "oar.2.crossed.circle.fill",
            "figure.pool.swim",
            "figure.pool.swim.circle",
            "figure.pool.swim.circle.fill",
            "figure.open.water.swim",
            "figure.open.water.swim.circle",
            "figure.open.water.swim.circle.fill",

            // Boating / rowing
            "figure.sailing",
            "figure.sailing.circle",
            "figure.sailing.circle.fill",
            "figure.indoor.rowing",
            "figure.indoor.rowing.circle",
            "figure.indoor.rowing.circle.fill",
            "figure.outdoor.rowing",
            "figure.outdoor.rowing.circle",

            // Water & waves
            "drop",
            "drop.fill",
            "waveform.path",
            "waveform.path.ecg",
            "wave.3.forward",      // proxy check in SF Symbols app
            "wave.3.backward",     // proxy check in SF Symbols app

            // Maps, pins & landmarks
            "mappin",
            "mappin.circle",
            "mappin.circle.fill",
            "map",
            "map.fill",
            "location",
            "location.fill",
            "flag",
            "flag.fill",
            "flag.circle",
            "flag.2.crossed",
            "flag.checkered",
            "bookmark",
            "bookmark.fill",

            // Directional / orientation
            "arrowtriangle.left",
            "arrowtriangle.left.fill",
            "arrowtriangle.right",
            "arrowtriangle.right.fill",
            "arrowtriangle.up",
            "arrowtriangle.up.fill",
            "arrowtriangle.down",
            "arrowtriangle.down.fill",
            "chevron.left",
            "chevron.right",
            "chevron.up",
            "chevron.down",

            // Terrain / shore / rock proxies
            "triangle",
            "triangle.fill",
            "hexagon",
            "hexagon.fill",
            "circle",
            "circle.fill",
            "square",
            "square.fill",
            "building.2",
            "building.columns",
            "leaf",
            "leaf.fill",

            // Safety / beacons / buoys (proxies)
            "light.max",          // lighthouse proxy
            "light.min",
            "lightbulb",
            "bell",
            "bell.fill",
            // use circle/dot compositions for buoys if no literal symbol exists

            // Fishing gear / hooks (suggest creating custom symbols)
            // (include proxies if you want placeholders)
            "scissors",           // proxy placeholder
            "tuningfork",         // proxy placeholder

            // Wildlife & bycatch
            "tortoise",
            "tortoise.fill",
            "bird",
            "bird.fill",
            "pawprint",

            // UI primitives & selector helpers
            "play",
            "stop",
            "pause",
            "plus",
            "minus",
            "xmark",
            "checkmark",
            "checkmark.circle",
            "pin",                // proxy — verify name in SF Symbols app
            "paperplane",
            "star",
            "gear",
            "slider.horizontal.3"
    ]

}
