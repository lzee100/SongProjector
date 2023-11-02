//
//  SubscriptionsInformationView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 31/10/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct SubscriptionsInformationView: View {

    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var songFeatures: [(id: Int, key: LocalizedStringKey)] = []
    @State private var beamFeatures: [(id: Int, key: LocalizedStringKey)] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    songView
                    BeamView
                }
            }
            .onAppear {
                songFeatures = (1..<9).map { index in
                    let key = "Intro-featuresSong\(index)"
                    return (index, LocalizedStringKey(key))
                }
                beamFeatures = (1..<7).map { index in
                    let key = "Intro-featuresBeam\(index)"
                    return (index, LocalizedStringKey(key))
                }
            }
            .background(.background.secondary)
            .navigationTitle("Subscriptions-info-title")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(AppText.Actions.close)
                    }

                }
            }
        }
    }

    @ViewBuilder var songView: some View {
        VStack(spacing: 7) {
            Text("Song")
                .styleAs(font: .xLargeBold)
            Text("Feature-song-intro")
                .styleAs(font: .large)
            ForEach(songFeatures, id:\.id) { info in
                HStack {
                    Text("-")
                        .styleAs(font: .xNormal)
                    Text(info.key)
                            .styleAs(font: .xNormal)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background.secondary, in: .rect(cornerSize: CGSize(width: 10, height: 10)))
        .padding()
    }

    @ViewBuilder private var BeamView: some View {
        VStack(spacing: 7) {
            Text("Beam")
                .styleAs(font: .xLargeBold)
            Text("Feature-beam-intro")
                .styleAs(font: .large)
            ForEach(beamFeatures, id:\.id) { info in
                HStack {

                    Text("-")
                        .styleAs(font: .xNormal)
                    Text(info.key)
                        .styleAs(font: .xNormal)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background.secondary, in: .rect(cornerSize: CGSize(width: 10, height: 10)))
        .padding()

    }
}

#Preview {
    SubscriptionsInformationView()
}
