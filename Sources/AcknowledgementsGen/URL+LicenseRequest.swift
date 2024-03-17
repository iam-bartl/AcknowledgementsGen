//
//  URL+LicenseRequest.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import Foundation

extension URL {
    var licenseRequest: URLRequest {
        let url  = "https://api.github.com/repos\(pathWithoutExtension)/license"
        var request = URLRequest(url: URL(string: url)!)
        request.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.raw",
            "X-GitHub-Api-Version": "2022-11-28"]
        return request
    }
}

private extension URL {    
    var pathWithoutExtension: String {
        path.replacingOccurrences(of: ".git", with: "")
    }
}
