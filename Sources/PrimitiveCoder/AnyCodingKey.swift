//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

internal enum AnyCodingKey : CodingKey {
    case string(String)
    case int(Int)
    case index(Int)
    case both(String, Int)
    case `super`

    @inline(__always)
    public init?(stringValue: String) {
        self = .string(stringValue)
    }

    @inline(__always)
    public init?(intValue: Int) {
        self = .int(intValue)
    }

    @inline(__always)
    internal init(index: Int) {
        self = .index(index)
    }

    @inline(__always)
    init(stringValue: String, intValue: Int?) {
        if let intValue {
            self = .both(stringValue, intValue)
        } else {
            self = .string(stringValue)
        }
    }

    var stringValue: String {
        switch self {
        case let .string(str): return str
        case let .int(int): return "\(int)"
        case let .index(index): return "Index \(index)"
        case let .both(str, _): return str
        case .super: return "super"
        }
    }

    var intValue: Int? {
        switch self {
        case .string: return nil
        case let .int(int): return int
        case let .index(index): return index
        case let .both(_, int): return int
        case .super: return nil
        }
    }
}
