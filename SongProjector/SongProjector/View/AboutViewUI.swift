//
//  AboutViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct AboutViewUI: View {

    @State private var showMessage = false
    private let noEmailMessage: LocalizedStringKey = "AboutController-errorNoMail"

    var body: some View {
        NavigationStack {
            Form {
                Section("AboutController-sectionAbout") {
                    Text("AboutController-infoText")
                        .styleAs(font: .xNormal)
                }
                Section("AboutController-sectionStartContact") {
                    Text("AboutController-contactInfo")
                        .styleAs(font: .xNormal)
                    Button("AboutController-contact") {
                        do {
                            try EmailController.shared.sendEmail(subject: "Contact", body: "")
                        } catch {
                            showMessage.toggle()
                        }
                    }
                }
            }
            .navigationTitle("AboutController-title")
            .alert(noEmailMessage, isPresented: $showMessage) {
                Button(AppText.Actions.ok) { }
            }
        }
    }
}

#Preview {
    AboutViewUI()
}
