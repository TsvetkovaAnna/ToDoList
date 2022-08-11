

import UIKit
import CocoaLumberjack

protocol TaskListViewInput: AnyObject {
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?)
}

protocol TaskListViewOutput: AnyObject {
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?)
}

final class TaskListViewController: UIViewController {

    let fileCache: FileCache
    private weak var delegate: TaskListViewInput?
    private var lastIndexPath: IndexPath?
    
    private lazy var viewTable: TaskListView = {
        print(fileCache.arrayToDoItems.map({ $0.text}))
        let view = TaskListView(frame: .zero, todoItems: fileCache.arrayToDoItems, deleteAction: { indexPath in
            let item = self.fileCache.arrayToDoItems[indexPath.row]
            self.fileCache.deleteItem(byId: item.id)
            self.delegate?.update(with: self.fileCache.arrayToDoItems, deletingRow: indexPath, refreshingRow: nil)
        })
        delegate = view
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    var doneCount = 0
//    private lazy var doneCountLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Выполнено - " + String(doneCount)
//        label.font = UIFont(name: "SFProText-Regular", size: 15)
//        label.textColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    var shownDoneTasks = false // ? нужно еще?
//    private lazy var showHideDoneTasksButton: UIButton = {
//        let button = UIButton()
//        //button.titleLabel = shownDoneTasks ? "Показать" : "Скрыть"
//        button.setTitle("Показать", for: .normal)
//        button.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 15)
//        button.setTitleColor(.init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
//    private lazy var addButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .clear
//        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .bold))?.withTintColor(UIColor.init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        //print("updating at", lastIndexPath ?? "(no index)")
        DDLogInfo("updating at \(String(describing: lastIndexPath))")
        fileCache.loadData()
        self.delegate?.update(with: self.fileCache.arrayToDoItems, deletingRow: nil, refreshingRow: lastIndexPath)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupView() {
        
        title = "Мои дела"
        view.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        
        view.addSubview(viewTable)
        let tableTop = viewTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let tableBottom = viewTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let tableLeading = viewTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let tableTrailing = viewTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        viewTable.backgroundColor = .clear
        
//        view.addSubview(doneCountLabel)
//        let doneCountLabelTop = doneCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18)
//        //let doneCountLabelBottom = doneCountLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        let doneCountLabelLeading = doneCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32)
//        //let doneCountLabelTrailing = doneCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//
//        view.addSubview(showHideDoneTasksButton)
//        let showHideDoneTasksButtonTop = showHideDoneTasksButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18)
//        let showHideDoneTasksButtonTrailing = showHideDoneTasksButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
//        let showHideDoneTasksButtonHeight = showHideDoneTasksButton.heightAnchor.constraint(equalToConstant: 20)
        
        //view.bringSubviewToFront(addButton)
//        view.addSubview(addButton)
//        let addBottom = addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54)
//        let addCenterX = addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        NSLayoutConstraint.activate([tableTop, tableBottom, tableLeading, tableTrailing/*, doneCountLabelTop, doneCountLabelLeading, showHideDoneTasksButtonTop, showHideDoneTasksButtonTrailing, showHideDoneTasksButtonHeight, addBottom, addCenterX*/])
    }

}

extension TaskListViewController: TaskListViewOutput {
    
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?) {
        let oneTaskController = OneTaskViewController(toDoItem: item)
        lastIndexPath = indexPath
        guard let navigationController = navigationController as? TransitionNavigationController else { return }
        navigationController.sourceFrame = onCellFrame
        navigationController.pushViewController(oneTaskController, animated: true)
    }
    
}
