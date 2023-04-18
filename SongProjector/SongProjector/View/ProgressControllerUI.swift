//
//  UploadViewUI.swift
//  
//
//  Created by Leo van der Zee on 17/04/2023.
//

import SwiftUI

struct ProgressControllerUI: View {
    
    enum Action {
        case uploading
        
        var stringValue: String {
            switch self {
            case .uploading: return AppText.Actions.uploading
            }
        }
    }
    
    @Binding var circleProgress: CGFloat
    @State private var checkProgress: CGFloat = 0
    private let frameSize: CGFloat = 300
    let action: Action
    
    init(circleProgress: Binding<CGFloat>, action: Action) {
        self._circleProgress = circleProgress
        self.action = action
    }
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.6))
            circleView(progress: 1, color: .gray.opacity(0.2))
                .frame(width: frameSize)
            circleView(progress: circleProgress, color: Color(uiColor: .green1))
                .frame(width: frameSize)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        if circleProgress != 1 {
                            Text(action.stringValue)
                                .styleAs(font: .title, color: .white)
                        }
                        checkView(progress: checkProgress)
                            .frame(width: frameSize * 0.5, height: frameSize * 0.5)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .onChange(of: circleProgress) { newValue in
            if newValue == 1 {
                withAnimation(.easeInOut(duration: 0.5).delay(0.3), {
                    checkProgress = 1
                })
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder private func circleView(progress: CGFloat, color: Color) -> some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                style: StrokeStyle(lineWidth: 15, lineCap: .round)
            )
            .foregroundColor(color)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 0.2), value: progress)
    }
    
    @ViewBuilder private func checkView(progress: CGFloat) -> some View {
        CheckLineShape()
            .trim(from: 0, to: progress)
            .stroke(Color(uiColor: .green1), style: StrokeStyle(lineWidth: 15, lineCap: .round))
    }
    
}

struct UploadViewUI_Previews: PreviewProvider {
    @State static var progress: CGFloat = 0.6
    static var previews: some View {
        ProgressControllerUI(circleProgress: $progress, action: .uploading)
    }
}
