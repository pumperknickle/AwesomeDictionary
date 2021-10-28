import Foundation

public enum NodeAltImpl<V> {
    indirect case node(prefix: Prefix, value: V?, nodes: [Self?])
}

extension NodeAltImpl: NodeAlt {
    public var prefix: Prefix! {
        switch self {
        case .node(let prefix,_,_):
            return prefix
        }
    }
    
    public var value: V? {
        switch self {
        case .node(_,let value,_):
            return value
        }
    }
    
    public var nodes: [NodeAltImpl<V>?] {
        switch self {
        case .node(_,_,let nodes):
            return nodes
        }
    }
    
    public static var arity: Int {
        return 256
    }
    
    public init(prefix: Prefix, value: V?, nodes: [NodeAltImpl<V>?]) {
        self = .node(prefix: prefix, value: value, nodes: nodes)
    }
}
