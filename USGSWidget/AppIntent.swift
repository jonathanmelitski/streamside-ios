//
//  AppIntent.swift
//  USGS Widget
//
//  Created by Jonathan Melitski on 5/26/25.
//

import WidgetKit
import AppIntents
import USGSShared

// Not really used for now

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
            (SharedViewModel.shared.currentProfile?.gauges ?? []).filter { el in
                identifiers.contains(where: { $0 == el.id })
            }
        }
        
        public func suggestedEntities() async throws -> [Location] {
            (SharedViewModel.shared.currentProfile?.gauges ?? [])
        }
                
        public func defaultResult() async -> Location? {
            nil
        }
    }
    
    
}
