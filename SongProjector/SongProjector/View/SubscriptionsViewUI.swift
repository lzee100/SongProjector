//
//  SubscriptionsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 31/10/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import StoreKit
import SwiftUI

struct SubscriptionsViewUI: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionsStore: SubscriptionsStore
    @State private var showingInformation = false

    var body: some View {
        Group {
            if subscriptionsStore.products.isEmpty {
                ProgressView()
            } else {
                SubscriptionStoreView(groupID: "20702484") {

                    VStack {
                        Spacer()
                        Image("ChurchBeam")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.bottom)
                        Button {
                                showingInformation.toggle()
                            } label: {
                                Text("Meer informatie")
                            }
                        .buttonStyle(.borderless)
                        .padding(.bottom)
                    }
                }
            }
        }
        .background(.background.secondary)
        .task {
            await subscriptionsStore.fetchProducts()
            await subscriptionsStore.fetchActiveTransactions()
        }
        .sheet(isPresented: $showingInformation, content: {
            SubscriptionsInformationView()
        })
    }
}

#Preview {
    SubscriptionsViewUI()
        .environmentObject(SubscriptionsStore())
        .environment(\.locale, .init(identifier: "nl"))
}
