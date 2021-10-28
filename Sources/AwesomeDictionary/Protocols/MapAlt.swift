import Foundation
import Bedrock

public protocol MapAlt: Codable {
    associatedtype Key: DataEncodable, Hashable
    associatedtype Value: Codable
    associatedtype NodeType: NodeAlt where NodeType.V == Value
    
    typealias KeyValuePair = (Key, Value)
    
    var nodes: [NodeType?] { get }
    
    func overwrite(with otherMap: Self) -> Self
    func deleting(key: Key) -> Self
    func setting(key: Key, value: Value) -> Self
    func isEmpty() -> Bool
    func elements() -> [KeyValuePair]
    subscript(key: Key) -> Value? { get }
    
    
    init(keyValuePairs: [(Key, Value)])
    init(nodes: [NodeType?])
    init()
}

public extension MapAlt {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionaryRep = try container.decode([Key: Value].self)
        self = Self(keyValuePairs: dictionaryRep.map { ($0.key, $0.value) })
    }

    func encode(to encoder: Encoder) throws {
        let stringDictionary: [Key: Value] = Dictionary(
          uniqueKeysWithValues: elements()
        )
        var container = encoder.singleValueContainer()
        try container.encode(stringDictionary)
    }
    
    init(keyValuePairs: [(Key, Value)]) {
        self = keyValuePairs.reduce(Self()) { result, entry in
            return result.setting(key: entry.0, value: entry.1)
        }
    }

    func changing(element: NodeType.Element, node: NodeType?) -> Self {
        let idx = Int(element)
        if idx == 0 {
            return Self(nodes: [node] + nodes.suffix(from: 1))
        }
        if idx == Self.NodeType.arity - 1 {
            return Self(nodes: nodes.prefix(upTo: idx) + [node])
        }
        return Self(nodes: Array(nodes.prefix(upTo: idx) + [node] + nodes.suffix(from: idx + 1)))
    }
    
    init() {
        self.init(nodes: NodeType.emptyNodes())
    }
    
    func isEmpty() -> Bool {
        return !nodes.contains(where: { $0 != nil })
    }
    
    subscript(key: Key) -> Value? {
        let serializedKey = key.toData()
        guard let firstByte = serializedKey.first else { return nil }
        guard let root = getRoot(element: firstByte) else { return nil }
        return root.get(key: serializedKey, index: 0)
    }
    
    func getRoot(element: NodeType.Element) -> NodeType? {
        return nodes[Int(element)]
    }
    
    func setting(key: Key, value: Value) -> Self {
        let serializedKey = NodeType.Prefix(key.toData())
        guard let firstByte = serializedKey.first else { return self }
        guard let childNode = getRoot(element: firstByte) else { return changing(element: firstByte, node: NodeType(prefix: serializedKey, value: value, nodes: NodeType.emptyNodes())) }
        return changing(element: firstByte, node: childNode.setting(key: serializedKey, index: 0, to: value))
    }
 
    func deleting(key: Key) -> Self {
        let serializedKey = key.toData()
        guard let firstByte = serializedKey.first else { return self }
        guard let childNode = getRoot(element: firstByte) else { return self }
        return changing(element: firstByte, node: childNode.deleting(key: serializedKey, index: 0))
    }

    func overwrite(with otherMap: Self) -> Self {
        return merge(with: otherMap) { (left, right) -> Value in
            return right
        }
    }

    func merge(with other: Self, combine: (Value, Value) -> Value) -> Self {
        let newNodes: [NodeType?] = zip(nodes, other.nodes).map { tuples in
            if tuples.0 == nil && tuples.1 == nil { return nil }
            if tuples.0 != nil && tuples.1 != nil { return tuples.0!.merge(with: tuples.1!, combine: combine) }
            if tuples.0 != nil { return tuples.0 }
            return tuples.1
        }
        return Self(nodes: newNodes)
    }
    
    func elements() -> [KeyValuePair] {
        var toVisit = Stack<(prefix: NodeType.Prefix, node: NodeType)>()
        var elements = [KeyValuePair]()
        for node in nodes {
            if let node = node {
                toVisit.push((prefix: NodeType.Prefix([]), node: node))
            }
        }
        while (toVisit.peek() != nil) {
            var current = toVisit.pop()
            current.prefix.append(contentsOf: current.node.prefix)
            if let currentValue = current.node.value {
                elements.append((Key(data: current.prefix)!, currentValue))
            }
            for node in current.node.nodes {
                if let node = node {
                    toVisit.push((prefix: current.prefix, node: node))
                }
            }
        }
        return elements
    }

    func keys() -> [Key] {
        return elements().map { $0.0 }
    }

    func values() -> [Value] {
        return elements().map { $0.1 }
    }
//    
//    @inlinable
//    @inline(__always)
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        return lhs.nodes == rhs.nodes
//    }

    func contains(_ key: Key) -> Bool {
        return self[key] != nil
    }
}
