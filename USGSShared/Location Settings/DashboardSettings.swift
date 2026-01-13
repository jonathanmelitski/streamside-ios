//
//  DashboardSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

public struct DashboardSettings: Codable, Hashable {
    public var titleOverride: String? = nil
    public var subtitleOverride: String? = nil
    // background types: map, pattern, photo
    
    public var displaySections: [DashboardDisplaySection]
    
    public init() {
        self.displaySections = [] //TODO: add sensible default for blocks (PDOC)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleOverride = try container.decodeIfPresent(String.self, forKey: .titleOverride)
        self.subtitleOverride = try container.decodeIfPresent(String.self, forKey: .subtitleOverride)
        self.displaySections = (try container.decodeIfPresent([DashboardDisplaySection].self, forKey: .displaySections)) ?? []
    }
}

public struct DashboardDisplaySection: Codable, Hashable {
    // Descriptor used to prevent serialization/saving of the entire dataset to Firebase
    public let metric: LocationDataMetricDescriptor
    public var title: String
    public var icon: String
    public var blocks: [DashboardDisplayBlock]
    
    public init(metric: LocationDataMetricDescriptor) {
        self.metric = metric
        self.title = metric.name ?? "New Section"
        self.icon = "number"
        //self.blocks = [] //TODO: add sensible default for blocks (PDOC)
        
        self.blocks = [.init(subblocks: [DashboardGraphBlock()]), .init(subblocks: [DashboardValueBlock(), DashboardValueBlock()])]
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.metric = try container.decode(LocationDataMetricDescriptor.self, forKey: .metric)
        self.title = try container.decode(String.self, forKey: .title)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.blocks = (try container.decodeIfPresent([DashboardDisplayBlock].self, forKey: .blocks)) ?? []
    }

}

public struct DashboardDisplayBlock: Codable, Hashable {
    public static func == (lhs: DashboardDisplayBlock, rhs: DashboardDisplayBlock) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        subblocks.sorted(by: { $0.index < $1.index }).forEach { el in
            hasher.combine(el)
        }
    }
    
    public var subblocks: [any DashboardComponentBlock]
    
    public init(subblocks: [any DashboardComponentBlock] = []) {
        self.subblocks = subblocks
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.subblocks = (try container.decodeIfPresent([GenericComponentBlock].self, forKey: .subblocks)) ?? []
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

private struct GenericComponentBlock: DashboardComponentBlock, Codable {
    static func == (lhs: GenericComponentBlock, rhs: GenericComponentBlock) -> Bool {
        lhs.type == rhs.type && lhs.horizontallyStackable == rhs.horizontallyStackable && lhs.configuration.hashValue == rhs.configuration.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
        hasher.combine(index)
        hasher.combine(id)
    }
    
    let type: DashboardComponentBlockType
    
    let horizontallyStackable: Bool
    
    var configuration: any DashboardComponentBlockConfiguration
    var index: Int
    let id: UUID
    
    init(from block: any DashboardComponentBlock) {
        self.type = block.type
        self.horizontallyStackable = block.horizontallyStackable
        self.configuration = block.configuration
        self.index = block.index
        self.id = block.id
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(DashboardComponentBlockType.self, forKey: .type)
        self.horizontallyStackable = try container.decode(Bool.self, forKey: .horizontallyStackable)
        self.index = try container.decode(Int.self, forKey: .index)
        self.id = try container.decode(UUID.self, forKey: .id)
        switch type {
        case .graph:
            self.configuration = try container.decode(DashboardGraphConfiguration.self, forKey: .configuration)
        case .value:
            self.configuration = try container.decode(DashboardValueConfiguration.self, forKey: .configuration)
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(horizontallyStackable, forKey: .horizontallyStackable)
        try container.encode(index, forKey: .index)
        try container.encode(id, forKey: .id)

        switch type {
        case .graph:
            try container.encode(configuration as! DashboardGraphConfiguration, forKey: .configuration)
        case .value:
            try container.encode(configuration as! DashboardValueConfiguration, forKey: .configuration)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case type, horizontallyStackable, configuration, index, id
    }
    
}

public protocol DashboardComponentBlock: Hashable {
    var id: UUID { get }
    var type: DashboardComponentBlockType { get }
    var index: Int { get set }
    var horizontallyStackable: Bool { get }
    var configuration: any DashboardComponentBlockConfiguration { get set }
    
}

public protocol DashboardComponentBlockConfiguration: Codable, Hashable {
    var type: DashboardComponentBlockType { get }
}

public enum DashboardComponentBlockType: Int, Codable {
    case graph, value
}

// MARK: Configuration Structs for Component Types

public struct DashboardGraphConfiguration: DashboardComponentBlockConfiguration {
    public var type: DashboardComponentBlockType = .graph
    public let seriesName: String
    
    public init() {
        self.seriesName = "Test"
    }
}

public struct DashboardValueConfiguration: DashboardComponentBlockConfiguration {
    public var type: DashboardComponentBlockType = .value
    public let value: Int
    
    public init() {
        self.value = 4
    }
}

// MARK: Component Blocks for Component Types

public struct DashboardGraphBlock: DashboardComponentBlock {
    public static func == (lhs: DashboardGraphBlock, rhs: DashboardGraphBlock) -> Bool {
        lhs.configuration as! DashboardGraphConfiguration == rhs.configuration as! DashboardGraphConfiguration && lhs.index == rhs.index
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
        hasher.combine(index)
        hasher.combine(id)
    }
    
    public var id = UUID()
    public var configuration: any DashboardComponentBlockConfiguration = DashboardGraphConfiguration()
    public var type: DashboardComponentBlockType = .graph
    public var horizontallyStackable: Bool = false
    public var index: Int = 0
}

public struct DashboardValueBlock: DashboardComponentBlock {
    public static func == (lhs: DashboardValueBlock, rhs: DashboardValueBlock) -> Bool {
        lhs.id == rhs.id && lhs.configuration as! DashboardValueConfiguration == rhs.configuration as! DashboardValueConfiguration && lhs.index == rhs.index
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
        hasher.combine(index)
        hasher.combine(id)
    }
    
    public var id = UUID()
    public var configuration: any DashboardComponentBlockConfiguration = DashboardValueConfiguration()
    public var type: DashboardComponentBlockType = .value
    public var horizontallyStackable: Bool = true
    public var index = 0
}
