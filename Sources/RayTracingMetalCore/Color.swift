//
//  Color.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 08.05.22.
//

import cRayTracingMetalCore
import SwiftySIMD

public struct ColorRGBA {
    @usableFromInline
    internal let _storage: RGBAStorage
    
    
    @inlinable
    public var red: UInt8 {
        .init(truncatingIfNeeded: self._storage.value >> 16)
    }
    
    @inlinable
    public var green: UInt8 {
        .init(truncatingIfNeeded: self._storage.value >> 8)
    }
    
    @inlinable
    public var blue: UInt8 {
        .init(truncatingIfNeeded: self._storage.value)
    }
    
    @inlinable
    public var alpha: UInt8 {
        .init(truncatingIfNeeded: self._storage.value >> 24)
    }
    
    
    @usableFromInline
    internal init(value: UInt32) {
        self._storage = .init(value: value)
    }
    
    @inlinable
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 0xFF) {
        self.init(value: (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | (UInt32(blue)))
    }
    
    @inlinable
    public init(white: UInt8, alpha: UInt8 = 0xFF) {
        self.init(value: (UInt32(alpha) << 24) | (UInt32(white) << 16) | (UInt32(white) << 8) | (UInt32(white)))
    }
    
    @inlinable
    public init(fromVector vector: Vector4) {
        let clamped = clamp(vector, min: 0, max: 1)
        
        let red = UInt8(clamped.x * 255)
        let green = UInt8(clamped.y * 255)
        let blue = UInt8(clamped.z * 255)
        let alpha = UInt8(clamped.w * 255)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    public static let red =    ColorRGBA(value: 0xFFFF0000)
    public static let green =  ColorRGBA(value: 0xFF00FF00)
    public static let blue =   ColorRGBA(value: 0xFF0000FF)
    public static let yellow = ColorRGBA(value: 0xFFFFFF00)
    public static let cyan =   ColorRGBA(value: 0xFF00FFFF)
    public static let purple = ColorRGBA(value: 0xFFFF00FF)
    public static let white =  ColorRGBA(value: 0xFFFFFFFF)
    public static let black =  ColorRGBA(value: 0xFF000000)
    public static let gray =   ColorRGBA(value: 0xFF808080)
}
