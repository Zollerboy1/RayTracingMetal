//
//  simd_float4x4+lookAt.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.08.22.
//

import SwiftySIMD

extension simd_float4x4 {
    static func lookAt(eye: Vector3, center: Vector3, up: Vector3) -> simd_float4x4 {
        let f = (center - eye).normalized
        let s = f.crossProduct(with: up).normalized
        let u = s.crossProduct(with: f)

        var result = simd_float4x4(1)
        result[0][0] = s.x
        result[1][0] = s.y
        result[2][0] = s.z
        result[0][1] = u.x
        result[1][1] = u.y
        result[2][1] = u.z
        result[0][2] = -f.x
        result[1][2] = -f.y
        result[2][2] = -f.z
        result[3][0] = -s.dotProduct(with: eye)
        result[3][1] = -u.dotProduct(with: eye)
        result[3][2] = f.dotProduct(with: eye)
        return result
    }
    
    static func perspectiveFOV(fov: Float, width: Float, height: Float, zNear: Float, zFar: Float) -> simd_float4x4 {
        assert(width > 0)
        assert(height > 0)
        assert(fov > 0)

        let rad = fov
        let h = cos(0.5 * rad) / sin(0.5 * rad)
        let w = h * height / width

        var result = simd_float4x4(0)
        result[0][0] = w
        result[1][1] = h
        result[2][2] = (zFar + zNear) / (zFar - zNear)
        result[2][3] = 1
        result[3][2] = -(2 * zFar * zNear) / (zFar - zNear)
        return result
    }
}
