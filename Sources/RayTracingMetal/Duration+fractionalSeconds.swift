//
//  Duration+fractionalSeconds.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 28.08.22.
//

extension Duration {
    var fractionalSeconds: Float {
        Float(Double(self.components.attoseconds / 1_000_000) / 1_000_000_000_000 + Double(self.components.seconds))
    }
}
