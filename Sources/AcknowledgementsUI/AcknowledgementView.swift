//
//  AcknowledgementView.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import SwiftUI

import Acknowledgements

struct AcknowledgementView: View {
    let acknowledgement: Acknowledgement
    
    var body: some View {
        ScrollView {
            if let text = acknowledgement.license {
                Text(text).font(.body)
                    .padding()
            }
            
            if let repository = acknowledgement.location {
                Link(destination: repository, label: {
                    Text("GitHub")
                        .font(.subheadline)
                })
            }
        }
        .navigationTitle(acknowledgement.name)
    }
}

#Preview {
    NavigationStack {
        AcknowledgementView(acknowledgement: .init(name: "Test", location: URL(string: "https://github.com"), license: mit))
    }
}

#Preview {
    NavigationStack {
        AcknowledgementView(acknowledgement: .init(name: "Test", location: nil, license: nil))
    }
}
