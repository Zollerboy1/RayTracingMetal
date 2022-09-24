//
//  Renderer.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.06.22.
//

import SwiftySIMD
import RayTracingMetalCore

class Renderer {
    private(set) var finalImage: Image
    
    private var imageBuffer: UnsafeMutableBufferPointer<ColorRGBA>
    private var lightDirection: Vector3
    
    init() {
        self.finalImage = .init(width: 1, height: 1)
        self.imageBuffer = .allocate(capacity: 1)
        self.lightDirection = .init(x: 10, y: -5, z: 0).normalized
    }
    
    func onResize(newWidth: Int, newHeight: Int) {
        if self.finalImage.resize(newWidth: newWidth, newHeight: newHeight) {
            self.imageBuffer.deallocate()
            self.imageBuffer = .allocate(capacity: newWidth * newHeight)
        }
    }
    
    func render(withCamera camera: Camera) {
        let rayOrigin = camera.position
        
        let width = self.finalImage.width
        let height = self.finalImage.height
        
        for y in 0..<height {
            for x in 0..<width {
                let rayDirection = camera.rayDirections[x + y * width]
                
                let color = self.trace(ray: .init(origin: rayOrigin, direction: rayDirection))
                
                self.imageBuffer[x + y * width] = .init(fromVector: color)
            }
        }
        
        self.finalImage.setData(UnsafeBufferPointer(self.imageBuffer))
    }
    
    private func trace(ray: Ray) -> Vector4 {
        let radius: Float = 0.5
        
        let a = ray.direction.lengthSquared
        let b = 2 * ray.origin.dotProduct(with: ray.direction)
        let c = ray.origin.lengthSquared - radius * radius
        
        let discriminant = b * b - 4 * a * c
        
        guard discriminant >= 0 else {
            return .init(x: 0, y: 0, z: 0, w: 1)
        }
        
        let t = (-b - discriminant.squareRoot()) / (2 * a)
        let hitPoint = ray.origin + ray.direction * t
        
        let normal = hitPoint / radius

        let lightAngle = max(normal.dotProduct(with: -self.lightDirection), 0)

        return .init(x: lightAngle, y: 0, z: lightAngle, w: 1)
    }
}
