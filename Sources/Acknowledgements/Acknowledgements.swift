//
//  Acknowledgements.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation

public extension Acknowledgement {
    static func acknowledgements(path: URL) -> [Acknowledgement] {
        let decoder = PropertyListDecoder()
        guard
            let data = try? Data(contentsOf: path),
            let list = try? decoder.decode([Acknowledgement].self, from: data)
        else { return [] }
        return list
    }
}
