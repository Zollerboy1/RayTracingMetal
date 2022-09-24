//
//  Camera.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.08.22.
//

import RayTracingMetalCore
import SwiftySIMD

class Camera {
    private let verticalFOV: Float
    private let nearClip, farClip: Float
    
    internal private(set) var projection, inverseProjection, view, inverseView: simd_float4x4
    internal private(set) var position, direction: Vector3
    
    internal private(set) var rayDirections: [Vector3]
    
    private var lastMousePosition: Vector2
    
    private var viewportWidth, viewportHeight: Int
    
    var rotationSpeed: Float { 0.3 }
    
    
    init(verticalFOV: Float, nearClip: Float, farClip: Float) {
        self.verticalFOV = verticalFOV
        self.nearClip = nearClip
        self.farClip = farClip
        
        self.projection = .init(diagonal: .one)
        self.inverseProjection = .init(diagonal: .one)
        self.view = .init(diagonal: .one)
        self.inverseView = .init(diagonal: .one)
        
        self.position = .init(x: 0, y: 0, z: -1)
        self.direction = .init(x: 0, y: 0, z: 3)
        
        self.rayDirections = []
        
        self.lastMousePosition = .zero
        
        self.viewportWidth = 0
        self.viewportHeight = 0
    }
    
    func onUpdate(timeStep: Duration) {
        let mousePosition = Input.mousePosition
        let mouseDelta = (mousePosition - self.lastMousePosition) * 0.002
        self.lastMousePosition = mousePosition
        
        if !Input.isMouseButtonDown(.right) {
            Input.setCursorMode(to: .normal)
            return
        }
        
        Input.setCursorMode(to: .locked)
        
        var moved = false
        
        let upDirection = Vector3(x: 0, y: 1, z: 0)
        let rightDirection = self.direction.crossProduct(with: upDirection)
        
        let speed: Float = 5
        let ts = timeStep.fractionalSeconds
        
        if Input.isKeyDown(withCode: .w) {
            self.position += self.direction * speed * ts
            moved = true
        } else if Input.isKeyDown(withCode: .s) {
            self.position -= self.direction * speed * ts
            moved = true
        }
        
        if Input.isKeyDown(withCode: .a) {
            self.position -= rightDirection * speed * ts
            moved = true
        } else if Input.isKeyDown(withCode: .d) {
            self.position += rightDirection * speed * ts
            moved = true
        }
        
        if Input.isKeyDown(withCode: .q) {
            self.position -= upDirection * speed * ts
            moved = true
        } else if Input.isKeyDown(withCode: .e) {
            self.position += upDirection * speed * ts
            moved = true
        }
        
        if mouseDelta.x != 0 || mouseDelta.y != 0 {
            let pitchDelta = mouseDelta.y * self.rotationSpeed
            let yawDelta = mouseDelta.x * self.rotationSpeed
            
            let rotation = simd_normalize(simd_mul(simd_quatf(angle: -pitchDelta, axis: rightDirection), simd_quatf(angle: -yawDelta, axis: upDirection)))
            self.direction = rotation.act(self.direction)
            
            moved = true
        }
        
        if moved {
            self.recalculateView()
            self.recalculateRayDirections()
        }
    }
    
    func onResize(newWidth: Int, newHeight: Int) {
        guard newWidth != self.viewportWidth || newHeight != self.viewportHeight else {
            return
        }
        
        self.viewportWidth = newWidth
        self.viewportHeight = newHeight
        
        self.recalculateProjection()
        self.recalculateRayDirections()
    }
    
    
    private func recalculateProjection() {
        self.projection = .perspectiveFOV(fov: self.verticalFOV / 180 * .pi, width: Float(self.viewportWidth), height: Float(self.viewportHeight), zNear: self.nearClip, zFar: self.farClip)
        self.inverseProjection = self.projection.inverse
    }
    
    private func recalculateView() {
        self.view = .lookAt(eye: self.position, center: self.position + self.direction, up: .init(x: 0, y: 1, z: 0))
        self.inverseView = self.view.inverse
    }
    
    private func recalculateRayDirections() {
        self.rayDirections.removeAll(keepingCapacity: true)
        self.rayDirections.reserveCapacity(self.viewportWidth * self.viewportHeight)
        
        for y in 0..<self.viewportHeight {
            for x in 0..<self.viewportWidth {
                var coordinates = Vector2(x: Float(x) / Float(self.viewportWidth), y: Float(y) / Float(self.viewportHeight))
                coordinates = coordinates * 2 - 1
                
                let target = self.inverseProjection * Vector4(coordinates, 1, 1)
                let rayDirection = Vector3(self.inverseView * Vector4((Vector3(target) / target.w).normalized, 0))
                self.rayDirections.append(rayDirection)
            }
        }
    }
}
