import UIKit

class TaskListView: UIView {
    
    weak var delegate: TaskListViewOutput?
    private let defaultCellIdentifier = "DefaultCell"
    private var todoItems: [ToDoItem]
    private let deleteAction: (IndexPath) -> Void
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(Constants.Images.plusCircleFill, for: .normal)
        button.addTarget(self, action: #selector(createNewTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Constants.Colors.Back.primary
        tableView.layer.cornerRadius = 16
        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.dataSource = self
        //tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        tableView.register(NewTableViewCell.self, forCellReuseIdentifier: NewTableViewCell.identifier)
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.estimatedRowHeight = 56
        return tableView
    }()
    
    private lazy var tableHeaderView: HeaderListView = {
        let tableHeaderView = HeaderListView(frame: .zero)
        //tableHeaderView.delegate = self
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        return tableHeaderView
    }()
    
    init(frame: CGRect, todoItems: [ToDoItem], deleteAction: @escaping (IndexPath) -> Void) {
        self.todoItems = todoItems
        self.deleteAction = deleteAction
        super.init(frame: frame)
        setupView()
        print("init items: \(todoItems)")
        //self.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*deinit {
        self.removeGestureRecognizer(tapRecognizer)
    }*/

    @objc private func createNewTask() {
        delegate?.presentNewItem()
    }
    
    func setupView() {
        
        self.addSubview(tableView)
        let tableTop = tableView.topAnchor.constraint(equalTo: self.topAnchor)
        let tableBottom = tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let tableLeading = tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let tableTrailing = tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        self.addSubview(addButton)
        let addBottom = addButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -54)
        let addCenterX = addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        
        NSLayoutConstraint.activate([tableTop, tableBottom, tableLeading, tableTrailing, addBottom, addCenterX])
    }

}

extension TaskListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? tableHeaderView : nil
    }
    
    func isLastCell(at indexPath: IndexPath) -> Bool {
        indexPath.row + 1 == self.tableView(tableView, numberOfRowsInSection: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let suitableCell = isLastCell(at: indexPath) ? newCell(indexPath) : taskCell(indexPath)
        
        guard let cell = suitableCell else { return defaultCell(indexPath) }
        
        return cell
    }
    
    private func taskCell(_ indexPath: IndexPath) -> TaskTableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else { return nil }
        
        let item = todoItems[indexPath.row]
        cell.setCell(with: item)
        return cell
    }
    
    private func defaultCell(_ indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath)
    }
    
    private func newCell(_ indexPath: IndexPath) -> NewTableViewCell? {
            tableView.dequeueReusableCell(withIdentifier: NewTableViewCell.identifier, for: indexPath) as? NewTableViewCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completion) in
            
            self.deleteAction(indexPath)
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = Constants.Colors.Color.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { (_, _, completion) in
            
            completion(true)
        }
        
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = Constants.Colors.Color.green
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let item = isLastCell(at: indexPath) ? nil : todoItems[indexPath.row]
        
        let isLastCell = self.tableView(tableView, numberOfRowsInSection: 0) == indexPath.row + 1
        print("didselect row item\(item?.importance)\n \(todoItems)")
        delegate?.didSelectItem(item, onCellFrame: cell?.frame, indexPath: isLastCell ? nil : indexPath)
    }
}

extension TaskListView: TaskListViewInput {
    
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?) {
        print(#function)
        print("rows:", deletingRow, refreshingRow)
        todoItems = items
        
        if let deletingRow = deletingRow {
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: [deletingRow], with: .fade)
            }
        }

        if let refreshingRow = refreshingRow {
            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: [refreshingRow], with: .fade)
            }
        }

        if deletingRow == nil && refreshingRow == nil {
            print("both nil")
            self.tableView.performBatchUpdates {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
    }
    
//    func reloadData() {
//        tableView.reloadData()
//        print("should load")
//    }
}

//extension TaskListView: /*TaskTableViewCellDelegate,*/ OneTaskViewControllerDelegate { //нужен ли?
//
//
//    func openCurrentTask() {
//        //let oneTaskController = OneTaskViewController()
//        //oneTaskController.delegate = self
//        //present(oneTaskController, animated: true) //нет презента, так как не контроллер
//    }
//}
