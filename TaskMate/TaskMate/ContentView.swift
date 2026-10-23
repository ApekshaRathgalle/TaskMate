import SwiftUI

import SwiftData

// MARK: - Task Model

@Model

final class TaskItem {

    var id: UUID

    var title: String

    var category: String

    var priority: String

    var isCompleted: Bool

    var createdAt: Date

    init(

        title: String,

        category: String = "Personal",

        priority: String = "Medium",

        isCompleted: Bool = false

    ) {

        self.id = UUID()

        self.title = title

        self.category = category

        self.priority = priority

        self.isCompleted = isCompleted

        self.createdAt = Date()

    }

}

// MARK: - Main Navigation

struct ContentView: View {

    @State private var selectedTab = 0

    private let blue = Color(

        red: 0.20,

        green: 0.40,

        blue: 0.90

    )

    var body: some View {

        TabView(selection: $selectedTab) {

            HomeView {

                selectedTab = 1

            }

            .tabItem {

                Label("Home", systemImage: "house.fill")

            }

            .tag(0)

            AddTaskView {

                selectedTab = 0

            }

            .tabItem {

                Label("Add Task", systemImage: "plus.circle.fill")

            }

            .tag(1)

            StatisticsView()

                .tabItem {

                    Label("Statistics", systemImage: "chart.bar.fill")

                }

                .tag(2)

            FocusMapView()

                .tabItem {

                    Label("Focus Map", systemImage: "map.fill")

                }

                .tag(3)

        }

        .tint(blue)

        .preferredColorScheme(.light)

    }

}

// MARK: - Home Screen

struct HomeView: View {

    var onAddTask: () -> Void

    @Query(sort: \TaskItem.createdAt, order: .reverse)

    private var tasks: [TaskItem]

    @State private var selectedFilter = "All"
    @State private var taskToEdit: TaskItem?

    @Environment(\.modelContext) private var modelContext

    private let blue = Color(

        red: 0.20,

        green: 0.40,

        blue: 0.90

    )

    private var completedCount: Int {

        tasks.filter { $0.isCompleted }.count

    }

    private var progress: Double {

        guard !tasks.isEmpty else { return 0 }

        return Double(completedCount) / Double(tasks.count)

    }

    private var filteredTasks: [TaskItem] {

        switch selectedFilter {

        case "Active":

            return tasks.filter { !$0.isCompleted }

        case "Completed":

            return tasks.filter { $0.isCompleted }

        default:

            return tasks

        }

    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    // Welcome section

                    VStack(alignment: .leading, spacing: 8) {

                        HStack {

                            Text("TASKMATE")

                                .font(.caption.bold())

                                .tracking(3)

                                .foregroundStyle(blue)

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")

                                .font(.title2)

                                .foregroundStyle(blue)

                        }

                        Text("Stay organised.")

                            .font(.system(size: 32, weight: .bold))

                            .foregroundStyle(.primary)

                        Text("Make today count, one task at a time.")

                            .font(.subheadline)

                            .foregroundStyle(.secondary)

                    }

                    // Progress card

                    VStack(alignment: .leading, spacing: 14) {

                        HStack {

                            VStack(alignment: .leading, spacing: 5) {

                                Text("Your progress")

                                    .font(.headline)

                                Text(

                                    "\(completedCount) of \(tasks.count) tasks completed"

                                )

                                .font(.subheadline)

                                .foregroundStyle(.secondary)

                            }

                            Spacer()

                            Text("\(Int(progress * 100))%")

                                .font(.title2.bold())

                                .foregroundStyle(blue)

                        }

                        ProgressView(value: progress)

                            .tint(blue)

                    }

                    .padding(18)

                    .background(.white)

                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    .overlay {

                        RoundedRectangle(cornerRadius: 20)

                            .stroke(Color.gray.opacity(0.15))

                    }

                    // Task heading

                    HStack {

                        VStack(alignment: .leading, spacing: 4) {

                            Text("My tasks")

                                .font(.title3.bold())

                            Text("A little progress every day.")

                                .font(.subheadline)

                                .foregroundStyle(.secondary)

                        }

                        Spacer()

                        Button(action: onAddTask) {

                            Label("Add task", systemImage: "plus")

                                .font(.subheadline.bold())

                                .foregroundStyle(.white)

                                .padding(.horizontal, 15)

                                .padding(.vertical, 11)

                                .background(blue)

                                .clipShape(Capsule())

                        }

                    }

                    // Task filters

                    HStack(spacing: 8) {

                        ForEach(

                            ["All", "Active", "Completed"],

                            id: \.self

                        ) { filter in

                            Button {

                                selectedFilter = filter

                            } label: {

                                Text(filter)

                                    .font(.subheadline.weight(.semibold))

                                    .frame(maxWidth: .infinity)

                                    .padding(.vertical, 11)

                                    .background(

                                        selectedFilter == filter

                                        ? blue : Color.white

                                    )

                                    .foregroundStyle(

                                        selectedFilter == filter

                                        ? Color.white : Color.secondary

                                    )

                                    .clipShape(Capsule())

                                    .overlay {

                                        Capsule()

                                            .stroke(

                                                Color.gray.opacity(0.15)

                                            )

                                    }

                            }

                            .buttonStyle(.plain)

                        }

                    }

                    // Task list

                    if filteredTasks.isEmpty {

                        VStack(spacing: 10) {

                            Image(systemName: "checklist")

                                .font(.system(size: 38))

                                .foregroundStyle(blue)

                            Text("Nothing here yet")

                                .font(.headline)

                            Text("Add a task and start making progress.")

                                .font(.subheadline)

                                .foregroundStyle(.secondary)

                                .multilineTextAlignment(.center)

                        }

                        .frame(maxWidth: .infinity)

                        .padding(30)

                        .background(.white)

                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    } else {

                        VStack(spacing: 12) {

                            ForEach(filteredTasks) { task in

                                TaskRow(
                                    task: task,
                                    onEdit: { taskToEdit = task },
                                    onDelete: { deleteTask(task) }
                                )

                            }

                        }

                    }

                    // Encouragement card

                    HStack(spacing: 14) {

                        Image(systemName: "sparkles")

                            .font(.title2)

                            .foregroundStyle(blue)

                        VStack(alignment: .leading, spacing: 4) {

                            Text("Keep going!")

                                .font(.headline)

                            Text("Every small step moves you forward.")

                                .font(.caption)

                                .foregroundStyle(.secondary)

                        }

                        Spacer()

                    }

                    .padding(18)

                    .background(blue.opacity(0.09))

                    .clipShape(RoundedRectangle(cornerRadius: 20))

                }

                .padding(20)

            }

            .background(Color(red: 0.95, green: 0.96, blue: 0.99))

            .toolbar(.hidden, for: .navigationBar)

            .sheet(item: $taskToEdit) { task in
                EditTaskView(task: task)
            }

        }

    }

    private func deleteTask(_ task: TaskItem) {
        modelContext.delete(task)
        do {
            try modelContext.save()
        } catch {
            print("Could not delete task: \(error)")
        }
    }

}

// MARK: - Task Row

struct TaskRow: View {

    @Bindable var task: TaskItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var priorityColor: Color {

        switch task.priority {

        case "High": return .red

        case "Medium": return .orange

        default: return .green

        }

    }

    private var categoryIcon: String {

        switch task.category {

        case "Study": return "book"

        case "Work": return "briefcase"

        case "Health": return "heart"

        default: return "person"

        }

    }

    var body: some View {

        HStack(spacing: 12) {

            Button {

                withAnimation(.spring(response: 0.3)) {

                    task.isCompleted.toggle()

                }

            } label: {

                Image(

                    systemName: task.isCompleted

                    ? "checkmark.circle.fill"

                    : "circle"

                )

                .font(.title)

                .foregroundStyle(

                    task.isCompleted

                    ? Color.blue : Color.gray.opacity(0.5)

                )

            }

            .buttonStyle(.plain)

            .accessibilityLabel(

                task.isCompleted

                ? "Mark \(task.title) incomplete"

                : "Complete \(task.title)"

            )

            VStack(alignment: .leading, spacing: 7) {

                Text(task.title)

                    .font(.subheadline.weight(.semibold))

                    .strikethrough(task.isCompleted)

                    .foregroundStyle(

                        task.isCompleted

                        ? Color.secondary : Color.primary

                    )

                Label(task.category, systemImage: categoryIcon)

                    .font(.caption)

                    .foregroundStyle(.secondary)

            }

            Spacer(minLength: 4)

            Text(task.priority)

                .font(.caption.weight(.semibold))

                .foregroundStyle(priorityColor)

                .padding(.horizontal, 10)

                .padding(.vertical, 7)

                .background(priorityColor.opacity(0.10))

                .clipShape(Capsule())

            Menu {
                Button("Edit task", systemImage: "pencil", action: onEdit)
                Button("Delete task", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 36)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Task options")

        }

        .padding(16)

        .background(.white)

        .clipShape(RoundedRectangle(cornerRadius: 18))

        .overlay {

            RoundedRectangle(cornerRadius: 18)

                .stroke(Color.gray.opacity(0.12))

        }

    }

}

// MARK: - Add Task Screen

struct AddTaskView: View {

    var onTaskCreated: () -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var title = ""

    @State private var category = "Personal"

    @State private var priority = "Medium"

    @FocusState private var titleFocused: Bool

    private let blue = Color(

        red: 0.20,

        green: 0.40,

        blue: 0.90

    )

    private let categories = [

        "Personal", "Study", "Work", "Health"

    ]

    private let priorities = ["Low", "Medium", "High"]

    var body: some View {

        NavigationStack {

            Form {

                Section("Task details") {

                    TextField(

                        "What do you need to do?",

                        text: $title

                    )

                    .focused($titleFocused)

                    .submitLabel(.done)

                    Picker("Category", selection: $category) {

                        ForEach(categories, id: \.self) { item in

                            Text(item).tag(item)

                        }

                    }

                    Picker("Priority", selection: $priority) {

                        ForEach(priorities, id: \.self) { item in

                            Text(item).tag(item)

                        }

                    }

                }

                Section {

                    Button(action: saveTask) {

                        HStack {

                            Spacer()

                            Text("Create task")

                                .fontWeight(.semibold)

                            Spacer()

                        }

                    }

                    .listRowBackground(blue)

                    .foregroundStyle(.white)

                    .disabled(

                        title.trimmingCharacters(

                            in: .whitespacesAndNewlines

                        ).isEmpty

                    )

                }

                Section {

                    Label(

                        "Your tasks are saved on this device.",

                        systemImage: "lock.shield"

                    )

                    .font(.caption)

                    .foregroundStyle(.secondary)

                }

            }

            .scrollContentBackground(.hidden)

            .background(Color(red: 0.95, green: 0.96, blue: 0.99))

            .navigationTitle("New task")

            .navigationBarTitleDisplayMode(.inline)

        }

    }

    private func saveTask() {

        let cleanTitle = title.trimmingCharacters(

            in: .whitespacesAndNewlines

        )

        guard !cleanTitle.isEmpty else { return }

        let newTask = TaskItem(

            title: cleanTitle,

            category: category,

            priority: priority

        )

        modelContext.insert(newTask)

        do {

            try modelContext.save()

            title = ""

            category = "Personal"

            priority = "Medium"

            titleFocused = false

            onTaskCreated()

        } catch {

            print("Could not save task: \(error)")

        }

    }

}

// MARK: - Edit Task Screen

struct EditTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: TaskItem

    @State private var title: String
    @State private var category: String
    @State private var priority: String

    private let categories = ["Personal", "Study", "Work", "Health"]
    private let priorities = ["Low", "Medium", "High"]
    private let blue = Color(red: 0.20, green: 0.40, blue: 0.90)

    init(task: TaskItem) {
        self.task = task
        _title = State(initialValue: task.title)
        _category = State(initialValue: task.category)
        _priority = State(initialValue: task.priority)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task details") {
                    TextField("What do you need to do?", text: $title)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                }

                Section {
                    Button(action: saveChanges) {
                        HStack {
                            Spacer()
                            Text("Save changes").fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .listRowBackground(blue)
                    .foregroundStyle(.white)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .tint(blue)
        .preferredColorScheme(.light)
    }

    private func saveChanges() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        task.title = cleanTitle
        task.category = category
        task.priority = priority

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Could not update task: \(error)")
        }
    }
}

// MARK: - Statistics Screen

struct StatisticsView: View {
    @Query(sort: \TaskItem.createdAt, order: .reverse)
    private var tasks: [TaskItem]

    private let blue = Color(red: 0.20, green: 0.40, blue: 0.90)
    private let categories = ["Study", "Work", "Personal", "Health"]
    private let priorities = ["High", "Medium", "Low"]

    private var completed: Int { tasks.filter { $0.isCompleted }.count }
    private var active: Int { tasks.filter { !$0.isCompleted }.count }
    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completed) / Double(tasks.count)
    }

    private func categoryCount(_ category: String) -> Int {
        tasks.filter { $0.category == category }.count
    }

    private func priorityCount(_ priority: String) -> Int {
        tasks.filter { $0.priority == priority }.count
    }

    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your achievements")
                            .font(.title.bold())
                        Text("Small steps add up to big progress.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        StatCard(title: "Total tasks", value: "\(tasks.count)", icon: "list.bullet", color: blue)
                        StatCard(title: "Completed", value: "\(completed)", icon: "checkmark.circle.fill", color: .green)
                    }

                    StatCard(title: "Still in progress", value: "\(active)", icon: "clock", color: .orange)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Completion rate")
                            .font(.headline)
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(blue)
                            Spacer()
                            Text("\(completed) of \(tasks.count) tasks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: progress)
                            .tint(blue)
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Category breakdown
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Tasks by category")
                            .font(.headline)

                        if tasks.isEmpty {
                            Text("Add a task to see your category breakdown.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(categories, id: \.self) { category in
                                let count = categoryCount(category)
                                VStack(spacing: 8) {
                                    HStack {
                                        Label(category, systemImage: categoryIcon(category))
                                            .font(.subheadline.weight(.medium))
                                        Spacer()
                                        Text("\(count)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color.gray.opacity(0.12))
                                            Capsule()
                                                .fill(blue.opacity(category == "Study" ? 1 : category == "Work" ? 0.82 : category == "Personal" ? 0.66 : 0.5))
                                                .frame(width: tasks.isEmpty ? 0 : geometry.size.width * CGFloat(count) / CGFloat(tasks.count))
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Priority breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tasks by priority")
                            .font(.headline)
                        ForEach(priorities, id: \.self) { priority in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(priorityColor(priority))
                                    .frame(width: 10, height: 10)
                                Text(priority)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text("\(priorityCount(priority))")
                                    .font(.subheadline.weight(.semibold))
                                Text(priorityCount(priority) == 1 ? "task" : "tasks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    if tasks.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title2)
                                .foregroundStyle(blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your progress starts here")
                                    .font(.headline)
                                Text("Create your first task to see your statistics update.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(blue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.95, green: 0.96, blue: 0.99))
            .navigationTitle("Statistics")
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "Study": return "book"
        case "Work": return "briefcase"
        case "Health": return "heart"
        default: return "person"
        }
    }
}

// MARK: - Statistics Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 30, weight: .bold))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
