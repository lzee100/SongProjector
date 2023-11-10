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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                        Text("Features-explain-standaard-headline")
                            .styleAs(font: .xNormalBold)
                            .padding(.top)
                            .listRowSeparator(.hidden)
                        Text("Features-explain-standaard-content")
                        .styleAs(font: .xNormal)
                        .padding(.bottom)
                } header: {
                    Text("Features-explain-standaard-header")
                        .textCase(nil)
                        .foregroundStyle(.black)
                        .font(.title3)
                        .bold()
                }

                Section {
                    Text("Features-explain-song-headline")
                        .styleAs(font: .xNormalBold)
                        .padding(.top)
                        .listRowSeparator(.hidden)
                    Text("Features-explain-song-content")
                    .styleAs(font: .xNormal)
                    .padding(.bottom)
                } header: {
                    Text("Features-explain-song-header")
                        .textCase(nil)
                        .foregroundStyle(.black)
                        .font(.title3)
                        .bold()
                }

                Section {
                    Text("Features-explain-beam-headline")
                        .styleAs(font: .xNormalBold)
                        .padding(.top)
                        .listRowSeparator(.hidden)
                    Text("Features-explain-beam-content")
                    .styleAs(font: .xNormal)
                    .padding(.bottom)
                } header: {
                    Text("Features-explain-beam-header")
                        .textCase(nil)
                        .foregroundStyle(.black)
                        .font(.title3)
                        .bold()
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
}

#Preview {
    SubscriptionsInformationView()
}
