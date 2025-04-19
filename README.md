# PrimitiveCoder

An *extremely* experimental Swift Decoder and Encoder which transforms the objects to and from
primitive values to complex Swift objects. 

## Examples

### Decoding

```swift
struct SimpleObject: Codable, Equatable {
    let colour: String
}

let cow = try PrimitiveDecoder().decode(type: SimpleObject.self, value: ["colour": "blue"])
// produces SimpleObject(colour: "blue")
```

### Encoding

#### Simple key values:

```swift
try encoder.encode(["Henry" : 6, "Martha": 10])
// produces .keyed(
//    [
//        (_DictionaryCodingKey(stringValue: "Martha", intValue: nil), .single(10)),
//        (_DictionaryCodingKey(stringValue: "Henry", intValue: nil), .single(6))
//    ]
// )

```

#### Date with passthrough

```swift
let encoder = PrimitiveEncoder()
encoder.primitiveTypes = [Date.self]
let result = try encoder.encode(Date.now)
// produces .single(2025-04-19 18:51:24 +0000)
```

#### Date without passthrough

```swift
let encoder = PrimitiveEncoder()
encoder.primitiveTypes = []
let result = try encoder.encode(Date.now)
// produces .single(766781540.428759)
```
