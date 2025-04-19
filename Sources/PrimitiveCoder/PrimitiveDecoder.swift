//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 John Scott. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

private protocol PrimitiveDecoderProtocol {
    init(value: Any?, codingPath: [CodingKey], root: PrimitiveDecoder) throws
}

public class PrimitiveDecoder {
    var userInfo: [CodingUserInfoKey : Any] = [:]

    public init() { }

    public func decode<T>(type: T.Type = T.self, value: Any?) throws -> T where T : Decodable {
        try _SingleValueDecodingContainer(value: value, codingPath: [], root: self).decode(type)
    }

    private class _Decoder: Decoder, PrimitiveDecoderProtocol {
        
        required init(value: Any?, codingPath: [CodingKey], root: PrimitiveDecoder) throws {
            self.value = value
            self.codingPath = codingPath
            self.root = root
        }

        let value: Any?

        var codingPath: [CodingKey]

        var userInfo: [CodingUserInfoKey : Any] { root.userInfo }

        unowned let root: PrimitiveDecoder

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            try KeyedDecodingContainer(_KeyedDecodingContainer<Key>(value: value, codingPath: codingPath, root: root))
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            try _UnkeyedDecodingContainer(value: value, codingPath: codingPath, root: root)
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            try _SingleValueDecodingContainer(value: value, codingPath: codingPath, root: root)
        }
    }

    private class _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol, PrimitiveDecoderProtocol {

        required init(value: Any?, codingPath: [CodingKey], root: PrimitiveDecoder) throws {
            guard let value = value as? [String: Any?] else {
                throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, value: value))
            }
            self.value = value
            self.codingPath = codingPath
            self.root = root
        }

        private func decoder<P: PrimitiveDecoderProtocol>(_ type: P.Type, forKey key:  some CodingKey) throws -> P {
            guard let value = value[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, value: value))
            }
            return try P(value: value, codingPath: codingPath + [key], root: root)
        }

        let value: [String: Any?]

        let codingPath: [CodingKey]

        unowned let root: PrimitiveDecoder

        var allKeys: [Key] { value.keys.compactMap(Key.init) }

        func contains(_ key: Key) -> Bool {
            return value[key.stringValue] != nil
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decodeNil()
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        func decode(_ type: Int128.Type, forKey key: Key) throws -> Int128 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        func decode(_ type: UInt128.Type, forKey key: Key) throws -> UInt128 {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            try decoder(_SingleValueDecodingContainer.self, forKey: key).decode(type)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try KeyedDecodingContainer(decoder(_KeyedDecodingContainer<NestedKey>.self, forKey: key))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            try decoder(_UnkeyedDecodingContainer.self, forKey: key)
        }

        func superDecoder() throws -> Decoder {
            try decoder(_Decoder.self, forKey: AnyCodingKey.super)
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            try decoder(_Decoder.self, forKey: key)
        }
    }

    private class _UnkeyedDecodingContainer: UnkeyedDecodingContainer, PrimitiveDecoderProtocol {

        required init(value: Any?, codingPath: [CodingKey], root: PrimitiveDecoder) throws {
            guard let value = value as? [Any] else {
                throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, value: value))
            }
            self.value = value
            self.codingPath = codingPath
            self.root = root
        }

        let value: [Any?]

        let codingPath: [CodingKey]

        unowned let root: PrimitiveDecoder

        var count: Int? { value.count }

        var isAtEnd: Bool { currentIndex >= value.count }

        var currentIndex: Int = 0

        private func decoder<P: PrimitiveDecoderProtocol, T>(_ decoderType: P.Type, _ valueType: T.Type) throws -> P {
            let key = AnyCodingKey.index(currentIndex)
            if isAtEnd {
                throw DecodingError.valueNotFound(T.self, .init(codingPath: codingPath, value: value))
            }
            let value = value[currentIndex]
            currentIndex += 1
            return try P(value: value, codingPath: codingPath + [key], root: root)
        }

        func decodeNil() throws -> Bool {
            try decoder(_SingleValueDecodingContainer.self, Never.self).decodeNil()
        }

        func decode(_ type: Bool.Type) throws -> Bool {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: String.Type) throws -> String {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Double.Type) throws -> Double {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Float.Type) throws -> Float {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Int.Type) throws -> Int {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        func decode(_ type: Int128.Type) throws -> Int128 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        func decode(_ type: UInt128.Type) throws -> UInt128 {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            try decoder(_SingleValueDecodingContainer.self, type).decode(type)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try KeyedDecodingContainer(decoder(_KeyedDecodingContainer<NestedKey>.self, [String: Any].self))
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            try decoder(_UnkeyedDecodingContainer.self, [String].self)
        }

        func superDecoder() throws -> Decoder {
            try decoder(_Decoder.self, Any.self)
        }
    }

    private class _SingleValueDecodingContainer: SingleValueDecodingContainer, PrimitiveDecoderProtocol {

        required init(value: Any?, codingPath: [CodingKey], root: PrimitiveDecoder) throws {
            self.value = value
            self.codingPath = codingPath
            self.root = root
        }

        let value: Any?

        let codingPath: [CodingKey]

        unowned let root: PrimitiveDecoder

        var isConsumed = false

        func decodePrimitive<T>(_ type: T.Type) throws -> T {
            if isConsumed {
                throw DecodingError.valueNotFound(T.self, .init(codingPath: codingPath, value: value))
            }
            isConsumed = true
            guard let value = value as? T else {
                throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, value: value))
            }
            return value
        }

        func decodeNil() -> Bool {
            value == nil
        }

        func decode(_ type: Bool.Type) throws -> Bool {
            try decodePrimitive(type)
        }

        func decode(_ type: String.Type) throws -> String {
            try decodePrimitive(type)
        }

        func decode(_ type: Double.Type) throws -> Double {
            try decodePrimitive(type)
        }

        func decode(_ type: Float.Type) throws -> Float {
            try decodePrimitive(type)
        }

        func decode(_ type: Int.Type) throws -> Int {
            try decodePrimitive(type)
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            try decodePrimitive(type)
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            try decodePrimitive(type)
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            try decodePrimitive(type)
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            try decodePrimitive(type)
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            try decodePrimitive(type)
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decodePrimitive(type)
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decodePrimitive(type)
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decodePrimitive(type)
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decodePrimitive(type)
        }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            if isConsumed {
                throw DecodingError.valueNotFound(T.self, .init(codingPath: codingPath, value: value))
            }
            isConsumed = true
            if let value = value as? T {
                return value
            } else {
                return try T(from: _Decoder(value: value, codingPath: codingPath, root: root))
            }
        }
    }
}

extension DecodingError.Context {
    init<Value>(codingPath: [any CodingKey], line: Int = #line, value: Value) {
        self.init(codingPath: codingPath, debugDescription: "line: \(line) value: \(String(describing:value))")
    }
}
