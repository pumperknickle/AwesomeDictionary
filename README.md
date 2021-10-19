# Persistent Dictionaries

Awesome Dictionary is a pure Swift implementation of a persistent Dictionary, composed of a collection of codable (key, value) pairs, such that each possible key appears at most once in the collection. Instead of using hash tables, it uses a compressed trie representatioon.

## Features

1. Persistent
- All versions are immutable.
- All operations create new objects, potentially reusing subgraphs of previous versions.
3. Generic
- Can be used with any Key type that conforms to BinaryEncodable.
- Can be used with any Value type that conforms to Codable.
4. Deterministic
- Two dictionaries with the same key value pairs are guaranteed to be the same.
- Two dictionaries with the same key value pairs are guaranteed to serialized exactly the same byte for byte.
5. Efficient
- Deletes maintain the Trie in a compact canonical form.
- Equality "short circuit".
6. Codable
- Easily serializable to and from JSON and other encodings.
7. Merge Functionality
- Efficiently merge two dictionaries, where runtime is O(m + n) where m and n are the number of nodes for both dictionaries.
  
  
## Installation

#### Swift Package Manager

Add AwesomeDictionary to Package.swift and the appropriate targets

```swift
dependencies: [
.package(url: "https://github.com/pumperknickle/AwesomeDictionary.git", from: "0.0.1")
]
```

## Usage

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

#### Deleting

When deleting, a new structure is returned with the entry corresponding to the key deleted.

```swift
let modifiedMap = newMapping.deleting(key: "foo")
```
