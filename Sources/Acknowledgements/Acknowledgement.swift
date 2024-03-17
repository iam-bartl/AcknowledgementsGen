//
//  Acknowledgement.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation

public struct Acknowledgement: Codable, Hashable {
    public init(name: String, location: URL?, license: String?) {
        self.name = name
        self.location = location
        self.license = license
    }
    
    public let name: String
    public let location: URL?
    public let license: String?
}
