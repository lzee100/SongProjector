//
//  SubscriptionTabView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/08/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import StoreKit

@MainActor class SubscriptionTabViewModel: ObservableObject {
    
    private let subscriptionsManager: SubscriptionsManager
    private let iconsBeam = [Image("Theme-1"), Image("Sheet"), Image("Automatic"), Image("Google-1")].compactMap({ $0 })
    private let iconsSong = [Image("Theme-1"), Image("Sheet"), Image("Automatic"), Image("Music"), Image("Mixer"), Image("Google-1")].compactMap({ $0 })
    @Published var showingLoader = false
    @Published var error: LocalizedError?

    init(subscriptionsManager: SubscriptionsManager) {
        self.subscriptionsManager = subscriptionsManager
    }
    
    func loadProducts() async {
        showingLoader = true
        do {
            try await subscriptionsManager.requestProducts()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error.forcedLocalizedError
        }
    }
    
    func buy(_ product: Product) async -> Bool {
        showingLoader = true
        do {
            let result = try await subscriptionsManager.purchase(product)
            showingLoader = false
            return result != nil
        } catch {
            showingLoader = false
            self.error = error.forcedLocalizedError
            return false
        }
    }
    
    func icons(isSong: Bool) -> [Image] {
        return isSong ? iconsSong : iconsBeam
    }
    
    func description(index: Int, isSong: Bool) -> String {
        if isSong {
            return AppText.Intro.featuresSong[index]
        }
        return AppText.Intro.featuresBeam[index]
    }
}

@MainActor struct SubscriptionTabView: View {
    
    @StateObject private var subscriptionsManager: SubscriptionsManager
    @ObservedObject private var viewModel: SubscriptionTabViewModel
    @Binding private var showingSubscriptions: Bool
    @State private var selectedIndex: Int = 0
    
    init(subscriptionsManager: SubscriptionsManager, showingSubscriptions: Binding<Bool>) {
        self._subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        viewModel = SubscriptionTabViewModel(subscriptionsManager: subscriptionsManager)
        _showingSubscriptions = showingSubscriptions
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    HStack {
                        if subscriptionsManager.subscriptions.count == 0 {
                            ProgressView()
                        } else {
                            ForEach(subscriptionsManager.subscriptions) { subscription in
                                tabView(product: subscription, isSong: subscription.id == "song", size: proxy.size)
                            }
                        }
                    }
                }
                .background(.black)
                .scrollBounceBehavior(.basedOnSize)
                .overlay {
                    if viewModel.showingLoader {
                        Rectangle()
                            .fill(.black.opacity(0.2))
                            .overlay {
                                ProgressView()
                            }
                    }
                }
            }
            .disabled(viewModel.showingLoader)
            .errorAlert(error: $viewModel.error)
            .onAppear {
                Task {
                    await viewModel.loadProducts()
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingSubscriptions = false
                    } label: {
                         Image(systemName: "x.circle")
                            .tint(Color(uiColor: .systemGray4))
                    }

                }
            }
        }
    }
    
    @ViewBuilder private func tabView(product: Product, isSong: Bool, size: CGSize) -> some View {
        VStack {
            VStack {
                Text(AppText.Intro.featureIntro(price: product.displayPrice))
                    .styleAs(font: .xNormal, color: .white)
                ForEach(Array(zip(viewModel.icons(isSong: isSong).indices, viewModel.icons(isSong: isSong))), id: \.0) { (index, icon) in
                    HStack {
                        icon
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: themeHighlighted))
                            .frame(width: 25, height: 25)
                        Text(viewModel.description(index: index, isSong: isSong))
                            .styleAs(font: .xNormal, color: .white)
                        Spacer()
                    }
                }
                Button {
                    Task {
                        let isSuccesfull = await viewModel.buy(product)
                        if isSuccesfull {
                            showingSubscriptions = false
                        }
                    }
                } label: {
                    Text(AppText.Intro.subscribe)
                        .styleAs(font: .xNormal, color: .white)
                        .padding([.leading, .trailing], 40)
                        .padding([.top, .bottom], 10)
                }
                .padding([.top])
                .tint(Color(uiColor: themeHighlighted))
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.showingLoader)
            }
            .padding([.leading, .trailing], 20)
            .padding([.top, .bottom], 40)
            Spacer()
        }
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .padding([.trailing], 20)
        .padding([.leading], product.id == "beam" ? 20 : 0)
        .padding([.top, .bottom], 40)
        .frame(width: size.width - 30)
    }
}
