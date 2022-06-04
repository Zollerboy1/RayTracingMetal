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
    private var rng: XORShift128Plus
    private var isRendering: Bool
    private var image: Image?
    private var imageBuffer: UnsafeMutableBufferPointer<UInt32>?

    
    init() {
        self.viewportWidth = 0
        self.viewportHeight = 0
        self.lastRenderTime = 0
        self.rng = .init()
        self.isRendering = false
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
        
        if let image = self.image {
            ImGui.image(withTextureID: image.textureID, size: .init(x: Float(image.width), y: Float(image.height)))
        }
        
        ImGui.end()
        ImGui.popStyleVar()
    }
    
    
    func onRenderEnd() {
        guard self.isRendering else { return }

        let startTime = DispatchTime.now().uptimeNanoseconds
        
        if self.image == nil || self.image?.width != self.viewportWidth || self.image?.width != self.viewportHeight {
            self.image = .init(width: self.viewportWidth, height: self.viewportHeight)
            self.imageBuffer?.deallocate()
            self.imageBuffer = .allocate(capacity: self.viewportWidth * self.viewportHeight)
        }
        
        for i in 0..<(self.viewportWidth * self.viewportHeight) {
            self.imageBuffer?[i] = .random(in: 0xFF000000...0xFFFFFFFF, using: &self.rng)
        }
        
        self.image?.setData(self.imageBuffer.map(UnsafeBufferPointer.init))
        
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
