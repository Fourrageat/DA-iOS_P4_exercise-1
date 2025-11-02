import SwiftUI

final class ToDoListViewModel: ObservableObject {
    // MARK: - Private properties

    // Data source responsible for loading and saving to-do items.
    private let repository: ToDoListRepositoryType

    // Source of truth for all items, used to apply filters.
    private var sourceToDoItems: [ToDoItem]

    // Currently selected filter index: 0 = All, 1 = Done, 2 = Not Done.
    private var currentFilterIndex: Int = 0

    // MARK: - Init

    // Initializes the view model by loading persisted items from the repository.
    init(repository: ToDoListRepositoryType) {
        self.repository = repository
        let loadedToDoItems = repository.loadToDoItems()
        self.sourceToDoItems = loadedToDoItems
        self.toDoItems = loadedToDoItems
    }

    // MARK: - Outputs

    /// Published list of to-do items reflecting the current filter.
    @Published var toDoItems: [ToDoItem] = [] {
        didSet {
            print("apres")
            print(sourceToDoItems)
            // Persist the full, unfiltered collection whenever items change.
            repository.saveToDoItems(sourceToDoItems)
        }
    }

    // MARK: - Inputs

    /// Adds a new to-do item to the collection, then reapplies the current filter.
    func add(item: ToDoItem) {
        sourceToDoItems.append(item)
        applyFilter(at: currentFilterIndex)
    }

    /// Toggles the completion state of the specified to-do item, then reapplies the current filter.
    func toggleTodoItemCompletion(_ item: ToDoItem) {
        if let index = sourceToDoItems.firstIndex(where: { $0.id == item.id }) {
            sourceToDoItems[index].isDone.toggle()
            applyFilter(at: currentFilterIndex)
        }
    }

    /// Removes the specified to-do item from the collection, then reapplies the current filter.
    func removeTodoItem(_ item: ToDoItem) {
        sourceToDoItems.removeAll { $0.id == item.id }
        applyFilter(at: currentFilterIndex)
    }

    /// Applies the selected filter and updates the published list.
    /// - Parameter filterIndex: 0 = All, 1 = Done, 2 = Not Done.
    func applyFilter(at filterIndex: Int) {
        currentFilterIndex = filterIndex
        switch filterIndex {
        case 1: // Done
            toDoItems = sourceToDoItems.filter { $0.isDone }
        case 2: // Not Done
            toDoItems = sourceToDoItems.filter { !$0.isDone }
        default: // All
            toDoItems = sourceToDoItems
        }
    }
}
