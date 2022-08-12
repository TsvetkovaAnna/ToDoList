import UIKit
import CocoaLumberjack

protocol OneTaskViewControllerDelegate: AnyObject {
    //func reloadData()
    func willDismiss()
    func updateTableViewDeletingRow()
}

final class OneTaskViewController: UIViewController {

    private var toDo: ToDoItem?
    
    private var cache = FileCache()
    
    //private var lastItemId: String? = nil
    
    //static var buttonDeleteHeight: CGFloat = 50 //пока не использовала
    
    //private var deadlineHorizontalStackHeight: NSLayoutConstraint?
    
    weak var delegate: OneTaskViewControllerDelegate?
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    }()
    
    var isCurrentSame: Bool {
        currentToDo?.text == toDo?.text && currentToDo?.deadline == toDo?.deadline &&  currentToDo?.importance == toDo?.importance
    }
    
    var currentToDo: ToDoItem? {
        
        guard let text = textView.text else { return nil }
        
        let importance: Importance// = .basic

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
        
        print("importance:", importance)
        
        let deadline = switcher.isOn ? calendar.date : nil
        
        return ToDoItem(text: text, importance: importance, deadline: deadline)
    }
    
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
        barButton.tintColor = textView.isEmpty ? Constants.Colors.Label.tertiary : Constants.Colors.Color.blue
        return barButton
    }()
    
    private lazy var undoBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(close))
        barButton.tintColor = Constants.Colors.Color.blue
        return barButton
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private(set) lazy var textView: PlaceholderTextView = {
        let textView = PlaceholderTextView(with: "Что надо сделать?", text: toDo?.text) {
            self.setupSaveButton()
        }
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        textView.font = Constants.Fonts.body
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
//    var textChanged: () -> Void = {
//        self.saveBarButton.isEnabled = !self.textView.isEmpty
//    }
    
    private lazy var accessoriesVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = Constants.Colors.Back.secondaryElevated
        stackView.layer.cornerRadius = 16
        //stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 12)
        stackView.spacing = 10 //как сделать отступ сверху у сегмента? может не через стек?
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = Constants.Colors.Support.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private lazy var separatorCalendar: UIView = {
        let separator = UIView()
        separator.isHidden = true
        separator.backgroundColor = Constants.Colors.Support.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private lazy var importanceHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        //stack.alignment = .center
        stack.distribution = .equalCentering
        //stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var deadlineDateVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually//.equalCentering //
        //let gesture = UITapGestureRecognizer(target: self, action: #selector(openCalendar))
        //stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    private lazy var deadlineHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill//.equalCentering
        //stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.textColor = Constants.Colors.Label.primary
        label.font = Constants.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.textColor = Constants.Colors.Label.primary
        label.font = Constants.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.Colors.Color.blue
        label.font = Constants.Fonts.footnote
        label.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openCalendar))
        label.addGestureRecognizer(gesture)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var segmentItems = [Constants.Images.arrowDown ?? "<-", "нет", Constants.Images.exclamationmark ?? "!!"] as [Any]
    
    private lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItems)
        segment.layer.cornerRadius = 9
        segment.backgroundColor = Constants.Colors.Support.overlay
        segment.selectedSegmentTintColor = .white
        //segment.selectedSegmentIndex = 2
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.isUserInteractionEnabled = true
        segment.addTarget(self, action: #selector(setupSaveButton), for: .valueChanged)
        return segment
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        //switcher.backgroundColor = .init(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchDeadlineLabel), for: .touchUpInside)
        return switcher
    }()
    
    lazy var buttonDelete: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        //button.clipsToBounds = true
        button.backgroundColor = .white
        button.tintColor = .black //?
        button.setTitleColor(Constants.Colors.Color.red, for: .normal)
        button.setTitleColor(Constants.Colors.Label.tertiary, for: .disabled)
        button.setTitle("Удалить", for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var calendar: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        calendar.preferredDatePickerStyle = .inline //как добиться выбора даты при .inline??
        calendar.locale = Locale.init(identifier: "ru_RU")
        calendar.calendar = Calendar.current
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear
        calendar.isUserInteractionEnabled = true
        calendar.isHidden = true
        calendar.addTarget(self, action: #selector(setDeadlineDate), for: .allEvents)
        calendar.tintColor = Constants.Colors.Color.blue
        return calendar
    }()
    
    init(toDoItem: ToDoItem?) {
        self.toDo = toDoItem
        //self.textView.text = toDoItem.text
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        switcher.isOn = toDo != nil && toDo?.deadline != nil
        calendar.isHidden = true
        calendarLabel.isHidden = !switcher.isOn
        calendarLabel.text = toDo?.deadline?.inString(withYear: true)
        if let deadline = toDo?.deadline {
            calendar.date = deadline
        }
        
        //print("empty", self.textView.isEmpty)
        DDLogInfo("empty \(self.textView.isEmpty)")
        self.setupSaveButton()
        
        print("toDo?.importance", toDo?.importance)
        segment.selectedSegmentIndex = 1
        
        guard let toDo = toDo else { return }
        
        switch toDo.importance {
        case .low:
            segment.selectedSegmentIndex = 0
        case .basic:
            segment.selectedSegmentIndex = 1
        case .important:
            segment.selectedSegmentIndex = 2
        }
        print("toDo?.importance", toDo.importance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        view.addGestureRecognizer(tapRecognizer)
        
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let offsetY = keyboardFrameValue.cgRectValue.height
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        view.removeGestureRecognizer(tapRecognizer)
        print(#function)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
        textView.endEditing(true)
    }
    
    private func setupView() {
        
        title = "Дело"
        view.backgroundColor = Constants.Colors.Back.primary
        self.navigationItem.setRightBarButton(saveBarButton, animated: true)
        self.navigationItem.setLeftBarButton(undoBarButton, animated: true)
        
        view.addSubview(scrollView)
        let scrollViewTop = scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let scrollViewBottom = scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let scrollViewLeading = scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let scrollViewTrailing = scrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
        
        scrollView.addSubview(contentView)
        let contentViewTop = contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        let contentViewBottom = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        let contentViewWidth = contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        let contentViewX = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
        //textView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing, contentViewTop, contentViewBottom, contentViewWidth, contentViewX])
        
        setTextView()
        
        setAccessoriesVerticalStack()
      
        setButtonDelete()
    }
    
    private func setTextView() {
        contentView.addSubview(textView)
        let textViewTop = textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        let textViewHeight = textView.heightAnchor.constraint(equalToConstant: 120)
        let textViewLeading = textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        let textViewTrailing = textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        NSLayoutConstraint.activate([textViewTop, textViewHeight, textViewLeading, textViewTrailing])
    }
    
    private func setAccessoriesVerticalStack() {
        contentView.addSubview(accessoriesVerticalStack)
        let accessoriesStackViewTop = accessoriesVerticalStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 15)
        let accessoriesStackViewX = accessoriesVerticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let accessoriesStackViewLeading = accessoriesVerticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let accessoriesViewTrailing = accessoriesVerticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        accessoriesVerticalStack.addArrangedSubview(importanceHorizontalStack)
        accessoriesVerticalStack.addArrangedSubview(separator)
        accessoriesVerticalStack.addArrangedSubview(deadlineHorizontalStack)
        accessoriesVerticalStack.addArrangedSubview(separatorCalendar)
        accessoriesVerticalStack.addArrangedSubview(calendar)
        
        importanceHorizontalStack.addArrangedSubview(importanceLabel)
        importanceHorizontalStack.addArrangedSubview(segment)

        deadlineHorizontalStack.addArrangedSubview(deadlineDateVerticalStack)
        deadlineHorizontalStack.addArrangedSubview(switcher)
        
        deadlineDateVerticalStack.addArrangedSubview(deadlineLabel)
        deadlineDateVerticalStack.addArrangedSubview(calendarLabel)

        //let importanceHorizontalStackHeight = importanceHorizontalStack.heightAnchor.constraint(equalToConstant: 46)
        let separatorHeight = separator.heightAnchor.constraint(equalToConstant: 0.5)
        //let deadlineHorizontalStackHeight = deadlineHorizontalStack.heightAnchor.constraint(equalToConstant: 49)
        let separator2Height = separatorCalendar.heightAnchor.constraint(equalToConstant: 0.5)
        let segmentWidth = segment.widthAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([accessoriesStackViewTop, accessoriesStackViewX, accessoriesStackViewLeading, accessoriesViewTrailing, separatorHeight/*, importanceHorizontalStackHeight, deadlineHorizontalStackHeight*/, separator2Height, segmentWidth])
    }
    
    private func setButtonDelete() {
        contentView.addSubview(buttonDelete)
        let buttonDeleteTop = buttonDelete.topAnchor.constraint(equalTo: accessoriesVerticalStack.bottomAnchor, constant: 15)
        let buttonDeleteHeight = buttonDelete.heightAnchor.constraint(equalToConstant: 56)
        let buttonDeleteLeading = buttonDelete.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let buttonDeleteTrailing = buttonDelete.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([buttonDeleteTop, buttonDeleteHeight, buttonDeleteLeading, buttonDeleteTrailing])
    }
    
    private func returnToTaskList() {
//        if let navController = navigationController {
//            navController.popViewController(animated: true)
//        } else {
//            print("nav controller is nil")
//        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func close() {
        //returnToTaskList()
        //navigationController?.popViewController(animated: true)
        
        print("delegate?.willDismiss(), delegate = ", delegate)
        delegate?.willDismiss()
        dismiss(animated: true)
    }
    
    @objc private func saveToDo() {
        
        guard let currentToDo = currentToDo else { return }
        
        if let toDo = toDo {
            cache.refreshItem(currentToDo, byId: toDo.id)
        } else {
            cache.addItem(item: currentToDo)
        }
        
        print(#function)
        
        close()
    }
    
    @objc private func didTapDeleteButton() {
        
        guard let id = toDo?.id else { return }
        cache.deleteItem(byId: id)
        delegate?.updateTableViewDeletingRow()
        close()
    }
    
    @objc private func setDeadlineDate(_: AnyObject/*calend: UIDatePicker*/) {
        calendarLabel.text = calendar.date.inString(withYear: true)
    }
    
    @objc func switchDeadlineLabel() {
        
        if !switcher.isOn {
            calendar.isHidden = true
            separatorCalendar.isHidden = true
        }
        
        calendarLabel.isHidden.toggle()
        calendarLabel.text = (Date.now + 24 * 60 * 60).inString(withYear: true)
        setupSaveButton()
    }
    
    @objc func setupSaveButton() {
        DDLogInfo("empty text - \(self.textView.isEmpty)")
        saveBarButton.isEnabled = !textView.isEmpty && !isCurrentSame
    }

    @objc private func openCalendar() {
        separatorCalendar.isHidden.toggle()
        calendar.isHidden.toggle()
    }
    
}
