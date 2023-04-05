//
//  OffsetPageView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct OffsetPageView<Content: View>: UIViewRepresentable {
    
    var contentBuilder: (() -> Content)
    @Binding var offset: CGFloat
    @Binding var selectedSong: SongObject?
    @Binding var didScrollWithOffset: CGFloat
    
    func makeCoordinator() -> Coordinator {
        return OffsetPageView.Coordinator(parent: self, offsetChanged: $didScrollWithOffset)
    }
    
    init(offset: Binding<CGFloat>, didScrollWithOffset: Binding<CGFloat>, selectedSong: Binding<SongObject?>, @ViewBuilder contentBuilder: @escaping (() -> Content) ) {
        self.contentBuilder = contentBuilder
        self._selectedSong = selectedSong
        self._offset = offset
        self._didScrollWithOffset = didScrollWithOffset
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        let hostView = UIHostingController(rootView: contentBuilder())
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostView.view)
         
        hostView.view.anchorToSuperView()
        hostView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let currentOffset = uiView.contentOffset.x
        
        let hostView = UIHostingController(rootView: contentBuilder())
        hostView.view.translatesAutoresizingMaskIntoConstraints = false

        uiView.subviews.forEach { $0.removeFromSuperview() }
        uiView.addSubview(hostView.view)
         
        hostView.view.anchorToSuperView()
        hostView.view.heightAnchor.constraint(equalTo: uiView.heightAnchor).isActive = true

        if offset != currentOffset {
            uiView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
        
        
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: OffsetPageView
        @Binding var offsetChanged: CGFloat
        
        init(parent: OffsetPageView, offsetChanged: Binding<CGFloat>) {
            self.parent = parent
            self._offsetChanged = offsetChanged
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            parent.offset = offset
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            offsetChanged = offset
        }
    }

}

struct OffsetPageView_Previews: PreviewProvider {
    @State private static var songService = makeSongService(true)
    static var previews: some View {
        PageViewContentView(selectedSong: $songService.selectedSong, selectedSheet: $songService.selectedSheet)
            .environmentObject(songService)
    }
}
