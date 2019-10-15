# AwesomeDictionary

AwesomeDictionary is a pure Swift implementation of a Dictionary or an abstract data type composed of a collection of (key, value) pairs, such that each possible key appears at most once in the collection. Instead of using hash tables, it uses a radix trie, which is essentially a compressed trie.

### Features

Functional
All operations create new objects, and all dictionaries in AwesomeDictionary are immutable.
Generic
Can be used with any key - value types (that conform to BinaryEncodable and Codable respectively).
Deterministic
Two dictionaries with the same key value pairs are guaranteed to be the same byte for byte (including for encoding/decoding).
Efficient
Modify existing dictionaries efficiently and functionally
Codable
Easily serializable to and from JSON encoding
  
  
### Installation

#### Swift Package Manager

Add AwesomeDictionary to Package.swift and the appropriate targets

```swift
dependencies: [
.package(url: "https://github.com/pumperknickle/AwesomeDictionary.git", from: "1.0.0")
]
```

### Usage

#### Importing

Use AwesomeDictionary by including it in the imports of your swift file

```swift
import AwesomeDictionary
```

#### Initialization

Create an empty generic mapping

```swift
let newMapping = Mapping<String, [[String]]>()
```

#### Getting

Use subscript to get the value of a key.

```swift
let value = newMapping["foo"]
```

#### Setting

When setting, a new structure is returned with the new key value pair inserted.

```swift
let modifiedMap = newMapping.setting(key: "foo", value: [["fooValue"]])
```

#### Deleting keys

When deleting, a new structure is returned with the entry corresponding to the key deleted.

```swift
let modifiedMap = newMapping.deleting(key: "foo")
```
