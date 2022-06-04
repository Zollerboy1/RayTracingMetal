//
//  Layer.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 03.05.22.
//

public protocol Layer: AnyObject {
    func onAttach()
    func onDetach()
    func onUIRender()
    func onRenderEnd()
}

extension Layer {
    public func onAttach() {}
    public func onDetach() {}
    public func onUIRender() {}
    public func onRenderEnd() {}
}
