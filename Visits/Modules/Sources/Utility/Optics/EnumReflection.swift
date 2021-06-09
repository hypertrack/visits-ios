// MIT License
//
// Copyright (c) 2020 Point-Free, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import func Foundation.memcmp

public extension Prism where S == T, A == B {
  static func `case`(_ embed: @escaping (Value) -> Root) -> Prism<Root, Value> {
    let extract: ((Value) -> Root, Root) -> Value? = extract(case:from:)
    return self.init(
      extract: { extract(embed, $0) },
      embed: embed
    )
  }
}

public extension Prism where S == T, A == B, Value == Void {
  static func `case`(_ value: Root) -> Prism<Root, Value> {
    Prism(
      extract: { "\($0)" == "\(value)" ? () : nil },
      embed: { value }
    )
  }
}

public func extract<Root, Value>(
  case embed: (Value) -> Root,
  from root: Root
) -> Value? {
  func extractHelp(from root: Root) -> ([String?], Value)? {
    if let value = root as? Value {
      var otherRoot = embed(value)
      var root = root
      if memcmp(&root, &otherRoot, MemoryLayout<Root>.size) == 0 {
        return ([], value)
      }
    }
    var path: [String?] = []
    var any: Any = root

    while case let (label?, anyChild)? = Mirror(reflecting: any).children.first {
      path.append(label)
      path.append(String(describing: type(of: anyChild)))
      if let child = anyChild as? Value {
        return (path, child)
      }
      any = anyChild
    }
    if MemoryLayout<Value>.size == 0, !isUninhabitedEnum(Value.self) {
      return (["\(root)"], unsafeBitCast((), to: Value.self))
    }
    return nil
  }
  if let (rootPath, child) = extractHelp(from: root),
    let (otherPath, _) = extractHelp(from: embed(child)),
    rootPath == otherPath {
    return child
  }
  return nil
}

public func extract<Root, Value>(
  _ case: @escaping (Value) -> Root
) -> (Root) -> (Value?) {
  { root in
    extract(case: `case`, from: root)
  }
}

// MARK: - Private Helpers
private struct EnumMetadata {
  let kind: Int
  let typeDescriptor: UnsafePointer<EnumTypeDescriptor>
}

private struct EnumTypeDescriptor {
  // These fields are not modeled because we don't need them.
  // They are the type descriptor flags and various pointer offsets.
  let flags, p1, p2, p3, p4: Int32
  
  let numPayloadCasesAndPayloadSizeOffset: Int32
  let numEmptyCases: Int32
  
  var numPayloadCases: Int32 {
    numPayloadCasesAndPayloadSizeOffset & 0xFFFFFF
  }
}

private func isUninhabitedEnum(_ type: Any.Type) -> Bool {
    // Load the type kind from the common type metadata area. Memory layout reference:
    // https://github.com/apple/swift/blob/master/docs/ABI/TypeMetadata.rst
    let metadataPtr = unsafeBitCast(type, to: UnsafeRawPointer.self)
    let metadataKind = metadataPtr.load(as: Int.self)
    
    // Check that this is an enum. Value reference:
    // https://github.com/apple/swift/blob/master/stdlib/public/core/ReflectionMirror.swift
    let isEnum = metadataKind == 0x201
    guard isEnum else { return false }
    
    // Access enum type descriptor
    let enumMetadata = metadataPtr.load(as: EnumMetadata.self)
    let enumTypeDescriptor = enumMetadata.typeDescriptor.pointee
    
    let numCases = enumTypeDescriptor.numPayloadCases + enumTypeDescriptor.numEmptyCases
    return numCases == 0
}
