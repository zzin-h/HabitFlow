//
//  HabitListView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitListView: View {
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading) {
                    Text("title")
                        .font(.headline)
                    Text("category")
                        .font(.subheadline)
                }
            }
            .navigationTitle("오늘의 습관")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                HabitAddEditView()
            }
        }
    }
}

#Preview {
    HabitListView()
}
