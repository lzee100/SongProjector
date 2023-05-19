//
//  OnboardingWelcomeViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct OnboardingWelcomeViewUI: View {
    var body: some View {
        ZStack {
            Color(uiColor: themeHighlighted).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text(AppText.Intro.introHalloTitle)
                        .padding([.bottom], 3)
                        .padding([.top], 80)
                        .styleAs(font: .title, color: .white)
                    Spacer()
                }
                HStack {
                    Text(AppText.Intro.introHalloContent)
                        .styleAs(font: .xxNormalLight, color: .white)
                    Spacer()
                }
                
            }
            .padding([.leading, .trailing], 50)
        }
    }
}

struct OnboardingWelcomeViewUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWelcomeViewUI()
    }
}
