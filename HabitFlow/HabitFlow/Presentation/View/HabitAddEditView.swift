//
//  HabitAddEditView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import SwiftUI

struct HabitAddEditView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var selectedCategory: HabitCategory = .healthyIt

    var body: some View {
        NavigationStack {
            Form {
                
                Section(header: Text("습관 제목")) {
                    TextField("예: 걷기 10분", text: $title)
                }

                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("습관 추가")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HabitAddEditView()
}

public enum HabitCategory: String, CaseIterable, Identifiable {
    case healthyIt
    case canDoIt
    case moneyIt
    case greenIt
    case myMindIt

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .healthyIt: return "헬시잇"
        case .canDoIt: return "할수잇"
        case .moneyIt: return "머니잇"
        case .greenIt: return "그린잇"
        case .myMindIt: return "내맘잇"
        }
    }
}
