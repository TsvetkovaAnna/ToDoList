import UIKit
import CocoaLumberjack

protocol TaskListViewInput: AnyObject {
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?)
}

typealias TaskListViewAndHeaderOutput = TaskListViewOutput & HeaderOutput

protocol TaskListViewOutput: AnyObject {
    func didSelectItem(_ item: ToDoItem?, onCellFrame: CGRect?, indexPath: IndexPath?)
    func presentNewItem()
    func changeIsDone(_ indexPath: IndexPath?)
}

final class TaskListViewController: UIViewController {

    //let fileCache: FileCache
    let generalService: GeneralService
    
    weak var taskViewDelegate: TaskListViewInput?
    weak var headerDelegate: HeaderInput?
    
    private var lastIndexPath: IndexPath?
    private var isDoneShown = true
    
    let activityIndicator = UIActivityIndicatorView.init(style: .medium)
    
    private lazy var viewTable: TaskListView = {
        
        let view = TaskListView(frame: .zero, todoItems: generalService.items, deleteAction: { indexPath in
            let item = self.generalService.items[indexPath.row]
            
            self.showIndicator()
            self.generalService.redact(.delete, item: item) { result in
                self.handleResult(result) {
                    self.taskViewDelegate?.update(with: self.generalService.items, deletingRow: indexPath, refreshingRow: nil)
                    self.hideIndicator()
                } failureCompletion: { self.hideIndicator() }
            }
        }, completionWithHeader: { headerView in
            headerView.delegate = self
            self.headerDelegate = headerView
            self.setHeaderDonesCount()
        })
        
        taskViewDelegate = view
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    init(fileCache: FileCache) {
//        self.fileCache = fileCache
//        super.init(nibName: nil, bundle: nil)
//    }
    
    init(generalService: GeneralService) {
        self.generalService = generalService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func showIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    func hideIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func refreshTableViewRow() {
        updateTableView(.refresh)
    }
    
    func updateTableView(_ type: UpdateType) {
        
        showIndicator()
        generalService.update { result in
            self.handleResult(result) {
                let items = self.isDoneShown ? self.generalService.items : self.generalService.items.filter({ $0.isDone == false })
                
                switch type {
                case .refresh:
                    self.taskViewDelegate?.update(with: items, deletingRow: nil, refreshingRow: self.lastIndexPath)
                case .remove:
                    self.taskViewDelegate?.update(with: items, deletingRow: self.lastIndexPath, refreshingRow: nil)
                case .refreshAll:
                    self.taskViewDelegate?.update(with: items, deletingRow: nil, refreshingRow: nil)
                }
                self.hideIndicator()
            } failureCompletion: { self.hideIndicator() }
        }
        
    }
    
    private func setupView() {
        
        title = "Мои дела"
        view.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)

        showIndicator()
        generalService.load { result in
            self.handleResult(result) {
                self.view.addSubview(self.viewTable)
                let tableTop = self.viewTable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
                let tableBottom = self.viewTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                let tableLeading = self.viewTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
                let tableTrailing = self.viewTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
                self.viewTable.backgroundColor = .clear
                
                NSLayoutConstraint.activate([tableTop, tableBottom, tableLeading, tableTrailing])
                self.hideIndicator()
            } failureCompletion: { self.hideIndicator() }
        }
    }
    
    func setHeaderDonesCount() {
        let donesCount = generalService.items.filter { $0.isDone == true }.count
        headerDelegate?.setDonesCount(donesCount)
    }

}

extension TaskListViewController: TaskListViewAndHeaderOutput, OneTaskViewControllerDelegate {
    
    enum UpdateType {
        case refresh
        case remove
        case refreshAll
    }
    
    func toggleShown() {
        isDoneShown.toggle()
        updateTableView(.refreshAll)
        headerDelegate?.setShowHide(isDoneShown)
    }
    
    func changeIsDone(_ indexPath: IndexPath?) {
        guard let row = indexPath?.row else { return }
        
        let revertedItem = generalService.items[row].reverted
        
        showIndicator()
        generalService.redact(.edit, item: revertedItem) { result in
            self.handleResult(result) {
                self.setHeaderDonesCount()
                self.refreshTableViewRow()
                self.hideIndicator()
            } failureCompletion: { self.hideIndicator() }
        }
    }
    
    func updateTableViewDeletingRow() {
        updateTableView(.remove)
    }
    
    func willDismiss(after action: TaskAction) {
        switch action {
        case .none:
            break
        case .deleting:
            updateTableViewDeletingRow()
        case .adding:
            updateTableView(.refreshAll)
        case .editing:
            refreshTableViewRow()
        }
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
        let oneTaskController = OneTaskViewController(toDoItem: item, generalService: generalService)
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
