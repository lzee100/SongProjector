//
//  Device.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/08/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit
import Foundation

public class SystemInfo {
	
	public static let sharedInstance = SystemInfo()
	
	public lazy var device = Device()
	
	public lazy var debug:Bool = {
		
		#if DEBUG
		return true
		#else
		return false
		#endif
		
	}()
	
	public lazy var sizeClass:IPhoneSizeClass = {
		let screen = UIScreen.main
		var bounds = screen.bounds.size
		let scale = screen.scale
		bounds = CGSize(width: bounds.width * scale, height: bounds.height * scale)
		
		if bounds.width == 320 && bounds.height == 480 {
			return .iPhone1
		}
		if bounds.width == 640 && bounds.height == 960 {
			return .iPhone4
		}
		if bounds.width == 640 && bounds.height == 1136 {
			return .iPhone5
		}
		if bounds.width == 750 && bounds.height == 1334 {
			return .iPhone6
		}
		if bounds.width == 1242 && bounds.height == 2208 {
			return .iPhone6Plus
		}
		if bounds.width == 768 && bounds.height == 1024 {
			return .iPad
		}
		if bounds.width == 1536 && bounds.height == 2048 {
			return .iPad
		}
		return .iPhone6
	}()
	
	private init() { }
	
	public func isOSVersion(_ version:String) -> Bool {
		return UIDevice.current.systemVersion.hasPrefix(version)
	}
	
	public func isOSVersion(_ version:Int) -> Bool {
		return UIDevice.current.systemVersion.hasPrefix("\(version)")
	}
	
	public func isDebugMode() -> ApplicationMode {
		#if DEBUG
		return .debug
		#else
		return .release
		#endif
	}
	
	public var systemName:String {
		return "\(UIDevice.current.name) (\(device.name))"
	}
	
}

public enum ApplicationMode {
	case debug, release
}

public enum IPhoneSizeClass {
	case iPhone1, iPhone4, iPhone5, iPhone6, iPhone6Plus, iPad
}

public enum Device {
	
	case iPodTouch5
	case iPodTouch6
	case iPhone4
	case iPhone4s
	case iPhone5
	case iPhone5c
	case iPhone5s
	case iPhone6
	case iPhone6Plus
	case iPhone6s
	case iPhone6sPlus
	case iPhone7
	case iPhone7Plus
	case iPhoneSE
	case iPhone8
	case iPhone8Plus
	case iPhoneX
	case iPhoneXs
	case iPhoneXr
	case iPhoneXsMax
	
	case iPad2
	case iPad3
	case iPad4
	case iPadAir
	case iPadAir2
	case iPadMini
	case iPadMini2
	case iPadMini3
	case iPadMini4
	
	case iPadPro9Inch
	case iPadPro12Inch
	
	case appleTV4
	
	indirect case simulator(Device)
	case unknown(String)
	
	public var name:String {
		
		switch self {
		case .iPodTouch5:                   return "iPod Touch 5"
		case .iPodTouch6:                   return "iPod Touch 6"
		case .iPhone4:                      return "iPhone 4"
		case .iPhone4s:                     return "iPhone 4s"
		case .iPhone5:                      return "iPhone 5"
		case .iPhone5c:                     return "iPhone 5c"
		case .iPhone5s:                     return "iPhone 5s"
		case .iPhone6:                      return "iPhone 6"
		case .iPhone6Plus:                  return "iPhone 6 Plus"
		case .iPhone6s:                     return "iPhone 6s"
		case .iPhone6sPlus:                 return "iPhone 6s Plus"
		case .iPhone7:                      return "iPhone 7"
		case .iPhone7Plus:                  return "iPhone 7 Plus"
		case .iPhone8:						return "iPhone 8"
		case .iPhone8Plus:					return "iPhone 8 Plus"
		case .iPhoneX:						return "iPhone X"
		case .iPhoneXs:						return "iPhone Xs"
		case .iPhoneXr:						return "iPhone Xr"
		case .iPhoneXsMax:					return "iPhone XMax"
		case .iPhoneSE:                     return "iPhone SE"
		case .iPad2:                        return "iPad 2"
		case .iPad3:                        return "iPad 3"
		case .iPad4:                        return "iPad 4"
		case .iPadAir:                      return "iPad Air"
		case .iPadAir2:                     return "iPad Air 2"
		case .iPadMini:                     return "iPad Mini"
		case .iPadMini2:                    return "iPad Mini 2"
		case .iPadMini3:                    return "iPad Mini 3"
		case .iPadMini4:                    return "iPad Mini 4"
		case .iPadPro9Inch:                 return "iPad Pro (9.7-inch)"
		case .iPadPro12Inch:                return "iPad Pro (12.9-inch)"
		case .simulator(let model):         return "Simulator (\(model))"
		case .unknown(let identifier):      return identifier
		case .appleTV4:                     return "Apple TV 4"
		}
	}
	
	fileprivate init() {
		self = Device.mapToDevice(identifier: Device.identifier)
	}
	
	/// Gets the identifier from the system, such as "iPhone7,1".
	private static var identifier: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let mirror = Mirror(reflecting: systemInfo.machine)
		
		let identifier = mirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		return identifier
	}
	
	private static func mapToDevice(identifier: String) -> Device {
		
		switch identifier {
		case "iPod5,1":                                 return iPodTouch5
		case "iPod7,1":                                 return iPodTouch6
		case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return iPhone4
		case "iPhone4,1":                               return iPhone4s
		case "iPhone5,1", "iPhone5,2":                  return iPhone5
		case "iPhone5,3", "iPhone5,4":                  return iPhone5c
		case "iPhone6,1", "iPhone6,2":                  return iPhone5s
		case "iPhone7,2":                               return iPhone6
		case "iPhone7,1":                               return iPhone6Plus
		case "iPhone8,1":                               return iPhone6s
		case "iPhone8,2":                               return iPhone6sPlus
		case "iPhone9,1", "iPhone9,3":                  return iPhone7
		case "iPhone9,2", "iPhone9,4":                  return iPhone7Plus
		case "iPhone10,1", "iPhone10,4":                return iPhone8
		case "iPhone10,2", "iPhone10,5":                return iPhone8Plus
		case "iPhone10,3", "iPhone10,6":                return iPhoneX
		case "iPhone11,2":                              return iPhoneXs
		case "iPhone11,4", "iPhone11,6":                return iPhoneXsMax
		case "iPhone11,8":                              return iPhoneXr
		case "iPhone8,4":                               return iPhoneSE
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return iPad2
		case "iPad3,1", "iPad3,2", "iPad3,3":           return iPad3
		case "iPad3,4", "iPad3,5", "iPad3,6":           return iPad4
		case "iPad4,1", "iPad4,2", "iPad4,3":           return iPadAir
		case "iPad5,3", "iPad5,4":                      return iPadAir2
		case "iPad2,5", "iPad2,6", "iPad2,7":           return iPadMini
		case "iPad4,4", "iPad4,5", "iPad4,6":           return iPadMini2
		case "iPad4,7", "iPad4,8", "iPad4,9":           return iPadMini3
		case "iPad5,1", "iPad5,2":                      return iPadMini4
		case "iPad6,3", "iPad6,4":                      return iPadPro9Inch
		case "iPad6,7", "iPad6,8":                      return iPadPro12Inch
		case "i386", "x86_64":                          return simulator(mapToDevice(identifier: String(validatingUTF8: getenv("SIMULATOR_MODEL_IDENTIFIER"))!))
		case "AppleTV5,3":                              return appleTV4
		default:                                        return unknown(identifier)
		}
	}
	
	public static var isIphoneX : Bool{
		return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
	}
	
	public static var isIphoneXMax: Bool {
		return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2688 && UIScreen.main.nativeBounds.width == 1242
	}
	
	public static var isIphoneXr: Bool {
		return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 1792 && UIScreen.main.nativeBounds.width == 828
	}
	
	public static var isXtype: Bool {
		return isIphoneX || isIphoneXMax || isIphoneXr
	}
}
