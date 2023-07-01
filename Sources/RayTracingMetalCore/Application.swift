//
//  Application.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 03.05.22.
//

import Cocoa
import Foundation
import GLFW
import ImGui
import ImGuiImplMetal
import Metal


open class Application {
    public typealias Instant = SuspendingClock.Instant
    
    
    public private(set) static var shared: Application!
    
    
    private static let dockspaceFlags: ImGuiDockNodeFlags = []
    
    public struct Specification {
        let name: String
        let width, height: Int
        
        public init(name: String = "RayTracingMetal", width: Int = 1600, height: Int = 900) {
            self.name = name
            self.width = width
            self.height = height
        }
    }
    
    private enum Error: Swift.Error {
        case imguiVersionMismatch
        case couldNotUploadFont
        case couldNotInitializeGLFW
        case couldNotCreateWindow
        case couldNotCreateDevice
        case couldNotCreateCommandQueue
    }
    
    
    public let specification: Specification
    public let device: MTLDevice
    public private(set) var currentCommandBuffer: MTLCommandBuffer?
    
    private var layers: [Layer]
    private var isRunning: Bool
    
    private var timeStep: Duration
    private var lastFrameTime: Instant
    
    internal let glfwWindow: OpaquePointer
    
    private let commandQueue: MTLCommandQueue
    private let renderPassDescriptor: MTLRenderPassDescriptor
    private let metalLayer: CAMetalLayer
    
    
    public required init(withSpecification specification: Specification = .init()) throws {
        self.specification = specification
        
        self.layers = []
        self.isRunning = false
        
        self.timeStep = .zero
        self.lastFrameTime = .now
        
        
        guard ImGui.checkVersion() else {
            throw Error.imguiVersionMismatch
        }
        
        
        ImGui.createContext()
        let io = ImGui.getIO()
        io[\.ConfigFlags].pointee |= ImGuiConfigFlags.navEnableKeyboard.rawValue
        io[\.ConfigFlags].pointee |= ImGuiConfigFlags.dockingEnable.rawValue
        io[\.ConfigFlags].pointee |= ImGuiConfigFlags.viewportsEnable.rawValue
        
        ImGui.styleColorsDark()
        
        let style = ImGui.getStyle()
        style[\.WindowRounding].pointee = 0
        style[\.Colors.2.w].pointee = 1
        
        guard ig_CImFontAtlas_AddFontFromFileTTF(io[\.Fonts].pointee, Bundle.module.path(forResource: "FiraSans-Regular", ofType: "ttf"), 15, nil, nil) != nil else {
            throw Error.couldNotUploadFont
        }
        
        
        glfwSetErrorCallback { errorCode, description in
            if let description = description.map(String.init(cString:)) {
                print("GLFW Error \(errorCode):", description, to: &stderrOutputStream)
            } else {
                print("GLFW Error \(errorCode)", to: &stderrOutputStream)
            }
        }
        
        if glfwInit() == GLFW_FALSE {
            throw Error.couldNotInitializeGLFW
        }
        
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
        
        guard let glfwWindow = glfwCreateWindow(Int32(specification.width), Int32(specification.height), specification.name, nil, nil) else {
            throw Error.couldNotCreateWindow
        }
        
        self.glfwWindow = glfwWindow
        
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw Error.couldNotCreateDevice
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            throw Error.couldNotCreateCommandQueue
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.renderPassDescriptor = MTLRenderPassDescriptor()
        self.metalLayer = CAMetalLayer()
        
        self.metalLayer.device = self.device
        self.metalLayer.pixelFormat = .bgra8Unorm
        
        
        igImplGLFW_Init(self.glfwWindow, true)
        igImplMetal_Init(self.device)
        
        let nsWindow = glfwGetCocoaWindow(self.glfwWindow) as! NSWindow
        nsWindow.contentView?.layer = self.metalLayer
        nsWindow.contentView?.wantsLayer = true
    }
    
    deinit {
        for layer in self.layers {
            layer.onDetach()
        }
        
        igImplMetal_Shutdown()
        igImplGLFW_Shutdown()
        ImGui.destroyContext()
        
        glfwDestroyWindow(self.glfwWindow)
        glfwTerminate()
    }
    
    
    public func push<L: Layer>(layer: L) {
        self.layers.append(layer)
        layer.onAttach()
    }
    
    
    open func initLayers() {}
    open func initMenubar() {}
    
    
    @MainActor
    public static func main() async throws {
        Self.shared = try Self.init()
        Self.shared.initLayers()
        Self.shared.initMenubar()
        
        await Self.shared.run()
    }
    
    
    @MainActor
    private func run() async {
        self.isRunning = true
        
        while glfwWindowShouldClose(self.glfwWindow) == GLFW_FALSE && self.isRunning {
            glfwPollEvents()
            
            for layer in self.layers {
                layer.onUpdate(timeStep: self.timeStep)
            }
            
            
            var width: Int32 = 0
            var height: Int32 = 0
            glfwGetFramebufferSize(self.glfwWindow, &width, &height)
            self.metalLayer.drawableSize = .init(width: Int(width), height: Int(height))
            
            guard let drawable = self.metalLayer.nextDrawable(),
                  let commandBuffer = self.commandQueue.makeCommandBuffer() else {
                continue
            }

            self.currentCommandBuffer = commandBuffer
            
            self.renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0.45, green: 0.55, blue: 0.6, alpha: 1.0)
            self.renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            self.renderPassDescriptor.colorAttachments[0].loadAction = .clear
            self.renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                commandBuffer.commit()
                self.currentCommandBuffer = nil
                return
            }
            
            renderEncoder.pushDebugGroup(self.specification.name)
            
            
            igImplMetal_NewFrame(self.renderPassDescriptor)
            igImplGLFW_NewFrame()
            ImGui.newFrame()
            
            do {
                var windowFlags = ImGuiWindowFlags.noDocking
                
                let viewport = ImGui.getMainViewport()
                ImGui.setNextWindowPosition(to: viewport[\.Pos].pointee)
                ImGui.setNextWindowSize(to: viewport[\.Size].pointee)
                ImGui.setNextWindowViewport(withID: viewport[\.ID].pointee)
                ImGui.pushStyleVar(withIndex: .windowRounding, value: 0)
                ImGui.pushStyleVar(withIndex: .windowBorderSize, value: 0)
                windowFlags.formUnion([.noTitleBar, .noCollapse, .noResize, .noMove])
                windowFlags.formUnion([.noBringToFrontOnFocus, .noNavFocus])
                
                ImGui.pushStyleVar(withIndex: .windowPadding, value: CImVec2())
                ImGui.begin(withName: "DockSpace", flags: windowFlags)
                ImGui.popStyleVar(count: 3)
                
                let dockspaceID = ImGui.getID(for: "MetalDockSpace")
                ImGui.dockSpace(withID: dockspaceID, size: .init(), flags: Self.dockspaceFlags)
                
                for layer in self.layers {
                    layer.onUIRender()
                }
                
                ImGui.end()
            }
            
            ImGui.render()
            let drawData = ImGui.getDrawData()
            
            igImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder)
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            
            let currentContextBackup = glfwGetCurrentContext()
            ImGui.updatePlatformWindows()
            ImGui.renderPlatformWindowsDefault()
            glfwMakeContextCurrent(currentContextBackup)


            for layer in self.layers {
                await layer.onRenderEnd()
            }

            self.currentCommandBuffer = nil
            
            
            let time = Instant.now
            self.timeStep = self.lastFrameTime.duration(to: time)
            self.lastFrameTime = time
        }
    }
}
