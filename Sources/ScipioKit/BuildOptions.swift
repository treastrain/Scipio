import Foundation

struct BuildOptions: Hashable, Codable {
    var tag: String?
    var buildConfiguration: BuildConfiguration
    var isSimulatorSupported: Bool
    var isDebugSymbolsEmbedded: Bool
    var sdks: Set<SDK>
}

public enum BuildConfiguration: Codable {
    case debug
    case release

    var settingsValue: String {
        switch self {
        case .debug: return "Debug"
        case .release: return "Release"
        }
    }
}

enum SDK: Codable {
    case macOS
    case macCatalyst
    case iOS
    case iOSSimulator
    case tvOS
    case tvOSSimulator
    case watchOS
    case watchOSSimulator

    init?(platformName: String) {
        switch platformName {
        case "macos":
            self = .macOS
        case "ios":
            self = .iOS
        case "maccatalyst":
            self = .macCatalyst
        case "tvos":
            self = .tvOS
        case "watchos":
            self = .watchOS
        default:
            return nil
        }
    }

    func extractForSimulators() -> Set<SDK> {
        switch self {
        case .macOS: return [.macOS]
        case .iOS: return [.iOS, .iOSSimulator]
        case .tvOS: return [.tvOS, .tvOSSimulator]
        case .watchOS: return [.watchOS, .watchOSSimulator]
        default: return [self]
        }
    }

    var displayName: String {
        switch self {
        case .macOS:
            return "macOS"
        case .macCatalyst:
            return "Catalyst"
        case .iOS:
            return "iOS"
        case .iOSSimulator:
            return "iPhone Simulator"
        case .watchOS:
            return "watchOS"
        case .watchOSSimulator:
            return "Watch Simulator"
        case .tvOS:
            return "tvOS"
        case .tvOSSimulator:
            return "TV Simulator"
        }
    }

    var name: String {
        switch self {
        case .macOS:
            return "macos"
        case .macCatalyst:
            return "maccatalyst"
        case .iOS:
            return "iphoneos"
        case .iOSSimulator:
            return "iphonesimulator"
        case .tvOS:
            return "appletvos"
        case .tvOSSimulator:
            return "appletvsimulator"
        case .watchOS:
            return "watchos"
        case .watchOSSimulator:
            return "watchsimulator"
        }
    }

    var destination: String {
        switch self {
        case .macOS:
            return "generic/platform=macOS,name=Any Mac"
        case .macCatalyst:
            return "generic/platform=macOS,variant=Mac Catalyst"
        case .iOS:
            return "generic/platform=iOS"
        case .iOSSimulator:
            return "generic/platform=iOS Simulator"
        case .tvOS:
            return "generic/platform=tvOS"
        case .tvOSSimulator:
            return "generic/platform=tvOS Simulator"
        case .watchOS:
            return "generic/platform=watchOS"
        case .watchOSSimulator:
            return "generic/platform=watchOS Simulator"
        }
    }
}
