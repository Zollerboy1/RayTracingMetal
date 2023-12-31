//
//  Material.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 01.11.22.
//

import SwiftySIMD

struct Material {
    var albedo: Vector3
    var roughness: Float = 1
    var metallic: Float = 0
    var emissionColor: Vector3 = .zero
    var emissionIntensity: Float = 0

    var emission: Vector3 {
        emissionColor * emissionIntensity
    }
}
