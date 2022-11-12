//
//  Scene.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 24.09.22.
//

class Scene {
    var spheres: [Sphere]
    var materials: [Material]
    
    init() {
        self.spheres = []
        self.materials = []
    }
}
