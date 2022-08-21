import UIKit
import CocoaLumberjack

protocol TaskListViewInput: AnyObject {
    func update(with items: [ToDoItem], deletingRow: IndexPath?, refreshingRow: IndexPath?)
}

// typealias TaskListViewAndHeaderInput = TaskListViewInput & HeaderInput
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
    
//    var appDelegate: AppDelegate? {
//        UIApplication().delegate as? AppDelegate
//    }
    
    let activityIndicator = UIActivityIndicatorView.init(style: .medium)
//    let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
//    self.navigationItem.leftBarButtonItem = refreshBarButton
//    activityIndicator.startAnimating()
    
    private lazy var viewTable: TaskListView = {
        
        let view = TaskListView(frame: .zero, todoItems: generalService.items, deleteAction: { indexPath in
            let item = self.generalService.items[indexPath.row]
            //self.fileCache.deleteItem(byId: item.id)
            self.generalService.delete(item.id) {
                self.taskViewDelegate?.update(with: self.generalService.items, deletingRow: indexPath, refreshingRow: nil)
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

        showIndicator()
        
        //hideIndicator()
        
        setupView()
        
//        let testItem = ToDoItem(id: "123", text: "t", importance: .low, deadline: nil, isDone: false, dateCreated: Date(), dateChanged: Date())
//        let testItem2 = ToDoItem(id: "1", text: "newText!!!", importance: .low, deadline: Date(), isDone: false, dateCreated: Date(), dateChanged: Date(timeIntervalSinceNow: 5))
//
//        generalService.add(testItem)
//
//
////        testItem.dateChanged = Date()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
////            self.generalService.edit(testItem2)
//            self.generalService.update {
//                print("upd")
//            }
//        }
//        generalService.delete("Check this design")

//        guard let appDelegate = appDelegate else { return }
//        appDelegate.application?(<#T##application: UIApplication##UIApplication#>, supportedInterfaceOrientationsFor: <#T##UIWindow?#>)
//        appDelegate.orientationMask = .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
//        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
//        self.navigationItem.rightBarButtonItem = refreshBarButton
//        activityIndicator.startAnimating()
        // updateTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func showIndicator() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        //self.navigationItem.titleView = self.activityIndicator
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }

    func hideIndicator() {
        //self.navigationItem.titleView = nil
        //self.navigationItem.leftBarButtonItem = nil
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    func refreshTableViewRow() {
        updateTableView(.refresh)
    }
    
    func updateTableView(_ type: UpdateType) {
        
        //fileCache.loadData()
        
        self.generalService.update {
            let items = self.isDoneShown ? self.generalService.items : self.generalService.items.filter({ $0.isDone == false })
            
            switch type {
            case .refresh:
                self.taskViewDelegate?.update(with: items, deletingRow: nil, refreshingRow: self.lastIndexPath)
            case .remove:
                self.taskViewDelegate?.update(with: items, deletingRow: self.lastIndexPath, refreshingRow: nil)
            case .refreshAll:
                self.taskViewDelegate?.update(with: items, deletingRow: nil, refreshingRow: nil)
            }
        }
        
    }
    
    private func setupView() {
        
        title = "Мои дела"
        //navigationItem.titleView?.backgroundColor?.withAlphaComponent(0.5)// = Constants.Colors.Support.navBarBlur
        //navigationItem.titleView?.backgroundColor?.withAlphaComponent(0.8)
        view.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        
        generalService.load {
            self.view.addSubview(self.viewTable)
            let tableTop = self.viewTable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            let tableBottom = self.viewTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            let tableLeading = self.viewTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
            let tableTrailing = self.viewTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
            self.viewTable.backgroundColor = .clear
            
            NSLayoutConstraint.activate([tableTop, tableBottom, tableLeading, tableTrailing])
        }
    }
    
    func setHeaderDonesCount() {
        let donesCount = generalService.items.filter { $0.isDone == true }.count
        headerDelegate?.setDonesCount(donesCount)
    }

}

//extension TaskListView: HeaderOutput { //Где делегат?
//    func showHideDoneInHeader() -> Int {
//        var notDoneItems = [ToDoItem]()
//        var doneItems = [ToDoItem]()
//        for item in todoItems {
//            if !item.isDone {
//                notDoneItems.append(item)
//            } else {
//                doneItems.append(item)
//            }
//        }
//        let doneCount = doneItems.count
//        return doneCount
//    }
//}

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
        //fileCache.refreshItem(revertedItem, byId: revertedItem.id)
        generalService.edit(revertedItem)
        
        //generalService.items.remove(at: row)
        //generalService.items.insert(generalService.items[row].reverted, at: row)
        
        setHeaderDonesCount()
        refreshTableViewRow()
    }
    
    func updateTableViewDeletingRow() {
        updateTableView(.remove)
    }
    
    func willDismiss() {
        refreshTableViewRow()
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
