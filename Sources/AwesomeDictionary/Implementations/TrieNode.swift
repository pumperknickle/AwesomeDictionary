import Foundation
import Bedrock

public struct TrieNode<V: Codable>: Node {
    private let rawPrefix: [Bool]!
    private let rawValue: V?
    private let rawTrueNode: [TrieNode<V>]!
    private let rawFalseNode: [TrieNode<V>]!
    
    public var prefix: [Bool]! { return rawPrefix }
    public var value: V? { return rawValue }
    public var trueNode: TrieNode<V>? { return rawTrueNode.first }
    public var falseNode: TrieNode<V>? { return rawFalseNode.first }
    
    public init(prefix: [Bool], value: V?, trueNode: TrieNode<V>?, falseNode: TrieNode<V>?) {
        self.rawPrefix = prefix
        self.rawValue = value
        self.rawTrueNode = trueNode == nil ? [] : [trueNode!]
        self.rawFalseNode = falseNode == nil ? [] : [falseNode!]
    }
}
