import Foundation
import Bedrock

public enum MappingAlt<Key: DataEncodable & Hashable, Value: Codable> {
    indirect case map(nodes: [NodeType?])
}

extension MappingAlt: MapAlt {
    public typealias Key = Key
    public typealias Value = Value
    public typealias NodeType = NodeAltImpl<Value>
        
    public var nodes: [NodeType?] {
        switch self {
        case .map(let nodes):
            return nodes
        }
    }
    
    public init(nodes: [NodeType?]) {
        self = .map(nodes: nodes)
    }
}


