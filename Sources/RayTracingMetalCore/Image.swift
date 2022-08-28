//
//  Image.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 04.05.22.
//

import ImGui
import Metal

public struct Image {
    private var region: MTLRegion
    private var textureDescriptor: MTLTextureDescriptor
    private var texture: MTLTexture
    
    public var width: Int {
        self.region.size.width
    }
    
    public var height: Int {
        self.region.size.height
    }
    
    public var textureID: CImTextureID {
        Unmanaged<MTLTexture>.passUnretained(self.texture).toOpaque()
    }
    
    public init(width: Int, height: Int, data: UnsafeBufferPointer<ColorRGBA>? = nil) {
        self.region = .init(origin: .init(), size: .init(width: width, height: height, depth: 1))
        
        self.textureDescriptor = MTLTextureDescriptor()
        self.textureDescriptor.width = width
        self.textureDescriptor.height = height
        self.textureDescriptor.pixelFormat = .bgra8Unorm
        
        self.texture = Application.shared.device.makeTexture(descriptor: self.textureDescriptor)!
        
        self.setData(data)
    }
    
    public func setData(_ data: UnsafeBufferPointer<ColorRGBA>?) {
        if let data = data,
           let rawData = UnsafeRawPointer(data.baseAddress) {
            precondition(data.count == width * height)
            
            self.texture.replace(region: self.region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: 4 * self.width)
        }
    }
    
    public mutating func resize(newWidth: Int, newHeight: Int) -> Bool {
        guard newWidth != self.width || newHeight != self.height else {
            return false
        }
        
        
        self.region = .init(origin: .init(), size: .init(width: newWidth, height: newHeight, depth: 1))
        
        self.textureDescriptor = MTLTextureDescriptor()
        self.textureDescriptor.width = newWidth
        self.textureDescriptor.height = newHeight
        self.textureDescriptor.pixelFormat = .bgra8Unorm
        
        self.texture = Application.shared.device.makeTexture(descriptor: self.textureDescriptor)!
        
        return true
    }
}
