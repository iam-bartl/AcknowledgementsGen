//
//  AcknowledgementsListView.swift
//
//
//  Created by Yauhen Rusanau on 17/03/2024.
//

import SwiftUI

import Acknowledgements

public struct AcknowledgementsListView: View {
    let title: String
    let acknowledgements: [Acknowledgement]
    
    public init(title: String, acknowledgements: [Acknowledgement]) {
        self.title = title
        self.acknowledgements = acknowledgements
    }
    
    public var body: some View {
        List {
            ForEach(acknowledgements, id: \.self) { ack in
                AcknowledgementRowView(acknowledgement: ack)
            }
        }
        .navigationTitle(title)
    }
}

struct AcknowledgementRowView: View {
    let acknowledgement: Acknowledgement
    var body: some View {
        if acknowledgement.license != nil {
            NavigationLink(acknowledgement.name) {
                AcknowledgementView(acknowledgement: acknowledgement)
            }
        } else if let url = acknowledgement.location {
            Link(acknowledgement.name, destination: url)
        } else {
            Text(acknowledgement.name)
        }
    }
}

#Preview {
    AcknowledgementsListView(title: "Acknowledgements", acknowledgements: [
        .init(name: "dep1",
              location: nil,
              license: nil),
        .init(name: "dep2",
              location: nil,
              license: mit),
        .init(name: "dep3",
              location: URL(string: "https://github.com"),
              license: nil)
    ])
}
