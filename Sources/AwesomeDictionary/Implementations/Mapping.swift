import Foundation
import Bedrock

public struct Mapping<Key: BinaryEncodable, Value: Codable>: Map {
    public typealias NodeType = EnumBasedNode<Value>
    
    private let rawTrueNode: NodeType?
    private let rawFalseNode: NodeType?
    
    public var trueNode: NodeType? { return rawTrueNode }
    public var falseNode: NodeType? { return rawFalseNode }
    
    public init(trueNode: NodeType?, falseNode: NodeType?) {
        self.rawTrueNode = trueNode
        self.rawFalseNode = falseNode
    }
}
