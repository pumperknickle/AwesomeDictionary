import Foundation
import Bedrock

public protocol Map: Codable {
    associatedtype Key: BinaryEncodable
    associatedtype Value
    associatedtype NodeType: Node where NodeType.V == Value
    
    typealias Element = (Key, Value)
    
    var trueNode: NodeType? { get }
    var falseNode: NodeType? { get }
    
    subscript(key: Key) -> Value? { get }
    func setting(key: Key, value: Value) -> Self
    func deleting(key: Key) -> Self
    func elements() -> [Element]
    func isEmpty() -> Bool
    func keys() -> [Key]
    func values() -> [Value]
    
    init(trueNode: NodeType?, falseNode: NodeType?)
    init()
}

public extension Map {
    init() {
        self = Self(trueNode: nil, falseNode: nil)
    }
    
    func isEmpty() -> Bool {
        return trueNode == nil && falseNode == nil
    }
    
    func changing(truthValue: Bool, node: NodeType?) -> Self {
        return Self(trueNode: truthValue ? node : trueNode, falseNode: truthValue ? falseNode : node)
    }
    
    func getRoot(truthValue: Bool) -> NodeType? {
        return truthValue ? trueNode : falseNode
    }
    
    subscript(key: Key) -> Value? {
        let serializedKey = key.toBoolArray()
        guard let firstBool = serializedKey.first else { return nil }
        guard let root = getRoot(truthValue: firstBool) else { return nil }
        return root.get(key: serializedKey)
    }
    
    func setting(key: Key, value: Value) -> Self {
        let serializedKey = key.toBoolArray()
        guard let firstBool = serializedKey.first else { return self }
        guard let childNode = getRoot(truthValue: firstBool) else { return changing(truthValue: firstBool, node: NodeType(prefix: serializedKey, value: value, trueNode: nil, falseNode: nil)) }
        return changing(truthValue: firstBool, node: childNode.setting(key: serializedKey, to: value))
    }
    
    func deleting(key: Key) -> Self {
        let serializedKey = key.toBoolArray()
        guard let firstBool = serializedKey.first else { return self }
        guard let childNode = getRoot(truthValue: firstBool) else { return self }
        return changing(truthValue: firstBool, node: childNode.deleting(key: serializedKey))
    }
    
    func keys() -> [Key] {
        let allBinaryKeys = (trueNode?.allKeys(key: []) ?? []) + (falseNode?.allKeys(key: []) ?? [])
        return allBinaryKeys.lazy.reduce([], { (keys, entry) -> [Key] in
            guard let key = Key(raw: entry) else { return keys }
            return keys + [key]
        })
    }
    
    func values() -> [Value] {
        return keys().lazy.reduce([], { (values, entry) -> [Value] in
            return values + [self[entry]!]
        })
    }
    
    func elements() -> [Element] {
        return keys().lazy.reduce([], { (elements, entry) -> [Element] in
            return elements + [(entry, self[entry]!)]
        })
    }
}
