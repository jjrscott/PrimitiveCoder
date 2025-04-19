import Testing
import PrimitiveCoder
import Foundation

struct SimpleObject: Codable, Equatable {
    let date: Date
    let colour: String
}

struct ComplexObject: Codable, Equatable {
    let simpleObject: SimpleObject
    let nestedObject: [String: Double]
}

@Test func testSimpleObject() async throws {
    let date = Date.now
    let cow = try PrimitiveDecoder().decode(type: SimpleObject.self, value: ["date": date, "colour": "blue"])
    #expect(cow == SimpleObject(date: date, colour: "blue"))
}


struct MultipleSingleValueObject: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        _ = try container.decode(String.self)
        _ = try container.decode(String.self)
    }
}

@Test func testMultipleSingleValueObjectFailure() async throws {
    #expect(throws: DecodingError.self) {
        try PrimitiveDecoder().decode(type: MultipleSingleValueObject.self, value: "womble")
    }
}


@Test func encodeSimpleObject() async throws {
    let encoder = PrimitiveEncoder()
    encoder.primitiveTypes.append(SimpleObject.self)
    let result = try encoder.encode(ComplexObject(simpleObject: SimpleObject(date: Date.now, colour: "blue"), nestedObject: ["Henry" : 6, "Martha": 10]))
    print(try encoder.encode(["Henry" : 6, "Martha": 10]))
}

@Test func encodeDate() async throws {
    let encoder = PrimitiveEncoder()
//    encoder.primitiveTypes = [Date.self]
    let result = try encoder.encode(Date.now)
    print(result)

}
