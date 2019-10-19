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

public extension Node {
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
}
