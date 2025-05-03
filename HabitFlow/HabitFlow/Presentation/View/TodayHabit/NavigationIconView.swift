//
//  NavigationIconView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct NavigationIconView: View {
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            NavigationLink(destination: HabitListView()) {
                Image(systemName: "list.bullet")
            }
            
            NavigationLink(destination: StatisticsOverviewView()) {
                Image(systemName: "chart.bar.xaxis")
            }
            
            NavigationLink(destination: HabitListView()) {
                Image(systemName: "gearshape")
            }
        }
        .foregroundStyle(Color.primaryColor)
        .padding()
    }
}
