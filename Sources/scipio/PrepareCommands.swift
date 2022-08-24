import Foundation
import ScipioKit
import ArgumentParser
import Logging

extension Scipio {
    struct Prepare: AsyncParsableCommand {
        enum CachePolicy: String, CaseIterable, ExpressibleByArgument {
            case disabled
            case project
            case local
        }

        static var configuration: CommandConfiguration = .init(
            abstract: "Prepare all dependencies in a specific manifest."
        )

        @Argument(help: "Path indicates a package directory.",
                  completion: .directory)
        var packageDirectory: URL = URL(fileURLWithPath: ".")

        @Option(name: [.customLong("cache-policy")],
                help: "Cache management policy to reuse built frameworks. (\(CachePolicy.allCases.map(\.rawValue).joined(separator: ","))",
                completion: .list(CachePolicy.allCases.map(\.rawValue)))
        var cachePolicy: CachePolicy = .project

        @Flag(name: .customLong("enable-cache"),
              help: "Whether skip building already built frameworks or not.")
        var cacheEnabled = false

        @OptionGroup var buildOptions: BuildOptionGroup
        @OptionGroup var globalOptions: GlobalOptionGroup
        
        mutating func run() async throws {
            LoggingSystem.bootstrap()

            let runnerCacheMode: Runner.Options.CacheMode
            switch cachePolicy {
            case .disabled:
                runnerCacheMode = .disabled
            case .project:
                runnerCacheMode = .storage(nil)
            case .local:
                runnerCacheMode = .storage(LocalCacheStorage())
            }
            
            let runner = Runner(
                mode: .prepareDependencies,
                options: .init(
                    buildConfiguration: buildOptions.buildConfiguration,
                    isSimulatorSupported: buildOptions.supportSimulators,
                    isDebugSymbolsEmbedded: buildOptions.embedDebugSymbols,
                    cacheMode: runnerCacheMode,
                    verbose: globalOptions.verbose)
            )

            let outputDir: Runner.OutputDirectory
            if let customOutputDir = buildOptions.customOutputDirectory {
                outputDir = .custom(customOutputDir)
            } else {
                outputDir = .default
            }
            
            try await runner.run(packageDirectory: packageDirectory,
                                 frameworkOutputDir: outputDir)
        }
    }
}
