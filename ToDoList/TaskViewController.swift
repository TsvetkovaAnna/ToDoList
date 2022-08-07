

import UIKit

final class TaskViewController: UIViewController {

    private var cache = FileCache()
    
    private var lastItemId: String? = nil
    
    private lazy var buttonDeleteHeight: CGFloat = 50
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .clear
        scrollView.contentSize = view.frame.size
        scrollView.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var saveBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveToDo))
        barButton.tintColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        return barButton
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var textField: IndentTextField = {
        let textField = IndentTextField()
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.tintColor = .black
        textField.font = UIFont.systemFont(ofSize: 17)
        //textField.drawPlaceholder(in: CGRect(x: 0, y: 0, width: 100, height: 30))
        //textField.placeholderRect(forBounds: CGRect(x: 0, y: 0, width: 100, height: 30))
        textField.placeholder = "Что надо сделать?" //как сместить наверх?
        //textField.addTarget(self, action: #selector(statusTextChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var accessoriesView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8 //как сделать отступ сверху у сегмента? может не через стек?
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private lazy var importanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var deadlineCalendarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var deadlineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var segmentItems = ["<-", "нет", "!!"]
    private lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItems)
        segment.backgroundColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.06)
        segment.selectedSegmentTintColor = .white
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.isUserInteractionEnabled = true
        return segment
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        //switcher.backgroundColor = .init(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchDeadline), for: .touchUpInside)
        return switcher
    }()
    
    lazy var buttonDelete: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 12
        //button.clipsToBounds = true
        button.backgroundColor = .white
        button.tintColor = .black
        button.setTitleColor(UIColor.init(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0), for: .normal)
        button.setTitleColor(UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15), for: .disabled)
        button.setTitle("Удалить", for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var calendar: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        calendar.preferredDatePickerStyle = .compact
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear
        calendar.isHidden = true
        //calendar.font = .systemFont(ofSize: 13)
        calendar.tintColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        guard let lastItem = cache.loadLast() else { return }
        
        switch lastItem.importance {
        case .low:
            segment.selectedSegmentIndex = 0
        case .basic:
            segment.selectedSegmentIndex = 1
        case .important:
            segment.selectedSegmentIndex = 2
        }
        textField.text = lastItem.text
        switcher.isOn = lastItem.deadline != nil
        calendar.isHidden = lastItem.deadline == nil
        if let deadline = lastItem.deadline, !calendar.isHidden {
            calendar.date = deadline
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.addGestureRecognizer(tapRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        view.removeGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let offsetY = keyboardFrameValue.cgRectValue.height
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        print(#function)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    private func setupView() {
        
        title = "Дело" //Как установить размер шрифта?
        view.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        self.navigationItem.setRightBarButton(saveBarButton, animated: true)
        
        view.addSubview(scrollView)
        let scrollViewTop = scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let scrollViewBottom = scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let scrollViewLeading = scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let scrollViewTrailing = scrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
        
        scrollView.addSubview(contentView)
        let contentViewTop = contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        let contentViewBottom = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        //let contentViewHeight = contentView.heightAnchor.constraint(equalToConstant: 700)
        let contentViewWidth = contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        let contentViewX = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
        contentView.addSubview(textField)
        let textFieldTop = textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        let textFieldHeight = textField.heightAnchor.constraint(equalToConstant: 150)
        let textFieldLeading = textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let textFieldTrailing = textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        contentView.addSubview(accessoriesView)
        let accessoriesViewTop = accessoriesView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15)
        let accessoriesViewHeight = accessoriesView.heightAnchor.constraint(equalToConstant: 140.5)
        let accessoriesViewLeading = accessoriesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let accessoriesViewTrailing = accessoriesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
      
        
        accessoriesView.addSubview(stackView)
        stackView.addArrangedSubview(importanceStack)
        stackView.addArrangedSubview(separator)
        stackView.addArrangedSubview(deadlineStack)
        //importanceStack.arrangedSubviews[importanceLabel, segment]
        importanceStack.addArrangedSubview(importanceLabel)
        importanceStack.addArrangedSubview(segment)
        //importanceStack.distribution = .equalCentering
        deadlineStack.addArrangedSubview(deadlineCalendarStack)
        deadlineStack.addArrangedSubview(switcher)
        deadlineCalendarStack.addArrangedSubview(deadlineLabel)
        deadlineCalendarStack.addArrangedSubview(calendar)
        let stackViewTop = stackView.topAnchor.constraint(equalTo: accessoriesView.topAnchor)
        let stackViewX = stackView.centerXAnchor.constraint(equalTo: accessoriesView.centerXAnchor)
        let stackViewLeading = stackView.leadingAnchor.constraint(equalTo: accessoriesView.leadingAnchor, constant: 10)
        let stackViewHeight = stackView.heightAnchor.constraint(equalToConstant: 140.5)
        let importanceStackHeight = importanceStack.heightAnchor.constraint(equalToConstant: 52)
        let separatorHeight = separator.heightAnchor.constraint(equalToConstant: 0.5)
        let deadlineStackHeight = deadlineStack.heightAnchor.constraint(equalToConstant: 72)
        
        
        
        contentView.addSubview(buttonDelete)
        let buttonDeleteTop = buttonDelete.topAnchor.constraint(equalTo: accessoriesView.bottomAnchor, constant: 15)
        let buttonDeleteHeight = buttonDelete.heightAnchor.constraint(equalToConstant: 50)
        let buttonDeleteLeading = buttonDelete.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let buttonDeleteTrailing = buttonDelete.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing, contentViewTop, contentViewBottom, contentViewWidth, contentViewX, textFieldTop, textFieldHeight, textFieldLeading, textFieldTrailing, accessoriesViewTop, accessoriesViewHeight, accessoriesViewLeading, accessoriesViewTrailing, stackViewTop, stackViewX, stackViewLeading, stackViewHeight, importanceStackHeight, separatorHeight, deadlineStackHeight, buttonDeleteTop, buttonDeleteHeight, buttonDeleteLeading, buttonDeleteTrailing])
    }
    
    @objc private func saveToDo() {
        
        guard let text = textField.text else { return }
        
        var importance: ImportanceEnum = .basic
        
        switch segment.selectedSegmentIndex {
        case 0:
            importance = .low
        case 1:
            importance = .basic
        case 2:
            importance = .important
        default:
            importance = .basic
        }
        
        let deadline = switcher.isOn ? calendar.date : nil
        let item = ToDoItem(text: text, importance: importance, deadline: deadline)
        lastItemId = item.id
        cache.addItem(item: item)
        
//        segment.selectedSegmentIndex = 1
//        textField.text = nil
//        switcher.isOn = false
//        view.endEditing(true)
    }
    
    @objc private func didTapDeleteButton() {
        guard let id = lastItemId else { return }
        cache.deleteItem(byId: id)
    }
    
    @objc func switchDeadline() {
        
        if calendar.isHidden {
            calendar.date = Date(timeIntervalSinceNow: 24*60*60)
        }
        
        calendar.isHidden.toggle()
    }

}

