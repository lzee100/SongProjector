//
//  OnboardingLoginViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct OnboardingLoginViewUI: View {
    
    @StateObject private var viewModel = GoogleLoginSignOutModel()
    @State private var showingError = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 40) {
                    
                    Text(AppText.Intro.loginWithChurchGoogle)
                        .lineLimit(nil)
                        .padding([.bottom], 3)
                        .padding([.top], 80)
                        .styleAs(font: .xLargeLight, color: .white)
                    
                    GoogleSignInButton(viewModel: viewModel)
                    
            }
            .padding([.leading, .trailing], 50)
        }
        .errorAlert(error: $viewModel.error)
    }
    
}

struct OnboardingLoginViewUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLoginViewUI()
    }
}
