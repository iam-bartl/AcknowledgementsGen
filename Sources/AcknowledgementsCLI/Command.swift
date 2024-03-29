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
    var inputFile: URL
    
    @Argument(transform: URL.init(fileURLWithPath:))
    var outputFile: URL

    mutating func run() async throws {
        let generator = AcknowledgementsGenerator(input: inputFile, output: outputFile)
        try await generator.run()
    }
}
