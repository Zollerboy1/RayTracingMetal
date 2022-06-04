//
//  Image.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 04.05.22.
//

import ImGui
import Metal

public struct Image {
    private let region: MTLRegion
    private let textureDescriptor: MTLTextureDescriptor
    private let texture: MTLTexture
    
    public var width: Int {
        self.region.size.width
    }
    
    public var height: Int {
        self.region.size.height
    }
    
    public var textureID: CImTextureID {
        Unmanaged<MTLTexture>.passUnretained(self.texture).toOpaque()
    }
    
    public init(width: Int, height: Int, data: UnsafeBufferPointer<UInt32>? = nil) {
        self.region = .init(origin: .init(), size: .init(width: width, height: height, depth: 1))
        
        self.textureDescriptor = MTLTextureDescriptor()
        self.textureDescriptor.width = width
        self.textureDescriptor.height = height
        self.textureDescriptor.pixelFormat = .bgra8Unorm
        
        self.texture = Application.shared.device.makeTexture(descriptor: self.textureDescriptor)!
        
        self.setData(data)
    }
    
    public func setData(_ data: UnsafeBufferPointer<UInt32>?) {
        if let data = data,
           let rawData = UnsafeRawPointer(data.baseAddress) {
            precondition(data.count == width * height)
            
            self.texture.replace(region: self.region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: 4 * self.width)
        }
    }
}
