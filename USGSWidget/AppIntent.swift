//
//  AppIntent.swift
//  USGS Widget
//
//  Created by Jonathan Melitski on 5/26/25.
//

import WidgetKit
import AppIntents
import USGSShared

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Select the river to display data for." }
    
    @Parameter(title: "Selected River")
    var location: Location?
}

extension Location: AppEntity {
    public static var defaultQuery = LocationQuery()
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(stringLiteral: "River Location")
    }
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: self.name)
    }
    
    public struct LocationQuery: EntityQuery {
        public init() {}
        
        public func entities(for identifiers: [Location.ID]) async throws -> [Location] {
            SharedViewModel.shared.favoriteLocations.filter { el in
                identifiers.contains(where: { $0 == el })
            }.compactMap {
                SharedViewModel.shared.locationData[$0]
            }
        }
        
        public func suggestedEntities() async throws -> [Location] {
            SharedViewModel.shared.favoriteLocations.compactMap {
                SharedViewModel.shared.locationData[$0]
            }
        }
                
        public func defaultResult() async -> Location? {
            nil
        }
    }
    
    
}
