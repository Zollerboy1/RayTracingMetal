//
//  Vector3+random.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 01.07.23.
//

import SwiftySIMD

extension Vector3 {
    static func randomInUnitSphere(using rng: inout some RandomNumberGenerator) -> Vector3 {
        .random(in: -1...1.0, using: &rng).normalized
    }
}
