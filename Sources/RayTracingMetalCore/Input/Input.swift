//
//  Input.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 28.08.22.
//

import GLFW
import SwiftySIMD

public enum Input {
    public static func isKeyDown(withCode keyCode: KeyCode) -> Bool {
        let windowHandle = Application.shared.glfwWindow
        let state = glfwGetKey(windowHandle, keyCode.rawValue)
        return state == GLFW_PRESS || state == GLFW_REPEAT
    }
    
    public static func isMouseButtonDown(_ button: MouseButton) -> Bool {
        let windowHandle = Application.shared.glfwWindow
        let state = glfwGetMouseButton(windowHandle, button.rawValue)
        return state == GLFW_PRESS
    }
    
    public static var mousePosition: Vector2 {
        let windowHandle = Application.shared.glfwWindow
        
        var x = 0.0
        var y = 0.0
        glfwGetCursorPos(windowHandle, &x, &y)
        
        return .init(x: Float(x), y: Float(y))
    }
    
    public static func setCursorMode(to mode: CursorMode) {
        let windowHandle = Application.shared.glfwWindow
        glfwSetInputMode(windowHandle, GLFW_CURSOR, GLFW_CURSOR_NORMAL + mode.rawValue)
    }
}
