//
//  DashboardSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

public struct DashboardSettings: Codable {
    public var titleOverride: String? = nil
    public var subtitleOverride: String? = nil
    // background types: map, pattern, photo
    
    public var displaySections: [DashboardDisplaySection]
}

public struct DashboardDisplaySection: Codable {
    // Descriptor used to prevent serialization/saving of the entire dataset to Firebase
    public let metric: LocationDataMetricDescriptor
    public var title: String
    public var icon: String
    public var blocks: [DashboardDisplayBlock]
    
    init(metric: LocationDataMetricDescriptor) {
        self.metric = metric
        self.title = metric.name ?? "New Section"
        self.icon = "number"
        self.blocks = [] //TODO: add sensible default for blocks (PDOC)
    }
}

public struct DashboardDisplayBlock: Codable {
    public var subblocks: [any DashboardComponentBlock]
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.subblocks = try container.decode([GenericComponentBlock].self, forKey: .subblocks)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let genericBlocks = subblocks.map({ GenericComponentBlock(from: $0) })
        try container.encode(genericBlocks, forKey: .subblocks)
    }
    
    public enum CodingKeys: String, CodingKey {
        case subblocks
    }
}

private struct GenericComponentBlock: DashboardComponentBlock {
    let type: DashboardComponentBlockType
    
    let horizontallyStackable: Bool
    
    var configuration: any DashboardComponentBlockConfiguration
    
    init(from block: any DashboardComponentBlock) {
        self.type = block.type
        self.horizontallyStackable = block.horizontallyStackable
        self.configuration = block.configuration
    }
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(DashboardComponentBlockType.self, forKey: .type)
        self.horizontallyStackable = try container.decode(Bool.self, forKey: .horizontallyStackable)
        let configurationType = type.configurationType
        self.configuration = try container.decode(configurationType, forKey: .configuration)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(horizontallyStackable, forKey: .horizontallyStackable)

        switch type {
        case .graph:
            try container.encode(configuration as! GraphConfig, forKey: .configuration)
        case .value:
            try container.encode(configuration as! ValueConfig, forKey: .configuration)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case type, horizontallyStackable, configuration
    }
    
}

public protocol DashboardComponentBlock: Codable {
    var type: DashboardComponentBlockType { get }
    var horizontallyStackable: Bool { get }
    var configuration: any DashboardComponentBlockConfiguration { get set }
    
}

public protocol DashboardComponentBlockConfiguration: Codable {
    var type: DashboardComponentBlockType { get }
}

public enum DashboardComponentBlockType: Int, Codable {
    case graph, value
    
    var configurationType: DashboardComponentBlockConfiguration.Type {
        switch self {
        case .graph:
            return GraphConfig.self
        case .value:
            return ValueConfig.self
        }
    }
}

struct GraphConfig: DashboardComponentBlockConfiguration {
    var type: DashboardComponentBlockType = .graph
    let seriesName: String
    
    init() {
        self.seriesName = "Test"
    }
}

struct ValueConfig: DashboardComponentBlockConfiguration {
    var type: DashboardComponentBlockType = .value
    let value: Int
    
    init() {
        self.value = 4
    }
}
