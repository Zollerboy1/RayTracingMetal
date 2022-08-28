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
    private var time: Float
    private var lightDirection: Vector3
    
    init() {
        self.finalImage = .init(width: 1, height: 1)
        self.imageBuffer = .allocate(capacity: 1)
        self.time = 0
        self.lightDirection = .init(x: 10, y: -5, z: 0).normalized
    }
    
    func onResize(newWidth: Int, newHeight: Int) {
        if self.finalImage.resize(newWidth: newWidth, newHeight: newHeight) {
            self.imageBuffer.deallocate()
            self.imageBuffer = .allocate(capacity: newWidth * newHeight)
        }
    }
    
    func render() {
        let width = self.finalImage.width
        let height = self.finalImage.height
        let aspectRatio = Float(width) / Float(height)
        
        for y in 0..<height {
            for x in 0..<width {
                var coordinates = Vector2(x: Float(x) / Float(width), y: Float(y) / Float(height)) * 2 - 1
                
                coordinates.x *= aspectRatio
                
                let color = self.pixel(for: coordinates)
                
                self.imageBuffer[x + y * width] = .init(fromVector: color)
            }
        }
        
        self.finalImage.setData(UnsafeBufferPointer(self.imageBuffer))
        
        self.time += 0.01
        self.lightDirection = .init(x: cos(self.time) * 10, y: cos(self.time * 2.4) * -10, z: sin(self.time) * -10).normalized
    }
    
    private func pixel(for coordinates: Vector2) -> Vector4 {
        let rayOrigin = Vector3(x: 0, y: 0, z: 1.5)
        let rayDirection = Vector3(coordinates, -1).normalized
        let radius: Float = 0.5
        
        let a: Float = 1
        let b = 2 * rayOrigin.dotProduct(with: rayDirection)
        let c = rayOrigin.lengthSquared - radius * radius
        
        let discriminant = b * b - 4 * a * c
        
        guard discriminant >= 0 else {
            return .init(x: 0, y: 0, z: 0, w: 1)
        }
        
        let t = (-b - discriminant.squareRoot()) / (2 * a)
        let hitPoint = rayOrigin + rayDirection * t
        
        let normal = hitPoint / radius

        let lightAngle = max(normal.dotProduct(with: -self.lightDirection), 0)

        return .init(x: lightAngle, y: 0, z: lightAngle, w: 1)
    }
}
