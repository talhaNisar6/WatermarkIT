//
//  HomeView.swift
//  WatermarkIT
//
//  Placeholder — full implementation comes in Phase 2

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.purple)

                Text("WatermarkIt")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Phase 1 — Models ready ✓")
                    .foregroundStyle(.secondary)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomeView()
}
