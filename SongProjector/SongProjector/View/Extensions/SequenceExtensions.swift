//
//  SequenceExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
    
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    
    
}

extension Sequence {
    func concurrentCompactMap(
        _ operation: @escaping (Element) async throws -> Element
    ) async throws -> [Element] {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        try await withThrowingTaskGroup(of: Element.self) { group in
            for element in self {
                group.addTask {
                    return try await operation(element)
                }
            }
            
            var results: [Element] = []
            for try await (result) in group {
                results.append(result)
            }
            return results

        }
    }
}
