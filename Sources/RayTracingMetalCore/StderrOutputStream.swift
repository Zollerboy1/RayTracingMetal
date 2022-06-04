//
//  StderrOutputStream.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 03.05.22.
//

import Foundation

public struct StderrOutputStream: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        
        let stderr = FileHandle.standardError
        if #available(macOS 10.15.4, *) {
            try! stderr.write(contentsOf: data)
        } else {
            stderr.write(data)
        }
    }
}

public var stderrOutputStream = StderrOutputStream()
