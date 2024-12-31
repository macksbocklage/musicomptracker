//
//  ContentView.swift
//  musicapp
//
//  Created by Max Bocklage on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                        .environment(\.symbolRenderingMode, .hierarchical)
                        .foregroundColor(.orange)
                    Text("Timer")
                }
            
            SessionHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                        .environment(\.symbolRenderingMode, .hierarchical)
                        .foregroundColor(.orange)
                    Text("History")
                }
        }
        .tint(.orange)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = .orange
        }
    }
}

#Preview {
    ContentView()
}
