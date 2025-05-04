//
//  TodayHabitView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import SwiftUI

struct TodayHabitView: View {
    @StateObject private var viewModel: TodayHabitViewModel
    @StateObject private var habitListViewModel: HabitListViewModel
    
    init(viewModel: TodayHabitViewModel = TodayHabitDIContainer().makeTodayHabitViewModel(),
         habitListViewModel: HabitListViewModel = HabitListDIContainer().makeHabitListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _habitListViewModel = StateObject(wrappedValue: habitListViewModel)
    }
    
    @State private var selectedDate: Date = Date()
    @State private var showingTimer = false
    @State private var selectedHabit: HabitModel?
    @State private var isSheetPresented: Bool = false
    @State private var isDoneList: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    NavigationIconView()
                    
                    WeeklyCalendarView(viewModel: viewModel, selectedDate: $selectedDate)
                        .padding(.bottom, 8)
                    
                    if !helperMessage.isEmpty {
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text(helperMessage[1]).bold()
                                Text(helperMessage[0])
                            }
                            .font(.footnote)
                            .foregroundColor(Color.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.cardBg.opacity(0.1))
                                    .shadow(color: Color.textPrimary.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.top, 8)
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("해야 할 습관 (\(viewModel.todos.count))")
                            .foregroundStyle(Color.textPrimary)
                            .font(.subheadline.bold())
                            .padding()
                        
                        ScrollView {
                            ForEach(viewModel.todos) { habit in
                                HabitCardView(habit: habit, isToday: Calendar.current.isDateInToday(selectedDate)) {
                                    if Calendar.current.isDateInToday(selectedDate) {
                                        if habit.goalMinutes != 0 {
                                            selectedHabit = habit
                                            showingTimer = true
                                        } else {
                                            viewModel.markHabitCompleted(habit)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.todos.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("해야 할 습관이 없어요")
                                    Spacer()
                                }
                                .padding(.top, 16)
                                .font(.title3.bold())
                                .foregroundStyle(Color(.systemGray4))
                            }
                        }
                    }
                    
                    if !viewModel.completed.isEmpty {
                        Button(action: {
                            withAnimation {
                                isDoneList.toggle()
                            }
                        }) {
                            HStack {
                                Text("완료한 습관 (\(viewModel.completed.count))")
                                    .foregroundStyle(Color.textPrimary)
                                Image(systemName: isDoneList ? "chevron.down" : "chevron.up")
                            }
                            .font(.subheadline.bold())
                            .padding()
                        }
                    }
                }
                .onAppear {
                    habitListViewModel.fetchHabits()
                    viewModel.loadHabits(for: selectedDate)
                }
                .onChange(of: selectedDate) { newDate in
                    viewModel.loadHabits(for: newDate)
                    habitListViewModel.fetchHabits()
                }
                
                if !viewModel.completed.isEmpty {
                    CompletionListView(
                        isShown: $isDoneList,
                        dragOffset: $dragOffset,
                        completedHabits: viewModel.completed
                    )
                    .zIndex(1)
                }
                
                Button(action: {
                    isSheetPresented = true
                }) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.textPrimary, radius: 3)
                }
                .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 80)
            }
            .navigationTitle("오늘의 습관")
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3), value: showingTimer)
            .sheet(isPresented: $isSheetPresented) {
                HabitAddEditView(
                    viewModel: habitListViewModel,
                    onSave: {
                        isSheetPresented = false
                        viewModel.loadHabits(for: selectedDate)
                    }
                )
            }
            .fullScreenCover(isPresented: $showingTimer) {
                if let habit = selectedHabit {
                    TimerView(
                        viewModel: TimerViewModel(
                            goalMinutes: habit.goalMinutes ?? 0,
                            onComplete: {
                                viewModel.markHabitCompleted(habit)
                                showingTimer = false
                                selectedHabit = nil
                            }
                        ),
                        showingTimer: $showingTimer,
                        habitTitle: habit.title,
                        category: habit.category
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var helperMessage: [String] {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return []
        } else if selectedDate < calendar.startOfDay(for: Date()) {
            return ["오늘의 습관만 완료할 수 있어요", "지난 날의 습관이에요"]
        } else {
            return ["오늘의 습관만 완료할 수 있어요", "앞으로 해야할 습관이에요"]
        }
    }
}

private struct HabitCardView: View {
    let habit: HabitModel
    var isToday: Bool = false
    var isCompleted: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(habit.category.color)
                
                Text(habit.title)
                    .font(.subheadline.bold())
                    .foregroundColor(isCompleted ? Color("TextSecondary") : Color("TextPrimary"))
                
                Spacer()
                
                if let goal = habit.goalMinutes, goal > 0 {
                    HStack {
                        Text("\(goal)분")
                        Image(systemName: "clock.fill")
                            .padding(-4)
                    }
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color(.systemGray5) : Color.cardBg)
            )
            .opacity(isToday || isCompleted ? 1 : 0.5)
        }
        .disabled(isCompleted || !isToday)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}

private struct CompletionListView: View {
    @Binding var isShown: Bool
    @Binding var dragOffset: CGFloat
    let completedHabits: [HabitModel]
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 80, height: 6)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)
            
            HStack {
                Text("완료한 습관 (\(completedHabits.count))")
                    .font(.subheadline.bold())
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isShown = false
                    }
                }) {
                    Image(systemName: "xmark")
                }
            }
            .foregroundStyle(Color.textPrimary)
            .padding()
            
            Divider()
            
            ScrollView {
                ForEach(completedHabits) { habit in
                    HabitCardView(habit: habit, isCompleted: true)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
            }
            .padding(.top, 16)
        }
        .frame(maxHeight: UIScreen.main.bounds.height)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .offset(y: isShown ? UIScreen.main.bounds.height * 0.2 : UIScreen.main.bounds.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.height > 100 {
                            isShown = false
                        }
                        dragOffset = 0
                    }
                }
        )
        .animation(.easeInOut(duration: 0.3), value: dragOffset)
        .edgesIgnoringSafeArea(.bottom)
    }
}
