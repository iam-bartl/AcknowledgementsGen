//
//  Command.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation
import ArgumentParser

import AcknowledgementsGen

@main
struct AcknowledgementsCLI: AsyncParsableCommand {
    @Argument(transform: URL.init(fileURLWithPath:))
    var inputFile: URL?
    
    @Argument(transform: URL.init(fileURLWithPath:))
    var outputFile: URL?

    @Option(name: .long, help: "Path to a Package.resolved file; repeat for multiple files.")
    var input: [String] = []

    @Option(name: .long, help: "Path to the generated acknowledgements plist.")
    var output: String?
    
    @Option
    var token: String? = nil
    
    @Flag
    var skipPrivate: Bool = false

    mutating func validate() throws {
        let hasNamedArguments = !input.isEmpty || output != nil
        let hasPositionalArguments = inputFile != nil || outputFile != nil

        if hasNamedArguments && hasPositionalArguments {
            throw ValidationError("Use either --input with --output or positional INPUT OUTPUT, not both.")
        }
        if hasNamedArguments && (input.isEmpty || output == nil) {
            throw ValidationError("The named form requires at least one --input and one --output.")
        }
        if !hasNamedArguments && (inputFile == nil || outputFile == nil) {
            throw ValidationError("Provide INPUT OUTPUT or use --input and --output.")
        }
    }

    mutating func run() async throws {
        let inputs: [URL]
        let destination: URL
        if !input.isEmpty, let output {
            inputs = input.map(URL.init(fileURLWithPath:))
            destination = URL(fileURLWithPath: output)
        } else if let inputFile, let outputFile {
            inputs = [inputFile]
            destination = outputFile
        } else {
            throw ValidationError("Provide INPUT OUTPUT or use --input and --output.")
        }
        let generator = AcknowledgementsGenerator(inputs: inputs, output: destination, skipPrivate: skipPrivate, token: token)
        try await generator.run()
    }
}
