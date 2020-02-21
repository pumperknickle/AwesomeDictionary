import Foundation
import Bedrock

public struct Set<Key: BinaryEncodable> {
    private let rawTrueNode: NodeType?
    private let rawFalseNode: NodeType?
}

extension Set: UniqueCollection {
    public typealias Value = Singleton
    public typealias NodeType = EnumBasedNode<Value>
    
    public var trueNode: NodeType? { return rawTrueNode }
    public var falseNode: NodeType? { return rawFalseNode }
    
    public init(trueNode: NodeType?, falseNode: NodeType?) {
        self.rawTrueNode = trueNode
        self.rawFalseNode = falseNode
    }
}
