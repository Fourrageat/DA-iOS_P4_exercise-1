import SwiftUI

final class ToDoListViewModel: ObservableObject {
    // MARK: - Private properties

    private let repository: ToDoListRepositoryType
    private var toFilterToDoItems: [ToDoItem]
    private var currentFilterIndex: Int = 0

    // MARK: - Init

    init(repository: ToDoListRepositoryType) {
        self.repository = repository
        let loadedToDoItems = repository.loadToDoItems()
        self.toFilterToDoItems = loadedToDoItems
        self.toDoItems = loadedToDoItems
    }

    // MARK: - Outputs

    /// Publisher for the list of to-do items.
    @Published var toDoItems: [ToDoItem] = [] {
        didSet {
            print("apres")
            print(toFilterToDoItems)
            repository.saveToDoItems(toFilterToDoItems)
        }
    }

    // MARK: - Inputs

    // Add a new to-do item with priority and category
    func add(item: ToDoItem) {
        toFilterToDoItems.append(item)
        applyFilter(at: currentFilterIndex)
    }

    /// Toggles the completion status of a to-do item.
    func toggleTodoItemCompletion(_ item: ToDoItem) {
        if let index = toFilterToDoItems.firstIndex(where: { $0.id == item.id }) {
            toFilterToDoItems[index].isDone.toggle()
            applyFilter(at: currentFilterIndex)
        }
    }

    /// Removes a to-do item from the list.
    func removeTodoItem(_ item: ToDoItem) {
        toFilterToDoItems.removeAll { $0.id == item.id }
        applyFilter(at: currentFilterIndex)
    }

    /// Apply the filter to update the list.
    func applyFilter(at filterIndex: Int) {
        currentFilterIndex = filterIndex
        switch filterIndex {
        case 1: // Done
            toDoItems = toFilterToDoItems.filter { $0.isDone }
        case 2: // Not Done
            toDoItems = toFilterToDoItems.filter { !$0.isDone }
        default: // All
            toDoItems = toFilterToDoItems
        }
    }
}
