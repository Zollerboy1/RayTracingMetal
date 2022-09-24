//
//  MouseButton.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 28.08.22.
//

extension Input {
    public enum MouseButton: Int32 {
        case button0 = 0
        case button1 = 1
        case button2 = 2
        case button3 = 3
        case button4 = 4
        case button5 = 5
        
        public static let left = MouseButton.button0
        public static let right = MouseButton.button1
        public static let middle = MouseButton.button2
    }
}
