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
        
        self.blocks = [.init(subblocks: [GraphBlock()]), .init(subblocks: [ValueBlock(), ValueBlock()])]
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

private struct GenericComponentBlock: DashboardComponentBlock, Codable {
    static func == (lhs: GenericComponentBlock, rhs: GenericComponentBlock) -> Bool {
        lhs.type == rhs.type && lhs.horizontallyStackable == rhs.horizontallyStackable && lhs.configuration.hashValue == rhs.configuration.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
    }
    
    let type: DashboardComponentBlockType
    
    let horizontallyStackable: Bool
    
    var configuration: any DashboardComponentBlockConfiguration
    var index: Int
    
    init(from block: any DashboardComponentBlock) {
        self.type = block.type
        self.horizontallyStackable = block.horizontallyStackable
        self.configuration = block.configuration
        self.index = block.index
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(DashboardComponentBlockType.self, forKey: .type)
        self.horizontallyStackable = try container.decode(Bool.self, forKey: .horizontallyStackable)
        self.index = try container.decode(Int.self, forKey: .index)
        switch type {
        case .graph:
            self.configuration = try container.decode(GraphConfig.self, forKey: .configuration)
        case .value:
            self.configuration = try container.decode(ValueConfig.self, forKey: .configuration)
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(horizontallyStackable, forKey: .horizontallyStackable)
        try container.encode(index, forKey: .index)

        switch type {
        case .graph:
            try container.encode(configuration as! GraphConfig, forKey: .configuration)
        case .value:
            try container.encode(configuration as! ValueConfig, forKey: .configuration)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case type, horizontallyStackable, configuration, index
    }
    
}

public protocol DashboardComponentBlock: Hashable {
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

struct GraphBlock: DashboardComponentBlock {
    static func == (lhs: GraphBlock, rhs: GraphBlock) -> Bool {
        lhs.configuration as! GraphConfig == rhs.configuration as! GraphConfig && lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
        hasher.combine(index)
    }
    
    var configuration: any DashboardComponentBlockConfiguration = GraphConfig()
    var type: DashboardComponentBlockType = .graph
    var horizontallyStackable: Bool = false
    var index: Int = 0
}

struct ValueBlock: DashboardComponentBlock {
    static func == (lhs: ValueBlock, rhs: ValueBlock) -> Bool {
        lhs.configuration as! ValueConfig == rhs.configuration as! ValueConfig && lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(configuration)
        hasher.combine(type)
        hasher.combine(horizontallyStackable)
        hasher.combine(index)
    }
    
    var configuration: any DashboardComponentBlockConfiguration = ValueConfig()
    var type: DashboardComponentBlockType = .value
    var horizontallyStackable: Bool = true
    var index = 0
}
