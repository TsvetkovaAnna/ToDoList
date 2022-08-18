import UIKit
import CocoaLumberjack

protocol TaskListViewInput: AnyObject {
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?)
}

protocol TaskListViewOutput: AnyObject {
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?)
    func presentNewItem()
    func changeIsDone(_ indexPath: IndexPath?)
}

final class TaskListViewController: UIViewController {

    let fileCache: FileCache
    weak var delegate: TaskListViewInput?
    //private weak var delegate2: TaskListViewReload?
    
    private var lastIndexPath: IndexPath?
    
    var appDelegate: AppDelegate? {
        UIApplication().delegate as? AppDelegate
    }
    
    private lazy var viewTable: TaskListView = {
        
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

//        guard let appDelegate = appDelegate else { return }
//        appDelegate.application?(<#T##application: UIApplication##UIApplication#>, supportedInterfaceOrientationsFor: <#T##UIWindow?#>)
//        appDelegate.orientationMask = .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // updateTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func updateTableView(_ type: UpdateType) {
        
        fileCache.loadData()
        
        switch type {
        case .refresh:
            delegate?.update(with: fileCache.items, deletingRow: nil, refreshingRow: lastIndexPath)
        case .remove:
            delegate?.update(with: fileCache.items, deletingRow: lastIndexPath, refreshingRow: nil)
        }
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

extension TaskListViewController: TaskListViewOutput, OneTaskViewControllerDelegate {
    
    enum UpdateType {
        case refresh
        case remove
    }
    
    func changeIsDone(_ indexPath: IndexPath?) {
        guard let row = indexPath?.row else { return }
        
        let revertedItem = fileCache.items[row].reverted
        fileCache.refreshItem(revertedItem, byId: revertedItem.id)
        
        //fileCache.items.remove(at: row)
        //fileCache.items.insert(fileCache.items[row].reverted, at: row)
        
        updateTableView(.refresh)
    }
    
    func updateTableViewDeletingRow() {
        updateTableView(.remove)
    }
    
    func willDismiss() {
        updateTableView(.refresh)
    }
    
    func presentNewItem() {
        lastIndexPath = nil
        openTask(nil)
    }
    
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?) {
        lastIndexPath = indexPath
        openTask(item)
    }
    
    func openTask(_ item: ToDoItem?) {
        let oneTaskController = OneTaskViewController(toDoItem: item)
        oneTaskController.delegate = self
        
//        guard let transitioningDelegate = navigationController as? TransitionNavigationController else { return }
//        transitioningDelegate.sourceFrame = onCellFrame
//        transitioningDelegate.pushViewController(oneTaskController, animated: true)
//
//        oneTaskController.transitioningDelegate = transitioningDelegate
//        oneTaskController.modalPresentationStyle = .custom
        
        let navigationController = UINavigationController(rootViewController: oneTaskController)
        present(navigationController, animated: true)
    }
}

//extension TaskListViewController: OneTaskViewControllerDelegate {
//    func reloadData() {
//        delegate?.reloadData()
//    }
//
//
//}
