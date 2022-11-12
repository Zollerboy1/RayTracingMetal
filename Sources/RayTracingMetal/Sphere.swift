//
//  Sphere.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 24.09.22.
//

import SwiftySIMD

struct Sphere {
    var center: Vector3
    var radius: Float
    var materialIndex: Int
    
    init(center: Vector3, radius: Float, materialIndex: Int) {
        self.center = center
        self.radius = radius
        self.materialIndex = materialIndex
    }
}
