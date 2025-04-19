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

enum PrimitiveEncoderError: Error {
    case unimplemented
    case foundNil
}

public class PrimitiveEncoder {
    public enum Encoded {
        case `nil`
        case single(Encodable)
        case keyed([(CodingKey, Self)])
        case unkeyed([Self])
    }

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /// Set of types that should be passed through as-is rather than taken apart and encoded.
    /// All these types will be returned as `Encoded.single` rather than `Encoded.keyed`
    public var primitiveTypes: [Encodable.Type] = []

    public init() { }

    public func encode<T: Encodable>(_ value: T) throws -> Encoded {
        var output: Encoded?
        var container: _SingleValueEncodingContainer? = .init(codingPath: [], root: self) { result in
            output = result
        }
        try container?.encode(value)
        container = nil
        guard let output else {
            throw PrimitiveEncoderError.foundNil
        }
        return output
    }

    private class _BaseContainer {
        required init(codingPath: [any CodingKey], root: PrimitiveEncoder, completion: @escaping (Encoded) -> Void) {
            self.codingPath = codingPath
            self.completion = completion
            self.root = root
        }

        let completion: (_ result: Encoded) -> Void
        unowned let root: PrimitiveEncoder

        var codingPath: [CodingKey] = []

        private var containers: [_BaseContainer] = []

        func constainer<T: _BaseContainer>(_ type: T.Type, key: CodingKey?, completion: @escaping (Encoded) -> Void) -> T {
            let container = T(codingPath: codingPath + (key.map({ [$0] }) ?? []), root: root, completion: completion)
            containers.append(container)
            return container
        }
    }

    private class _Encoder: _BaseContainer, Encoder {
        
        var userInfo: [CodingUserInfoKey : Any] = [:]

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            KeyedEncodingContainer(_KeyedEncodingContainer<Key>(codingPath: codingPath, root: root, completion: completion))
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            _UnkeyedEncodingContainer(codingPath: codingPath, root: root, completion: completion)
        }

        func singleValueContainer() -> any SingleValueEncodingContainer {
            _SingleValueEncodingContainer(codingPath: codingPath, root: root, completion: completion)
        }
    }

    private class _KeyedEncodingContainer<Key: CodingKey>: _BaseContainer, KeyedEncodingContainerProtocol {
        private var result: [(CodingKey, Encoded)] = []

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            if root.primitiveTypes.contains(where: { $0 == T.self }) {
                result.append((key, .single(value)))
            } else {
                let encoder = _Encoder(codingPath: codingPath + [key], root: root) { result in
                    self.result.append((key, result))
                }
                try value.encode(to: encoder)
            }
        }

        func encode(_ value: UInt64, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: UInt32, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: UInt16, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: UInt8, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: UInt, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Int64, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Int32, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Int16, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Int8, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Int, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Float, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Double, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: String, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encode(_ value: Bool, forKey key: Key) throws {
            result.append((key, .single(value)))
        }

        func encodeNil(forKey key: Key) throws {
            result.append((key, .nil))
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            KeyedEncodingContainer(_KeyedEncodingContainer<NestedKey>(codingPath: codingPath + [key], root: root) { result in
                self.result.append((key, result))
            })
        }

        func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            _UnkeyedEncodingContainer(codingPath: codingPath + [key], root: root) { result in
                self.result.append((key, result))
            }
        }

        func superEncoder() -> any Encoder {
            _Encoder(codingPath: codingPath + [AnyCodingKey.super], root: root) { result in
                self.result.append((AnyCodingKey.super, result))
            }
        }

        func superEncoder(forKey key: Key) -> any Encoder {
            _Encoder(codingPath: codingPath + [key], root: root) { result in
                self.result.append((key, result))
            }
        }

        deinit {
            completion(.keyed(result))
        }
    }

    private class _UnkeyedEncodingContainer: _BaseContainer, UnkeyedEncodingContainer {
        var count: Int = 0

        private var result: [Encoded] = []

        func encode<T>(_ value: T) throws where T : Encodable {
            if root.primitiveTypes.contains(where: { $0 == T.self }) {
                result.append(.single(value))
            } else {
                let encoder = _Encoder(codingPath: codingPath, root: root, completion: { self.result.append($0) })
                try value.encode(to: encoder)
            }
        }

        func encode(_ value: UInt64) throws {
            result.append(.single(value))
        }

        func encode(_ value: UInt32) throws {
            result.append(.single(value))
        }

        func encode(_ value: UInt16) throws {
            result.append(.single(value))
        }

        func encode(_ value: UInt8) throws {
            result.append(.single(value))
        }

        func encode(_ value: UInt) throws {
            result.append(.single(value))
        }

        func encode(_ value: Int64) throws {
            result.append(.single(value))
        }

        func encode(_ value: Int32) throws {
            result.append(.single(value))
        }

        func encode(_ value: Int16) throws {
            result.append(.single(value))
        }

        func encode(_ value: Int8) throws {
            result.append(.single(value))
        }

        func encode(_ value: Int) throws {
            result.append(.single(value))
        }

        func encode(_ value: Float) throws {
            result.append(.single(value))
        }

        func encode(_ value: Double) throws {
            result.append(.single(value))
        }

        func encode(_ value: String) throws {
            result.append(.single(value))
        }

        func encode(_ value: Bool) throws {
            result.append(.single(value))
        }

        func encodeNil() throws {
            result.append(.nil)
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            KeyedEncodingContainer(_KeyedEncodingContainer<NestedKey>(codingPath: codingPath + [AnyCodingKey(index: count)], root: root, completion: { self.result.append($0) }))
        }

        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            _UnkeyedEncodingContainer(codingPath: codingPath + [AnyCodingKey(index: count)], root: root, completion: { self.result.append($0) })
        }

        func superEncoder() -> any Encoder {
            _Encoder(codingPath: codingPath + [AnyCodingKey.super], root: root, completion: { self.result.append($0) })
        }

        deinit {
            completion(.unkeyed(result))
        }
    }

    private class _SingleValueEncodingContainer: _BaseContainer, SingleValueEncodingContainer {
        var result: Encoded?

        func encode<T>(_ value: T) throws where T : Encodable {
            if root.primitiveTypes.contains(where: { $0 == T.self }) {
                result = .single(value)
            } else {
                let encoder = _Encoder(codingPath: codingPath, root: root, completion: { self.result = $0 })
                try value.encode(to: encoder)
            }
        }

        func encode(_ value: UInt64) throws {
            result = .single(value)
        }

        func encode(_ value: UInt32) throws {
            result = .single(value)
        }

        func encode(_ value: UInt16) throws {
            result = .single(value)
        }

        func encode(_ value: UInt8) throws {
            result = .single(value)
        }

        func encode(_ value: UInt) throws {
            result = .single(value)
        }

        func encode(_ value: Int64) throws {
            result = .single(value)
        }

        func encode(_ value: Int32) throws {
            result = .single(value)
        }

        func encode(_ value: Int16) throws {
            result = .single(value)
        }

        func encode(_ value: Int8) throws {
            result = .single(value)
        }

        func encode(_ value: Int) throws {
            result = .single(value)
        }

        func encode(_ value: Float) throws {
            result = .single(value)
        }

        func encode(_ value: Double) throws {
            result = .single(value)
        }

        func encode(_ value: String) throws {
            result = .single(value)
        }

        func encode(_ value: Bool) throws {
            result = .single(value)
        }

        func encodeNil() throws {
            result = .nil
        }

        deinit {
            completion(result!)
        }
    }
}
