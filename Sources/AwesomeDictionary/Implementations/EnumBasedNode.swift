import Foundation
import Bedrock

public enum EnumBasedNode<V: Codable>: Codable {
    indirect case node(prefix: [Bool], value: V?, trueNode: EnumBasedNode<V>?, falseNode: EnumBasedNode<V>?)
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
