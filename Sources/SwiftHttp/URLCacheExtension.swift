//
//  File.swift
//
//
//  Created by Felix Schindler on 12.06.23.
//

import Foundation

extension URLCache {
    public static func setup() {
        URLCache.shared.memoryCapacity = 20 * 1024 * 1024 // 20 MB
        URLCache.shared.diskCapacity = 100 * 1024 * 1024 // 100 MB
    }
}
