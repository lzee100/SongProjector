//
//  StickyViewModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
    func sticky(_ stickyRects: [CGRect], alignment: Sticky.Alignment) -> some View {
        modifier(Sticky(alignment: alignment, stickyRects: stickyRects))
    }

}

struct FramePreference: PreferenceKey {
    static var defaultValue: [CGRect] = []
    
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct Sticky: ViewModifier {
    enum Alignment {
        case horizontal
        case vertical
        
        var isVertical: Bool {
            switch self {
            case .horizontal: return false
            case .vertical: return true
            }
        }
    }
    var alignment: Alignment
    var stickyRects: [CGRect]
    @State private var frame: CGRect = .zero
    
    var isSticking: Bool {
        getMinXY() < 0
    }
        
    var offset: CGFloat {
        guard isSticking else { return 0 }
        var o = -getMinXY()
        if let idx = stickyRects.firstIndex(where: { $0.getMinXYFor(alignment) > getMinXY() && $0.getMinXYFor(alignment) < frame.height }) {
            let other = stickyRects[idx]
            o -= frame.height - other.getMinXYFor(alignment)
        }
        return o
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: alignment.isVertical ? 0 : offset, y: alignment.isVertical ? offset : 0)
            .zIndex(isSticking ? .infinity : 0)
            .overlay(GeometryReader { proxy in
                let f = proxy.frame(in: .named("container"))
                Color.clear
                    .onAppear { frame = f }
                    .onChange(of: f) { frame = $0 }
                    .preference(key: FramePreference.self, value: [frame])
            })
    }
    
    private func getMinXY() -> CGFloat {
        switch alignment {
        case .horizontal: return frame.minX
        case .vertical: return frame.minY
        }
    }
    
}

private extension CGRect {
    func getMinXYFor(_ alignment: Sticky.Alignment) -> CGFloat {
        switch alignment {
        case .horizontal: return minX
        case .vertical: return minY
        }
    }
}
