//
//  Renderer.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.06.22.
//

import Foundation
import SwiftySIMD
import RayTracingMetalCore

class Renderer {
    struct Settings {
        var accumulate = true
    }

    private struct HitPayload {
        let hitDistance: Float
        let worldPosition, worldNormal: Vector3

        let objectIndex: Int
    }


    public var settings: Settings

    private(set) var finalImage: Image

    private var activeScene: Scene!
    private var activeCamera: Camera!

    private var imageBuffer: UnsafeMutableBufferPointer<ColorRGBA>
    private var accumulationBuffer: UnsafeMutableBufferPointer<Vector4>

    private var frameIndex: Int

    init() {
        self.finalImage = .init(width: 1, height: 1)
        self.imageBuffer = .allocate(capacity: 1)
        self.accumulationBuffer = .allocate(capacity: 1)
        self.frameIndex = 1

        self.settings = .init()
    }

    func onResize(newWidth: Int, newHeight: Int) {
        if self.finalImage.resize(newWidth: newWidth, newHeight: newHeight) {
            self.imageBuffer.deallocate()
            self.imageBuffer = .allocate(capacity: newWidth * newHeight)

            self.accumulationBuffer.deallocate()
            self.accumulationBuffer = .allocate(capacity: newWidth * newHeight)

            self.frameIndex = 1
        }
    }


    @MainActor
    func render(scene: Scene, withCamera camera: Camera) async {
        self.activeScene = scene
        self.activeCamera = camera

        let width = self.finalImage.width
        let height = self.finalImage.height

        if self.frameIndex == 1 {
            memset(.init(self.accumulationBuffer.baseAddress), 0, width * height * MemoryLayout<Vector4>.size)
        }

//       await withTaskGroup(of: (Int, [Vector4]).self) { group in
//           for y in 0..<height {
//               group.addTask(priority: .userInitiated) {
//                   var rng = XORShift128Plus()
//                   return (y, (0..<width).map { x in self.perPixel(x: x, y: y, using: &rng) })
//               }
//           }
//
//           for await (y, colors) in group {
//               for x in 0..<width {
//                   self.accumulationBuffer[x + y * width] += colors[x]
//
//                   let accumulatedColor = self.accumulationBuffer[x + y * width] / Float(self.frameIndex)
//
//                   self.imageBuffer[x + y * width] = .init(fromVector: accumulatedColor)
//               }
//           }
//       }

        let processors = ProcessInfo.processInfo.processorCount * 2
        let blockSize = height / processors

        let frameIndex = self.frameIndex

        DispatchQueue.concurrentPerform(iterations: processors) { block in
            for y in (block * blockSize)..<min((block + 1) * blockSize, height) {
                var rng = XORShift128Plus(withInitialState: (UInt64(y + 1), UInt64(y * frameIndex + 1)))

                for x in 0..<width {
                    let light = self.perPixel(x: x, y: y, using: &rng)

                    self.accumulationBuffer[x + y * width] += light

                    let accumulatedColor = self.accumulationBuffer[x + y * width] / Float(self.frameIndex)

                    self.imageBuffer[x + y * width] = .init(fromVector: accumulatedColor)
                }
            }
        }

//        var rng = XORShift128Plus()
//
//        for y in 0..<height {
//            for x in 0..<width {
//                let light = self.perPixel(x: x, y: y, using: &rng)
//
//                self.accumulationBuffer[x + y * width] += light
//
//                let accumulatedColor = self.accumulationBuffer[x + y * width] / Float(self.frameIndex)
//
//                self.imageBuffer[x + y * width] = .init(fromVector: accumulatedColor)
//            }
//        }

        self.finalImage.setData(UnsafeBufferPointer(self.imageBuffer))

        if self.settings.accumulate {
            self.frameIndex += 1
        } else {
            self.frameIndex = 1
        }
    }

    func resetFrameIndex() {
        self.frameIndex = 1
    }

    private func perPixel(x: Int, y: Int, using rng: inout some RandomNumberGenerator) -> Vector4 {
        var ray = Ray(
            origin: self.activeCamera.position,
            direction: self.activeCamera.rayDirections[x + y * self.finalImage.width]
        )

        var light = Vector3.zero
        var contribution = Vector3.one

        for _ in 0..<10 {
            guard let payload = self.trace(ray: ray) else {
                break
            }

            let sphere = self.activeScene.spheres[payload.objectIndex]
            let material = self.activeScene.materials[sphere.materialIndex]

            contribution *= material.albedo
            light += material.emission

            ray = .init(
                origin: payload.worldPosition + (payload.worldNormal * 0.0001),
                direction: (payload.worldNormal + .randomInUnitSphere(using: &rng)).normalized
            )
        }

        return .init(light, 1)
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
