//
//  XORShift128Plus.swift
//  RayTracingMetalCore
//
// Created by Josef Zoller on 04.05.22.
//

public struct XORShift128Plus: RandomNumberGenerator {
    @usableFromInline
    internal var _state: (UInt64, UInt64)

    @inlinable
    public init() {
        var state0, state1: UInt64
        repeat {
            state0 = UInt64.random(in: .min...(.max))
            state1 = UInt64.random(in: .min...(.max))
        } while state0 == 0 && state1 == 0

        self._state = (state0, state1)
    }

    @inlinable
    public mutating func next() -> UInt64 {
        var x = self._state.0
        let y = self._state.1
        self._state.0 = y
        x ^= x << 23
        self._state.1 = x ^ y ^ (x >> 17) ^ (y >> 26)
        return self._state.1 &+ y
    }
}
