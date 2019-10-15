# AwesomeDictionary

AwesomeDictionary is a pure Swift implementation of a Dictionary or an abstract data type composed of a collection of (key, value) pairs, such that each possible key appears at most once in the collection. Instead of using hash tables, it uses a radix trie, which is essentially a compressed trie.

## Features

1. Functional
- All operations create new objects.
- All mappings in AwesomeDictionary are immutable.
2. Generic
- Can be used with any Key type that conforms to BinaryEncodable.
- Can be used with any Value type that conforms to Codable.
3. Deterministic
- Two dictionaries with the same key value pairs are guaranteed to be the same.
- Two dictionaries with the same key value pairs are guaranteed to serialized the same byte for byte.
4. Efficient
- Modify existing dictionaries efficiently and functionally.
5. Codable
- Easily serializable to and from JSON and other encodings.
  
  
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
