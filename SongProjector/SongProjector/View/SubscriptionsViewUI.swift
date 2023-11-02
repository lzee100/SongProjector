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
    @EnvironmentObject var subscriptionsStore: SubscriptionsStore
    @State private var showingInformation = false

    var body: some View {
        NavigationStack {
                Group {
                    if subscriptionsStore.products.isEmpty {
                        ProgressView()
                    } else {
                        SubscriptionStoreView(groupID: "20702484", visibleRelationships: .all)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(AppText.Actions.close)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !subscriptionsStore.products.isEmpty {
                        Button {
                            showingInformation.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SubscriptionsViewUI()
        .environmentObject(SubscriptionsStore())
        .environment(\.locale, .init(identifier: "nl"))
}
