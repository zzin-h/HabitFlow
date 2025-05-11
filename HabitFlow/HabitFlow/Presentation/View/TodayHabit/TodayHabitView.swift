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
    @StateObject private var notifyViewModel: HabitNotificationViewModel
    @StateObject private var colorSchemeManager = ColorSchemeManager()
    
    init(viewModel: TodayHabitViewModel = TodayHabitDIContainer().makeTodayHabitViewModel(),
         habitListViewModel: HabitListViewModel = HabitListDIContainer().makeHabitListViewModel(),
         notifyViewModel: HabitNotificationViewModel = HabitNotificationDIContainer().makeHabitNotificationViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _habitListViewModel = StateObject(wrappedValue: habitListViewModel)
        _notifyViewModel = StateObject(wrappedValue: notifyViewModel)
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
                        HelperCardView(
                            text1: helperMessage[1],
                            text2: helperMessage[0]
                        )
                    }
                    
                    ToDoListView(viewModel: viewModel, selectedDate: $selectedDate, selectedHabit: $selectedHabit, showingTimer: $showingTimer
                    )
                    
                    if !viewModel.completed.isEmpty {
                        Button(action: {
                            withAnimation {
                                isDoneList.toggle()
                            }
                        }) {
                            HStack {
                                HStack(spacing: 0) {
                                    Text(NSLocalizedString("done_list", comment: "done_list"))
                                    Text(" (\(viewModel.completed.count))")
                                }
                                .foregroundStyle(Color.textPrimary)
                                
                                Image(systemName: "chevron.up")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal)
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
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.textPrimary, radius: 3)
                }
                .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 80)
            }
            .navigationTitle(String(localized: "today_habit_nav_title"))
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3), value: showingTimer)
            .sheet(isPresented: $isSheetPresented) {
                HabitAddEditView(
                    viewModel: habitListViewModel,
                    notifyViewModel: notifyViewModel,
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
        .environmentObject(colorSchemeManager)
        .preferredColorScheme(colorSchemeManager.currentScheme)
    }
    
    private var helperMessage: [String] {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return []
        } else if selectedDate < calendar.startOfDay(for: Date()) {
            return [String(localized: "complete_today_only"),
                    String(localized: "past_day_message")]
        } else {
            return [String(localized: "complete_today_only"),
                    String(localized: "future_day_message")]
        }
    }
}

private struct ToDoListView: View {
    @ObservedObject var viewModel: TodayHabitViewModel
    @Binding var selectedDate: Date
    @Binding var selectedHabit: HabitModel?
    @Binding var showingTimer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                Text(NSLocalizedString("to_do_list", comment: "to_do_list"))
                Text(" (\(viewModel.todos.count))")
            }
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
                        Text(NSLocalizedString("no_habits_to_do", comment: "no_habits_to_do"))
                        Spacer()
                    }
                    .padding(.top, 16)
                    .font(.title3.bold())
                    .foregroundStyle(Color(.systemGray4))
                }
            }
        }
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
                HStack(spacing: 0) {
                    Text(NSLocalizedString("done_list", comment: "done_list"))
                    Text(" (\(completedHabits.count))")
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isShown = false
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .font(.subheadline.bold())
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
            .padding(.vertical, 16)
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.73)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(radius: 3, y: -4)
        .offset(y: isShown ? UIScreen.main.bounds.height * 0.11 : UIScreen.main.bounds.height )
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
                    .lineLimit(1)
                
                Spacer()
                
                if let goal = habit.goalMinutes, goal > 0 {
                    HStack {
                        HStack(spacing: 0) {
                            Text("\(goal)")
                            Text(NSLocalizedString("min", comment: "min"))
                        }
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

private struct HelperCardView: View {
    let text1: String
    let text2: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text(text1)
                    .bold()
                
                Text(text2)
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
}
