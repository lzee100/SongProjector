//
//  AppConfiguration.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/09/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

enum AppConfigurationMode {
  case Debug
  case TestFlight
  case AppStore
}

struct AppConfiguration {
  // This is private because the use of 'appConfiguration' is preferred.
  private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  
  // This can be used to add debug statements.
  static var isDebug: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }

  static var mode: AppConfigurationMode {
    if isDebug {
      return .Debug
    } else if isTestFlight {
      return .TestFlight
    } else {
      return .AppStore
    }
  }
}
