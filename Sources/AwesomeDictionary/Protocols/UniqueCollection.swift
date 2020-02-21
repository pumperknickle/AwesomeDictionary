import Foundation

public protocol UniqueCollection: Map where Value == Singleton {
    func contains(_ key: Key) -> Bool
    func adding(_ key: Key) -> Self
    func removing(_ key: Key) -> Self
    func toArray() -> [Key]
}

public extension UniqueCollection {
    func contains(_ key: Key) -> Bool {
        return self[key] != nil
    }
    
    func adding(_ key: Key) -> Self {
        return setting(key: key, value: Singleton.void)
    }
    
    func removing(_ key: Key) -> Self {
        return deleting(key: key)
    }
    
    func toArray() -> [Key] {
        return keys()
    }
}

