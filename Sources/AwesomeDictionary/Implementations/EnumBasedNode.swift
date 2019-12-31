import Foundation
import Bedrock

public enum EnumBasedNode<V: Codable>: Codable {
    indirect case node(prefix: [Bool], value: V?, trueNode: EnumBasedNode<V>?, falseNode: EnumBasedNode<V>?)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let prefix = try container.decode(String.self, forKey: .prefix)
        let value = try? container.decode(V.self, forKey: .value)
        let trueNode = try? container.decode(Self.self, forKey: .trueNode)
        let falseNode = try? container.decode(Self.self, forKey: .falseNode)
        self = .node(prefix: prefix.bools(), value: value, trueNode: trueNode, falseNode: falseNode)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .node(let prefix, let value, let trueNode, let falseNode):
            try container.encode(prefix.literal(), forKey: .prefix)
            if let value = value { try container.encode(value, forKey: .value) }
            if let trueNode = trueNode { try container.encode(trueNode, forKey: .trueNode) }
            if let falseNode = falseNode { try container.encode(falseNode, forKey: .falseNode) }
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case prefix
        case value
        case trueNode
        case falseNode
    }
}

extension EnumBasedNode: Node {
    public var prefix: [Bool]! {
        switch self {
        case .node(let prefix,_,_,_):
            return prefix
        }
    }
    
    public var value: V? {
        switch self {
        case .node(_,let value,_,_):
            return value
        }
    }
    
    public var trueNode: EnumBasedNode<V>? {
        switch self {
        case .node(_,_,let trueNode,_):
            return trueNode
        }
    }
    
    public var falseNode: EnumBasedNode<V>? {
        switch self {
        case .node(_,_,_,let falseNode):
            return falseNode
        }
    }
    
    public init(prefix: [Bool], value: V?, trueNode: EnumBasedNode<V>?, falseNode: EnumBasedNode<V>?) {
        self = .node(prefix: prefix, value: value, trueNode: trueNode, falseNode: falseNode)
    }
}
