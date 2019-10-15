import Foundation
import Bedrock

public struct Mapping<Key: BinaryEncodable, Value: Codable>: Map {
    public typealias NodeType = TrieNode<Value>
    
    private let rawTrueNode: NodeType?
    private let rawFalseNode: NodeType?
    
    public var trueNode: NodeType? { return rawTrueNode }
    public var falseNode: NodeType? { return rawFalseNode }
    
    public init(trueNode: NodeType?, falseNode: NodeType?) {
        self.rawTrueNode = trueNode
        self.rawFalseNode = falseNode
    }
}

public extension Mapping {
    func overwrite(with map: Mapping) -> Mapping {
        return map.elements().lazy.reduce(self, { (result, entry) -> Mapping in
            return result.setting(key: entry.0, value: entry.1)
        })
    }
}

public extension Mapping where Value == [[String]] {
    func prepend(_ key: String) -> Mapping<Key, Value> {
        return elements().lazy.reduce(Mapping<Key, Value>()) { (result, entry) -> Mapping<Key, Value> in
            result.setting(key: entry.0, value: entry.1.map { [key] + $0 })
        }
    }
    
    static func + (lhs: Mapping<Key, Value>, rhs: Mapping<Key, Value>) -> Mapping<Key, Value> {
        return rhs.elements().lazy.reduce(lhs) { (result, entry) -> Mapping<Key, Value> in
            guard let current = result[entry.0] else { return result.setting(key: entry.0, value: entry.1) }
            return result.setting(key: entry.0, value: entry.1 + current)
        }
    }
}
