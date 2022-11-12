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
}
