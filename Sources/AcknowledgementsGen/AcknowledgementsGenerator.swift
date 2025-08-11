//
//  AcknowledgementsGenerator.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation
import Acknowledgements

public struct AcknowledgementsGenerator {
    let input: URL
    let output: URL
    let skipPrivate: Bool
    
    public init(input: URL, output: URL, skipPrivate: Bool) {
        self.input = input
        self.output = output
        self.skipPrivate = skipPrivate
    }
    
    public func run() async throws {
        let data = try Data(contentsOf: input)
        let packages = try ResolvedPackage.decode(data)
        
        var result: [Acknowledgement] = []
        for package in packages {
            guard let repository = package.repository, repository.isGithub == true else {
                if !skipPrivate {
                    result.append(package.acknowledgement())
                }
                continue
            }
            
            let request = repository.licenseRequest
            let response = try await URLSession(configuration: .ephemeral).data(for: request)
            
            guard
                let httpResponse = response.1 as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let license = String(data: response.0, encoding: .utf8)
            else {
                if !skipPrivate {
                    result.append(package.acknowledgement())
                }
                continue
            }
            
            result.append(package.acknowledgement(license))
        }
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let resultData = try encoder.encode(result)
        
        try resultData.write(to: output)
    }
}

private extension URL {
    var isGithub: Bool {
        absoluteString.hasPrefix("https://github.com/")
    }
}

private extension ResolvedPackage {
    func acknowledgement(_ license: String? = nil) -> Acknowledgement {
        .init(name: name,
              location: repository,
              license: license)
    }
}
