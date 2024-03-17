//
//  ResolvedPackage.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation

struct ResolvedPackage {
    let name: String
    let repository: URL?
    
    static func decode(_ data: Data) throws -> [ResolvedPackage] {
        let decoder = JSONDecoder()
        if let root = try? decoder.decode(RootV1.self, from: data) {
            let list = root.object.pins.map {
                ResolvedPackage(name: $0.package, repository: URL(string: $0.repositoryURL))
            }
            return list
        }
        
        let root = try decoder.decode(RootV2.self, from: data)
        let list = root.pins.map {
            ResolvedPackage(name: $0.identity, repository: URL(string: $0.location))
        }
        return list
    }
}

private extension ResolvedPackage {
    struct RootV1: Codable {
        let object: ObjectV1
        let version: Int
    }
    
    struct ObjectV1: Codable {
        let pins: [PinV1]
    }
    
    struct PinV1: Codable {
        let package: String
        let repositoryURL: String
    }
    
    struct RootV2: Codable {
        let pins: [PinV2]
        let version: Int
    }
    
    struct PinV2: Codable {
        let identity: String
        let location: String
    }
}
