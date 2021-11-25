//
//  MainTabsView.swift
//  txmer
//
//  Created by macos sucks balls on 11/25/21.
//

import SwiftUI

@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView: View {
    var body: some View {
        TabView {
            MainTimerView()
                .tabItem {
                    Image(systemName: "stopwatch")
            }
            TimeListView()
                .tabItem {
                    Image(systemName: "hourglass.bottomhalf.filled")
            }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.pie")
            }
            SessionsView()
                .tabItem {
                    Image(systemName: "line.3.horizontal.circle")
            }
            SettingsView()
                .tabItem {
                    Image(systemName: "line.3.horizontal.circle")
            }
        }
    }
}

@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabsView()
    }
}
