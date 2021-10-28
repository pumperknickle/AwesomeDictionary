import Foundation
import Bedrock

public protocol NodeAlt {
    associatedtype V
    
    typealias Prefix = Data
    typealias Element = Prefix.Element
    
    var prefix: Prefix! { get }
    var value: V? { get }
    var nodes: [Self?] { get }
    
    static var arity: Int { get }
    
    func get(key: Prefix, index: Int) -> V?
    func setting(key: Prefix, index: Int, to value: V) -> Self
    func deleting(key: Prefix, index: Int) -> Self?
    func merge(with other: Self, combine: (V, V) -> V) -> Self
        
    init(prefix: Prefix, value: V?, nodes: [Self?])
}

public extension NodeAlt {
    static func emptyNodes() -> [Self?] {
        return (0..<arity).map { _ in nil }
    }

    func getNode(element: Element) -> Self? {
        return nodes[Int(element)]
    }

    func changing(prefix: Prefix) -> Self {
        return Self(prefix: prefix, value: value, nodes: nodes)
    }

    func changing(value: V?) -> Self {
        return Self(prefix: prefix, value: value, nodes: nodes)
    }

    func changing(element: Element, node: Self?) -> Self {
        let idx = Int(element)
        if idx == 0 {
            return Self(prefix: prefix, value: value, nodes: [node] + nodes.suffix(from: 1))
        }
        if idx == Self.arity - 1 {
            return Self(prefix: prefix, value: value, nodes: nodes.prefix(upTo: idx) + [node])
        }
        return Self(prefix: prefix, value: value, nodes: Array(nodes.prefix(upTo: idx) + [node] + nodes.suffix(from: idx + 1)))
    }
    
    func get(key: Prefix, index: Int) -> V? {
        if !key.startsWith(idx: index, other: prefix) { return nil }
        let newIdx = index + prefix.count
        if key.count == newIdx {
            return value
        }
        let newElement = key[newIdx]
        guard let childNode = getNode(element: newElement) else { return nil }
        return childNode.get(key: key, index: newIdx)
    }
    
    func setting(key: Prefix, index: Int, to value: V) -> Self {
        let comparisonResult = key.compare(idx: index, other: prefix, otherIdx: 0, countSimilar: 0)
        switch comparisonResult {
        case -3:
            let nextIdx = index + prefix.count
            let firstValue = key[nextIdx]
            guard let childNode = getNode(element: firstValue) else {
                let nextPrefix = Array(key.dropFirst(index + prefix.count))
                return changing(element: firstValue, node: Self(prefix: Data(nextPrefix), value: value, nodes: Self.emptyNodes()))
            }
            return changing(element: firstValue, node: childNode.setting(key: key, index: nextIdx, to: value))
        case -2:
            let keyArray = Array(key.dropFirst(index))
            let suffix = Array(prefix.dropFirst(keyArray.count))
            return Self(prefix: Data(keyArray), value: value, nodes: Self.emptyNodes()).changing(element: suffix.first!, node: changing(prefix: Data(suffix)))
        case -1:
            return changing(value: value)
        default:
            let parentPrefix = prefix.prefix(comparisonResult)
            let newPrefix = key.dropFirst(index + comparisonResult)
            let oldPrefix = prefix.dropFirst(comparisonResult)
            let newNode = Self(prefix: Data(Array(newPrefix)), value: value, nodes: Self.emptyNodes())
            let oldNode = changing(prefix: Data(Array(oldPrefix)))
            // could optimized to be twice as fast
            return Self(prefix: Data(Array(parentPrefix)), value: nil, nodes: Self.emptyNodes()).changing(element: newPrefix.first!, node: newNode).changing(element: oldPrefix.first!, node: oldNode)
        }
    }

    func deleting() -> Self? {
        guard let foundChild = findChild(idx: 0) else { return nil }
        if foundChild.2 { return changing(value: nil) }
        return foundChild.0.changing(prefix: prefix + foundChild.0.prefix)
    }
    
    func deleting(key: Prefix, index: Int) -> Self? {
        if !key.startsWith(idx: index, other: prefix) { return self }
        let newIdx = index + prefix.count
        if key.count <= newIdx { return deleting() }
        let firstValueAfter = key[newIdx]
        guard let child = getNode(element: firstValueAfter) else { return self }
        guard let childResult = child.deleting(key: key, index: newIdx) else {
            if value == nil && !containsAtLeast(n: 3, idx: 0) {
                let otherChildIdx = Int(getOtherChild(notIdx: Int(firstValueAfter), idx: 0)!)
                return nodes[otherChildIdx]!.changing(prefix: prefix + nodes[otherChildIdx]!.prefix)
            }
            return changing(element: firstValueAfter, node: nil)
        }
        return changing(element: firstValueAfter, node: childResult)
    }
    
    func merge(with other: Self, combine: (V, V) -> V) -> Self {
        let comparisonResult = self.prefix.compare(idx: 0, other: other.prefix, otherIdx: 0, countSimilar: 0)
        if comparisonResult == -3 {
            let suffix = Array(prefix.dropFirst(other.prefix.count))
            let firstSuffix = suffix.first!
            guard let currentChild = other.nodes[Int(firstSuffix)] else {
                return other.changing(element: firstSuffix, node: changing(prefix: Prefix(suffix)))
            }
            return other.changing(element: firstSuffix, node: changing(prefix: Prefix(suffix)).merge(with: currentChild, combine: combine))
        }
        if comparisonResult == -2 {
            let suffix = Array(other.prefix.dropFirst(prefix.count))
            let firstSuffix = suffix.first!
            guard let currentChild = nodes[Int(firstSuffix)] else {
                return changing(element: firstSuffix, node: other.changing(prefix: Prefix(suffix)))
            }
            return changing(element: firstSuffix, node: other.changing(prefix: Prefix(suffix)).merge(with: currentChild, combine: combine))
        }
        if comparisonResult == -1 {
            let newNodes: [Self?] = zip(nodes, other.nodes).map { tuples in
                if tuples.0 == nil && tuples.1 == nil { return nil }
                if tuples.0 != nil && tuples.1 != nil { return tuples.0!.merge(with: tuples.1!, combine: combine) }
                if tuples.0 != nil { return tuples.0 }
                return tuples.1
            }
            if value != nil && other.value != nil {
                return Self(prefix: self.prefix, value: combine(value!, other.value!), nodes: newNodes)
            }
            return Self(prefix: self.prefix, value: value ?? other.value, nodes: newNodes)
        }
        let commonPrefix = prefix.prefix(comparisonResult)
        let nodeSuffix = other.prefix.dropFirst(commonPrefix.count)
        let suffix = prefix.dropFirst(commonPrefix.count)
        return Self(prefix: Prefix(Array(commonPrefix)), value: nil, nodes: Self.emptyNodes()).changing(element: nodeSuffix.first!, node: other.changing(prefix: Prefix(Array(nodeSuffix)))).changing(element: suffix.first!, node: changing(prefix: Prefix(Array(suffix))))
    }

    func getOtherChild(notIdx: Int, idx: Int) -> Int? {
        if idx >= Self.arity { return nil }
        if idx == notIdx { return getOtherChild(notIdx: notIdx, idx: idx + 1) }
        if nodes[idx] != nil { return idx }
        return getOtherChild(notIdx: notIdx, idx: idx + 1)
    }

    func findChild(idx: Int) -> (Self, Int, Bool)? {
        if idx == Self.arity { return nil }
        guard let foundNode = nodes[idx] else { return findChild(idx: idx + 1) }
        return (foundNode, idx, containsAtLeast(n: 1, idx: idx + 1))
    }
    
    func containsAtLeast(n: Int, idx: Int) -> Bool {
        if n == 0 { return true }
        if idx == Self.arity { return false }
        if nodes[idx] != nil { return containsAtLeast(n: n - 1, idx: idx + 1) }
        return containsAtLeast(n: n, idx: idx + 1)
    }
}

extension Data {
    
    // return -3 if self starts with other
    // return -2 if other starts with self
    // return -1 if self == other
    // return number of similar starting elements
    func compare(idx: Int, other: Data, otherIdx: Int, countSimilar: Int) -> Int {
        if otherIdx >= other.count && idx >= self.count { return -1 }
        if otherIdx >= other.count { return -3 }
        if idx >= self.count { return -2 }
        if self[idx] == other[otherIdx] {
            return compare(idx: idx + 1, other: other, otherIdx: otherIdx + 1, countSimilar: countSimilar + 1)
        }
        return countSimilar
    }
    
    func startsWith(idx: Int, other: Data) -> Bool {
        if other.count > count - idx { return false }
        return startsWith(idx: idx, other: other, otherIdx: 0)
    }
    
    func startsWith(idx: Int, other: Data, otherIdx: Int) -> Bool {
        if otherIdx >= other.count {
            return true }
        if idx >= self.count {
            return false }
        if self[idx] == other[otherIdx] {
            return startsWith(idx: idx + 1, other: other, otherIdx: otherIdx + 1)
        }
        return false
    }
}
//
//extension NodeAlt where V: Equatable {
//    @inlinable
//    @inline(__always)
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        if lhs.prefix != rhs.prefix { return false }
//        if lhs.value != rhs.value { return false }
//        return zip(lhs.nodes, <#T##sequence2: Sequence##Sequence#>)
//    }
//}
