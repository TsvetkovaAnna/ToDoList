import UIKit
import CocoaLumberjack

// protocol OneTaskViewControllerDelegate {
//     func reloadData()
// }

final class OneTaskViewController: UIViewController {

    private var toDo: ToDoItem?
    
    private var cache = FileCache()
    
    //private var lastItemId: String? = nil
    
    private lazy var buttonDeleteHeight: CGFloat = 50 //пока не использовала
    
    //private var deadlineHorizontalStackHeight: NSLayoutConstraint?
    
    /*weak*/ var delegate: OneTaskViewControllerDelegate?
    
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
        barButton.tintColor = textView.isEmpty ? .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) : .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        return barButton
    }()
    
    private lazy var undoBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(close))
        barButton.tintColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        return barButton
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
//    private lazy var placeholderLabel: UILabel = {
//        let placeholder = UILabel()
//        placeholder.text = "Что надо сделать?"
//        placeholder.font = UIFont(name: "SFProText-Regular", size: 17)
//        placeholder.sizeToFit()
//        placeholder.textColor = .lightGray
//        placeholder.isHidden = !textView.text.isEmpty
//        placeholder.frame.origin = CGPoint(x: 19, y: 17)
//        return placeholder
//    }()
    
    private(set) lazy var textView: PlaceholderTextView = {
        let textView = PlaceholderTextView(with: "Что надо сделать?", text: toDo?.text) {
            self.setupSaveButton()
        }
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    @objc func setupSaveButton() {
        //print("empty", self.textView.isEmpty)
        DDLogInfo("empty \(self.textView.isEmpty)")
        saveBarButton.isEnabled = !textView.isEmpty && !isCurrentSame
    }
    
//    var textChanged: () -> Void = {
//        self.saveBarButton.isEnabled = !self.textView.isEmpty
//    }
    
//    private lazy var accessoriesView: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    private lazy var accessoriesVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .white
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
        separator.backgroundColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private lazy var separatorCalendar: UIView = {
        let separator = UIView()
        separator.isHidden = true
        separator.backgroundColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
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
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)//UIFont.boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarLabel: UILabel = {
        let label = UILabel()
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ru_RU")
//        dateFormatter.dateFormat = "d MMMM yyyy"
//        let date = Date.now + 24 * 60 * 60
//        let defaultText = dateFormatter.string(from: date)
//        label.text = defaultText
        label.textColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 13)
        label.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openCalendar))
        label.addGestureRecognizer(gesture)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var segmentItems = [UIImage(systemName: "arrow.down")?.withTintColor(.gray, renderingMode: .alwaysOriginal) ?? "<-", "нет", UIImage(systemName: "exclamationmark.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.withTintColor(.red, renderingMode: .alwaysOriginal) ?? "!!"] as [Any]
    
    private lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItems)
        segment.layer.cornerRadius = 9
        segment.backgroundColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.06)
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
        calendar.preferredDatePickerStyle = .inline //как добиться выбора даты при .inline??
        calendar.locale = Locale.init(identifier: "ru_RU")
        calendar.calendar = Calendar.current
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear
        calendar.isUserInteractionEnabled = true
        calendar.isHidden = true
        calendar.addTarget(self, action: #selector(setDeadlineDate), for: .allEvents)
        calendar.tintColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
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
        view.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
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
        
        contentView.addSubview(textView)
        let textFieldTop = textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        let textFieldHeight = textView.heightAnchor.constraint(equalToConstant: 120)
        let textFieldLeading = textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        let textFieldTrailing = textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        //textView.addSubview(placeholderLabel)
        
      
        contentView.addSubview(accessoriesVerticalStack)
        let accessoriesStackViewTop = accessoriesVerticalStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 15)
        let accessoriesStackViewX = accessoriesVerticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let accessoriesStackViewLeading = accessoriesVerticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let accessoriesViewTrailing = accessoriesVerticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        
        accessoriesVerticalStack.addArrangedSubview(importanceHorizontalStack)
        accessoriesVerticalStack.addArrangedSubview(separator)
        accessoriesVerticalStack.addArrangedSubview(deadlineHorizontalStack)
        //accessoriesVerticalStack.addArrangedSubview(separatorCalendar)
        accessoriesVerticalStack.addArrangedSubview(calendar)
        
        importanceHorizontalStack.addArrangedSubview(importanceLabel)
        importanceHorizontalStack.addArrangedSubview(segment)

        deadlineHorizontalStack.addArrangedSubview(deadlineDateVerticalStack)
        deadlineHorizontalStack.addArrangedSubview(switcher)
        
        deadlineDateVerticalStack.addArrangedSubview(deadlineLabel)
        deadlineDateVerticalStack.addArrangedSubview(calendarLabel)

        let importanceHorizontalStackHeight = importanceHorizontalStack.heightAnchor.constraint(equalToConstant: 46)
        let separatorHeight = separator.heightAnchor.constraint(equalToConstant: 0.5)
        let deadlineHorizontalStackHeight = deadlineHorizontalStack.heightAnchor.constraint(equalToConstant: 49)
        let segmentWidth = segment.widthAnchor.constraint(equalToConstant: 150)
        
        contentView.addSubview(buttonDelete)
        let buttonDeleteTop = buttonDelete.topAnchor.constraint(equalTo: accessoriesVerticalStack.bottomAnchor, constant: 15)
        let buttonDeleteHeight = buttonDelete.heightAnchor.constraint(equalToConstant: 56)
        let buttonDeleteLeading = buttonDelete.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let buttonDeleteTrailing = buttonDelete.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing, contentViewTop, contentViewBottom, contentViewWidth, contentViewX, textFieldTop, textFieldHeight, textFieldLeading, textFieldTrailing, accessoriesStackViewTop, accessoriesStackViewX, accessoriesStackViewLeading, accessoriesViewTrailing, importanceHorizontalStackHeight, separatorHeight, deadlineHorizontalStackHeight, buttonDeleteTop, buttonDeleteHeight, buttonDeleteLeading, buttonDeleteTrailing, segmentWidth])
    }
    
    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }
    
    var isCurrentSame: Bool {
        currentToDo?.text == toDo?.text && currentToDo?.deadline == toDo?.deadline &&  currentToDo?.importance == toDo?.importance
    }
    
    var currentToDo: ToDoItem? {
        
        guard let text = textView.text else { return nil }
        
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
        
        return ToDoItem(text: text, importance: importance, deadline: deadline)
    }
    
    @objc private func saveToDo() {
        
        guard let currentToDo = currentToDo else { return }
        
        if let toDo = toDo {
            cache.refreshItem(currentToDo, byId: toDo.id)
        } else {
            cache.addItem(item: currentToDo)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapDeleteButton() {
        guard let id = toDo?.id else { return }
        cache.deleteItem(byId: id)
    }
    
    @objc private func setDeadlineDate(_: AnyObject/*calend: UIDatePicker*/) {
        calendarLabel.text = calendar.date.inString(withYear: true)
    }
    
    @objc func switchDeadlineLabel() {
        
        if !switcher.isOn {
            calendar.isHidden = true
        }
        
//        if !switcher.isOn {
//            calendar.isHidden = false
//            //deadlineHorizontalStackHeight = deadlineHorizontalStack.heightAnchor.constraint(equalToConstant: 49)
//            //NSLayoutConstraint.activate([deadlineHorizontalStackHeight])
//        }
            
        calendarLabel.isHidden.toggle()
        calendarLabel.text = (Date.now + 24 * 60 * 60).inString(withYear: true)
        setupSaveButton()
    }
    
    
    @objc func switchDeadline() {
        
        if calendar.isHidden {
            calendar.date = Date(timeIntervalSinceNow: 24*60*60)
        }
        
        calendar.isHidden.toggle()
    }
    
    @objc private func openCalendar() {
        
        //        if calendar.isHidden {
//
//            //calendar.date = Date(timeIntervalSinceNow: 24*60*60)
//        }

        separatorCalendar.isHidden.toggle()
        calendar.isHidden.toggle()
    }

}
