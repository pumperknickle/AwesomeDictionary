import Foundation
import Bedrock

public protocol Node: Codable {
    associatedtype V: Codable
    
    var prefix: [Bool]! { get }
    var value: V? { get }
    var trueNode: Self? { get }
    var falseNode: Self? { get }
    
    func get(key: [Bool]) -> V?
    func setting(key: [Bool], to value: V) -> Self
    func deleting(key: [Bool]) -> Self?
	func first() -> ([Bool], V)
    
    init(prefix: [Bool], value: V?, trueNode: Self?, falseNode: Self?)
}

public enum CodingKeys: String, CodingKey {
    case prefix
    case value
    case trueNode
    case falseNode
}

public extension Node {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let prefix = try container.decode(String.self, forKey: .prefix)
        let value = try? container.decode(V.self, forKey: .value)
        let trueNode = try? container.decode(Self.self, forKey: .trueNode)
        let falseNode = try? container.decode(Self.self, forKey: .falseNode)
        self.init(prefix: prefix.bools(), value: value, trueNode: trueNode, falseNode: falseNode)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prefix.literal(), forKey: .prefix)
        if let value = value { try container.encode(value, forKey: .value) }
        if let trueNode = trueNode { try container.encode(trueNode, forKey: .trueNode) }
        if let falseNode = falseNode { try container.encode(falseNode, forKey: .falseNode) }
    }
    
    func getNode(truthValue: Bool) -> Self? {
        return truthValue ? trueNode : falseNode
    }
    
    func changing(prefix: [Bool]) -> Self {
        return Self(prefix: prefix, value: value, trueNode: getNode(truthValue: true), falseNode: getNode(truthValue: false))
    }
    
    func changing(value: V?) -> Self {
        return Self(prefix: prefix, value: value, trueNode: getNode(truthValue: true), falseNode: getNode(truthValue: false))
    }
    
    func changing(truthValue: Bool, node: Self?) -> Self {
        return Self(prefix: prefix, value: value, trueNode: truthValue ? node : getNode(truthValue: true), falseNode: truthValue ? getNode(truthValue: false) : node)
    }
    
    func isValid() -> Bool {
        if value == nil && (getNode(truthValue: true) == nil || getNode(truthValue: false) == nil) { return false }
        if let trueNode = getNode(truthValue: true) {
            if trueNode.prefix.first == nil || trueNode.prefix.first! == false || !trueNode.isValid() { return false }
        }
        if let falseNode = getNode(truthValue: false) {
            if falseNode.prefix.first == nil || falseNode.prefix.first! == true || !falseNode.isValid() { return false }
        }
        return true
    }
    
    func allKeys(key: [Bool]) -> [[Bool]] {
        let newKey = key + prefix
        return (getNode(truthValue: false)?.allKeys(key: newKey) ?? []) + (getNode(truthValue: true)?.allKeys(key: newKey) ?? []) + (value == nil ? [] : [newKey])
    }
    
    func get(key: [Bool]) -> V? {
        if !key.starts(with: prefix) { return nil }
        let suffix = key - prefix
        guard let firstValue = suffix.first else { return value }
        guard let childNode = getNode(truthValue: firstValue) else { return nil }
        return childNode.get(key: suffix)
    }
    
    func setting(key: [Bool], to value: V) -> Self {
        if key.count >= prefix.count && key.starts(with: prefix) {
            let suffix = key - prefix
            guard let firstValue = suffix.first else { return changing(value: value) }
            guard let childNode = getNode(truthValue: firstValue) else { return changing(truthValue: firstValue, node: Self(prefix: suffix, value: value, trueNode: nil, falseNode: nil)) }
            return changing(truthValue: firstValue, node: childNode.setting(key: suffix, to: value))
        }
        if prefix.count > key.count && prefix.starts(with: key) {
            let suffix = prefix - key
            return Self(prefix: key, value: value, trueNode: nil, falseNode: nil).changing(truthValue: suffix.first!, node: changing(prefix: suffix))
        }
        let parentPrefix = key ~> prefix
        let newPrefix = key - parentPrefix
        let oldPrefix = prefix - parentPrefix
        let newNode = Self(prefix: newPrefix, value: value, trueNode: nil, falseNode: nil)
        let oldNode = changing(prefix: oldPrefix)
        return Self(prefix: parentPrefix, value: nil, trueNode: nil, falseNode: nil).changing(truthValue: newPrefix.first!, node: newNode).changing(truthValue: oldPrefix.first!, node: oldNode)
    }
    
    func deleting() -> Self? {
        if getNode(truthValue: true) == nil && getNode(truthValue: false) == nil { return nil }
        if getNode(truthValue: true) != nil && getNode(truthValue: false) != nil { return changing(value: nil) }
        if let node = getNode(truthValue: true) { return node.changing(prefix: prefix + node.prefix) }
        let node = getNode(truthValue: false)!
        return node.changing(prefix: prefix + node.prefix)
    }
    
    func deleting(key: [Bool]) -> Self? {
        if !key.starts(with: prefix) { return self }
        let suffix = key - prefix
        guard let firstValue = suffix.first else { return deleting() }
        guard let child = getNode(truthValue: firstValue) else { return self }
        guard let childResult = child.deleting(key: suffix) else {
            guard let _ = value else {
                let childNode = getNode(truthValue: !firstValue)!
                return childNode.changing(prefix: prefix + childNode.prefix)
            }
            return changing(truthValue: firstValue, node: nil)
        }
        return changing(truthValue: firstValue, node: childResult)
    }
	
	func first() -> ([Bool], V) {
		if let value = value {
			return (prefix, value)
		}
		if let falseResult = falseNode?.first() {
			return (prefix + falseResult.0, falseResult.1)
		}
		let trueResult = trueNode!.first()
		return (prefix + trueResult.0, trueResult.1)
	}
    
    func merge(with other: Self, combine: (V, V) -> V) -> Self {
        if self.prefix == other.prefix {
            let newTrueNode = trueNode != nil ? (other.trueNode != nil ? trueNode!.merge(with: other.trueNode!, combine: combine) : trueNode!) : (other.trueNode != nil ? other.trueNode! : nil)
            let newFalseNode = falseNode != nil ? (other.falseNode != nil ? falseNode!.merge(with: other.falseNode!, combine: combine) : falseNode!) : (other.falseNode != nil ? other.falseNode! : nil)
            let newValue = value != nil ? (other.value != nil ? combine(value!, other.value!) : value) : (other.value != nil ? other.value : nil)
            return Self(prefix: self.prefix, value: newValue, trueNode: newTrueNode, falseNode: newFalseNode)
        }
        if prefix.starts(with: other.prefix) {
            let suffix = prefix - other.prefix
            let firstSuffix = suffix.first!
            guard let currentChild = (firstSuffix ? other.trueNode : other.falseNode) else {
                return other.changing(truthValue: firstSuffix, node: changing(prefix: suffix))
            }
            return other.changing(truthValue: firstSuffix, node: changing(prefix: suffix).merge(with: currentChild, combine: combine))
        }
        if other.prefix.starts(with: prefix) {
            let suffix = other.prefix - prefix
            let firstSuffix = suffix.first!
            guard let currentChild = (firstSuffix ? trueNode : falseNode) else {
                return changing(truthValue: firstSuffix, node: other.changing(prefix: suffix))
            }
            return changing(truthValue: firstSuffix, node: other.changing(prefix: suffix).merge(with: currentChild, combine: combine))
        }
        let commonPrefix = other.prefix ~> prefix
        let nodeSuffix = other.prefix - commonPrefix
        let suffix = prefix - commonPrefix
        return Self(prefix: commonPrefix, value: nil, trueNode: nil, falseNode: nil).changing(truthValue: nodeSuffix.first!, node: other.changing(prefix: nodeSuffix)).changing(truthValue: suffix.first!, node: changing(prefix: suffix))
    }
}
