//
//  AcknowledgementsGenerator.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation
import Acknowledgements

public struct AcknowledgementsGenerator {
    let inputs: [URL]
    let output: URL
    let skipPrivate: Bool
    let token: String?
    
    public init(input: URL, output: URL, skipPrivate: Bool, token: String?) {
        self.init(inputs: [input], output: output, skipPrivate: skipPrivate, token: token)
    }

    public init(inputs: [URL], output: URL, skipPrivate: Bool, token: String?) {
        self.inputs = inputs
        self.output = output
        self.skipPrivate = skipPrivate
        self.token = token
    }
    
    public func run() async throws {
        var packages: [ResolvedPackage] = []
        var seen: Set<PackageKey> = []
        for input in inputs {
            let data = try Data(contentsOf: input)
            for package in try ResolvedPackage.decode(data) {
                let key: PackageKey = package.repository.map { .repository($0) } ?? .name(package.name.lowercased())
                if seen.insert(key).inserted {
                    packages.append(package)
                }
            }
        }
        
        var result: [Acknowledgement] = []
        for package in packages {
            guard let repository = package.repository, repository.isGithub == true else {
                if !skipPrivate {
                    result.append(package.acknowledgement())
                }
                continue
            }
            
            let request = repository.licenseRequest(token: token)
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

private enum PackageKey: Hashable {
    case repository(URL)
    case name(String)
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
