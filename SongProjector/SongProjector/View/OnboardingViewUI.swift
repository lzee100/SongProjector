//
//  OnboardingViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct OnboardingViewUI: View {
    var body: some View {
        TabView() {
            OnboardingWelcomeViewUI()
                .tag(1)
            OnboardingLoginViewUI()
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }
}

struct OnboardingViewUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewUI()
    }
}
