//
//  simd+PointerProvider.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 24.09.22.
//

import ImGui
import SwiftySIMD

extension SIMD2: MutablePointerProvider {
    public var valueCount: Int { 2 }
    
    public func withUnsafePointer<R>(_ body: (UnsafePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafePointer(to: self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 2) {
                try body($0)
            }
        }
    }
    
    public mutating func withUnsafeMutablePointer<R>(_ body: (UnsafeMutablePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafeMutablePointer(to: &self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 2) {
                try body($0)
            }
        }
    }
}

extension SIMD3: MutablePointerProvider {
    public var valueCount: Int { 3 }
    
    public func withUnsafePointer<R>(_ body: (UnsafePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafePointer(to: self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 3) {
                try body($0)
            }
        }
    }
    
    public mutating func withUnsafeMutablePointer<R>(_ body: (UnsafeMutablePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafeMutablePointer(to: &self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 3) {
                try body($0)
            }
        }
    }
}

extension SIMD4: MutablePointerProvider {
    public var valueCount: Int { 4 }
    
    public func withUnsafePointer<R>(_ body: (UnsafePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafePointer(to: self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 4) {
                try body($0)
            }
        }
    }
    
    public mutating func withUnsafeMutablePointer<R>(_ body: (UnsafeMutablePointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafeMutablePointer(to: &self) { pointer in
            try pointer.withMemoryRebound(to: Scalar.self, capacity: 4) {
                try body($0)
            }
        }
    }
}
