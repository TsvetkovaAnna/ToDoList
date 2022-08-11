import UIKit
import CocoaLumberjack

protocol TaskListViewInput: AnyObject {
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?)
}

protocol TaskListViewOutput: AnyObject {
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?)
    func presentNewItem(_ item: ToDoItem?)
}

final class TaskListViewController: UIViewController {

    let fileCache: FileCache
    weak var delegate: TaskListViewInput?
    //private weak var delegate2: TaskListViewReload?
    
    private var lastIndexPath: IndexPath?
    
    private lazy var viewTable: TaskListView = {
        print(fileCache.items.map({ $0.text}))
        let view = TaskListView(frame: .zero, todoItems: fileCache.items, deleteAction: { indexPath in
            let item = self.fileCache.items[indexPath.row]
            self.fileCache.deleteItem(byId: item.id)
            self.delegate?.update(with: self.fileCache.items, deletingRow: indexPath, refreshingRow: nil)
        })
        delegate = view
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        
        DDLogInfo("updating at \(String(describing: lastIndexPath))")
        fileCache.loadData()
        //print("update", lastIndexPath, "\n", self.fileCache.items)
        //self.delegate?.update(with: self.fileCache.items, deletingRow: lastIndexPath, refreshingRow: lastIndexPath)
        self.delegate?.update(with: self.fileCache.items, deletingRow: nil, refreshingRow: lastIndexPath)
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
        
        NSLayoutConstraint.activate([tableTop, tableBottom, tableLeading, tableTrailing])
    }

}

extension TaskListViewController: TaskListViewOutput {
    func presentNewItem(_ item: ToDoItem?) {
        let oneTaskViewController = OneTaskViewController(toDoItem: item)
        let navigationController = UINavigationController(rootViewController: oneTaskViewController)
     
        present(navigationController, animated: true)
    }
    
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?) {
        let oneTaskController = OneTaskViewController(toDoItem: item)
        lastIndexPath = indexPath
        guard let navigationController = navigationController as? TransitionNavigationController else { return }
        navigationController.sourceFrame = onCellFrame
        navigationController.pushViewController(oneTaskController, animated: true)
    }
}

//extension TaskListViewController: OneTaskViewControllerDelegate {
//    func reloadData() {
//        delegate?.reloadData()
//    }
//
//
//}
