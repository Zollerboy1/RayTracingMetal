//
//  RayTracingMetal.swift
//  RayTracingMetal
//
//  Created by Josef Zoller on 03.05.22.
//

import Dispatch
import ImGui
import RayTracingMetalCore

class ExampleLayer: Layer {
    private var viewportWidth, viewportHeight: Int
    private var lastRenderTime: Double
    private var isRendering: Bool
    private let renderer: Renderer
    private let camera: Camera

    
    init() {
        self.viewportWidth = 0
        self.viewportHeight = 0
        self.lastRenderTime = 0
        self.isRendering = false
        self.renderer = .init()
        self.camera = .init(verticalFOV: 45, nearClip: 0.1, farClip: 100)
    }
    
    
    func onUpdate(timeStep: Duration) {
        self.camera.onUpdate(timeStep: timeStep)
    }
    
    
    func onUIRender() {
        ImGui.begin(withName: "Settings")

        if ImGui.button(withLabel: self.isRendering ? "Stop rendering" : "Start rendering") {
            self.isRendering.toggle()
        }
        
        ImGui.text(format: "Image size: (%d, %d)", self.viewportWidth, self.viewportHeight)
        ImGui.text(format: "Last render time: %.3fms", self.lastRenderTime)
        
        ImGui.end()
        
        
        ImGui.pushStyleVar(withIndex: .windowPadding, value: .init(x: 0, y: 0))
        ImGui.begin(withName: "Viewport")
        
        let viewportSize = ImGui.getContentRegionAvail()
        self.viewportWidth = Int(viewportSize.x)
        self.viewportHeight = Int(viewportSize.y)
        
        let image = self.renderer.finalImage
        ImGui.image(withTextureID: image.textureID, size: .init(x: Float(image.width), y: Float(image.height)), uv0: .init(x: 0, y: 1), uv1: .init(x: 1, y: 0))
        
        ImGui.end()
        ImGui.popStyleVar()
    }
    
    
    func onRenderEnd() {
        guard self.isRendering else { return }

        let startTime = DispatchTime.now().uptimeNanoseconds
        
        self.renderer.onResize(newWidth: self.viewportWidth, newHeight: self.viewportHeight)
        self.camera.onResize(newWidth: self.viewportWidth, newHeight: self.viewportHeight)
        
        self.renderer.render(withCamera: self.camera)
        
        let endTime = DispatchTime.now().uptimeNanoseconds
        self.lastRenderTime = Double(endTime - startTime) / 1_000_000
    }
}

@main
class RayTracingMetal: Application {
    override func initLayers() {
        self.push(layer: ExampleLayer())
    }
    
    override func initMenubar() {
    }
}
