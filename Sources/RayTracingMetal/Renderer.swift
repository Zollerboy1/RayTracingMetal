//
//  Renderer.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.06.22.
//

import SwiftySIMD
import RayTracingMetalCore

class Renderer {
    private struct HitPayload {
        let hitDistance: Float
        let worldPosition, worldNormal: Vector3
        
        let objectIndex: Int
    }
    
    
    private let initialRNGState: (UInt64, UInt64)
    
    
    private(set) var finalImage: Image
    
    private var activeScene: Scene!
    private var activeCamera: Camera!
    
    private var imageBuffer: UnsafeMutableBufferPointer<ColorRGBA>
    private var lightDirection: Vector3
    
    private var rng: XORShift128Plus
    
    init() {
        self.finalImage = .init(width: 1, height: 1)
        self.imageBuffer = .allocate(capacity: 1)
        self.lightDirection = .init(x: 10, y: -5, z: 0).normalized
        
        var state0, state1: UInt64
        repeat {
            state0 = UInt64.random(in: .min...(.max))
            state1 = UInt64.random(in: .min...(.max))
        } while state0 == 0 && state1 == 0

        self.initialRNGState = (state0, state1)
        
        self.rng = .init(withInitialState: self.initialRNGState)
    }
    
    func onResize(newWidth: Int, newHeight: Int) {
        if self.finalImage.resize(newWidth: newWidth, newHeight: newHeight) {
            self.imageBuffer.deallocate()
            self.imageBuffer = .allocate(capacity: newWidth * newHeight)
        }
    }
    
    func render(scene: Scene, withCamera camera: Camera) {
        self.activeScene = scene
        self.activeCamera = camera
        
        //self.rng = .init(withInitialState: self.initialRNGState)
        
        let width = self.finalImage.width
        let height = self.finalImage.height
        
        for y in 0..<height {
            for x in 0..<width {
                let color = self.perPixel(x: x, y: y)
                
                self.imageBuffer[x + y * width] = .init(fromVector: color)
            }
        }
        
        self.finalImage.setData(UnsafeBufferPointer(self.imageBuffer))
    }
    
    private func perPixel(x: Int, y: Int) -> Vector4 {
        var ray = Ray(
            origin: self.activeCamera.position,
            direction: self.activeCamera.rayDirections[x + y * self.finalImage.width]
        )
        
        var color = Vector3.zero
        var multiplier: Float = 1
        
        for _ in 0..<10 {
            guard let payload = self.trace(ray: ray) else {
                let skyColor = Vector3(x: 0.6, y: 0.7, z: 0.9)
                color += skyColor * multiplier
                break
            }
            
            let sphere = self.activeScene.spheres[payload.objectIndex]
            let material = self.activeScene.materials[sphere.materialIndex]

            let lightAngle = max(payload.worldNormal.dotProduct(with: -self.lightDirection), 0)
            
            color += (material.albedo * lightAngle) * multiplier
            multiplier *= 0.5
            
            ray = .init(
                origin: payload.worldPosition + (payload.worldNormal * 0.0001),
                direction: reflect(ray.direction, n: payload.worldNormal + material.roughness * Vector3.random(in: -0.4...0.4, using: &self.rng))
            )
        }
        
        return .init(color, 1)
    }
    
    private func trace(ray: Ray) -> HitPayload? {
        var sphereAndT: (Int, Float)?
        for (i, sphere) in self.activeScene.spheres.enumerated() {
            let origin = ray.origin - sphere.center
            
            let a = ray.direction.lengthSquared
            let b = 2 * origin.dotProduct(with: ray.direction)
            let c = origin.lengthSquared - sphere.radius * sphere.radius
            
            let discriminant = b * b - 4 * a * c
            
            guard discriminant >= 0 else {
                continue
            }
            
            let t = (-b - discriminant.squareRoot()) / (2 * a)
            
            if t > 0 {
                if let oldSphereAndT = sphereAndT {
                    if oldSphereAndT.1 > t {
                        sphereAndT = (i, t)
                    }
                } else {
                    sphereAndT = (i, t)
                }
            }
        }
        
        guard let (sphere, t) = sphereAndT else {
            return nil
        }
        
        return self.closestHit(ray: ray, hitDistance: t, objectIndex: sphere)
    }
    
    private func closestHit(ray: Ray, hitDistance: Float, objectIndex: Int) -> HitPayload {
        let closestSphere = self.activeScene.spheres[objectIndex]
        
        let hitPoint = (ray.origin - closestSphere.center) + ray.direction * hitDistance
        
        let normal = hitPoint / closestSphere.radius

        return .init(
            hitDistance: hitDistance,
            worldPosition: hitPoint + closestSphere.center,
            worldNormal: normal,
            objectIndex: objectIndex
        )
    }
}
