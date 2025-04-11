//
//  HumanLeagueLandingWireframe.swift
//  CardStock
//
//  Created by Jason Jobe on 4/11/25.
//


import SwiftUI

struct HumanLeagueLandingWireframe: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                // Hero Section
                VStack(spacing: 16) {
                    Text("Protocols for participation. Infrastructure for action.")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("The civic coordination layer communities have been waiting for.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 16) {
                        Button("Join the League") {}
                        Button("See it in Action") {}
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Problem Statement
                VStack(alignment: .leading, spacing: 12) {
                    Text("Civic systems are breaking down. Communities are overwhelmed.")
                        .font(.title2.bold())
                    Text("The tools we rely on for communication and decision-making aren't built for coordination. Fragmented channels, low visibility, and decision paralysis block action when it matters most.")
                }
                .padding(.horizontal)

                // 4C Feature Block
                VStack(alignment: .leading, spacing: 24) {
                    Text("The operating system for civic coordination.")
                        .font(.title2.bold())

                    HStack(alignment: .top, spacing: 24) {
                        VStack(alignment: .leading) {
                            Label("Connect", systemImage: "link")
                            Text("Find aligned neighbors, causes, and teams")
                        }
                        VStack(alignment: .leading) {
                            Label("Communicate", systemImage: "message")
                            Text("Share context, updates, and plans with clarity")
                        }
                        VStack(alignment: .leading) {
                            Label("Collaborate", systemImage: "person.2.fill")
                            Text("Work together asynchronously or in real time")
                        }
                        VStack(alignment: .leading) {
                            Label("Coordinate", systemImage: "arrow.triangle.merge")
                            Text("Move from intent to execution without friction")
                        }
                    }
                    .font(.body)
                }
                .padding(.horizontal)

                // Use Cases
                VStack(alignment: .leading, spacing: 12) {
                    Text("For people who move communities, not just messages.")
                        .font(.title3.bold())
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        Text("Local Resilience Teams")
                        Text("Civic Tech Projects")
                        Text("Mutual Aid Networks")
                        Text("Participatory Budgeting Circles")
                        Text("Disaster Coordination Groups")
                        Text("Policy Hackathons")
                    }
                }
                .padding(.horizontal)

                // Manifesto Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Built on principles that matter.")
                        .font(.title3.bold())
                    Text("Participation is sacred\nCoordination is power\nTransparency builds trust\nLocal is where it starts\nDemocracy is a daily practice")
                        .font(.body)
                    Button("Read the Full Manifesto") {}
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                // Footer CTA
                VStack(spacing: 16) {
                    Text("Join the League. Build the commons.")
                        .font(.title2.bold())
                    Text("We're inviting the first wave of collaborators to shape the civic infrastructure of the future.")
                        .multilineTextAlignment(.center)
                    HStack(spacing: 16) {
                        Button("Sign Up Now") {}
                        Button("Request a Demo") {}
                        Button("View Use Cases") {}
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    HumanLeagueLandingWireframe()
}
