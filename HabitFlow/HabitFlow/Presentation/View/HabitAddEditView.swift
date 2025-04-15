//
//  HabitAddEditView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

//import SwiftUI
//
//struct HabitAddEditView: View {
//    @Environment(\.dismiss) var dismiss
//    @ObservedObject var viewModel: HabitViewModel
//
//    @State private var title: String = ""
//    @State private var selectedCategory: HabitCategory = .healthyIt
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("습관 이름")) {
//                    TextField("예: 아침에 물 마시기", text: $title)
//                }
//
//                Section(header: Text("카테고리")) {
//                    Picker("카테고리 선택", selection: $selectedCategory) {
//                        ForEach(HabitCategory.allCases) { category in
//                            Text(category.displayName).tag(category)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("습관 추가")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("저장") {
//                        viewModel.add(title: title, category: selectedCategory)
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("취소") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
