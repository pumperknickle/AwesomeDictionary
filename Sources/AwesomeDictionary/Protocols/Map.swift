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
	func first() -> Element?
    func contains(_ key: Key) -> Bool
	func overwrite(with otherMap: Self) -> Self
    
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
    
    func contains(_ key: Key) -> Bool {
         return self[key] != nil
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
	
	func first() -> Element? {
		if let falseResult = falseNode?.first() {
			guard let key = Key(raw: falseResult.0) else { return nil }
			return (key, falseResult.1)
		}
		if let trueResult = trueNode?.first() {
			guard let key = Key(raw: trueResult.0) else { return nil }
			return (key, trueResult.1)
		}
		return nil
	}
	
	func overwrite(with otherMap: Self) -> Self {
		if ((self.trueNode == nil) != (otherMap.trueNode == nil) && (self.falseNode == nil) != (otherMap.falseNode == nil)) {
			return Self(trueNode: self.trueNode ?? otherMap.trueNode!, falseNode: self.falseNode ?? otherMap.falseNode!)
		}
		return otherMap.elements().lazy.reduce(self, { (result, entry) -> Self in
            return result.setting(key: entry.0, value: entry.1)
        })
	}
}
