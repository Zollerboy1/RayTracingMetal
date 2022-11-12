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
    private let scene: Scene

    
    init() {
        self.viewportWidth = 0
        self.viewportHeight = 0
        self.lastRenderTime = 0
        self.isRendering = true
        self.renderer = .init()
        self.camera = .init(verticalFOV: 45, nearClip: 0.1, farClip: 100)
        self.scene = .init()
        
        self.scene.materials.append(.init(albedo: .init(x: 1, y: 0, z: 1), roughness: 0))
        self.scene.materials.append(.init(albedo: .init(x: 0.2, y: 0.3, z: 0.8), roughness: 0.2))
        
        self.scene.spheres.append(.init(center: .zero, radius: 1, materialIndex: 0))
        self.scene.spheres.append(.init(center: .init(x: 0, y: -101, z: 0), radius: 100, materialIndex: 1))
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
        
        
        ImGui.begin(withName: "Scene")

        for i in 0..<self.scene.spheres.count {
            ImGui.pushID(i)
            
            ImGui.dragFloat3(withLabel: "Center", values: &self.scene.spheres[i].center, speed: 0.1)
            ImGui.dragFloat(withLabel: "Radius", value: &self.scene.spheres[i].radius, speed: 0.1, minValue: 0.1, maxValue: .infinity)
            
            var materialIndex = Int32(self.scene.spheres[i].materialIndex)
            ImGui.dragInt(withLabel: "Material", value: &materialIndex, minValue: 0, maxValue: Int32(self.scene.materials.count - 1))
            self.scene.spheres[i].materialIndex = Int(materialIndex)
            
            ImGui.separator()
            
            ImGui.popID()
        }
        
        ImGui.spacing()
        
        for i in 0..<self.scene.materials.count {
            ImGui.pushID(i)
            
            ImGui.text(format: "Material %d", i)
            
            ImGui.colorEdit3(withLabel: "Albedo", color: &self.scene.materials[i].albedo)
            ImGui.dragFloat(withLabel: "Roughness", value: &self.scene.materials[i].roughness, speed: 0.01, minValue: 0, maxValue: 1)
            ImGui.dragFloat(withLabel: "Metallicness", value: &self.scene.materials[i].metallic, speed: 0.01, minValue: 0, maxValue: 1)
            
            if i < self.scene.materials.count - 1 {
                ImGui.separator()
            }
            
            ImGui.popID()
        }
        
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
        
        self.renderer.render(scene: self.scene, withCamera: self.camera)
        
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
