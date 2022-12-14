import UIKit
import CocoaLumberjack

enum TaskAction {
    case none
    case adding
    case deleting
    case editing
}

protocol OneTaskViewControllerDelegate: AnyObject {
    func willDismiss(after: TaskAction)
    func updateTableViewDeletingRow()
}

extension OneTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: fixedWidth, height: max(newSize.height, textViewHeight))
    }
}

final class OneTaskViewController: UIViewController {

    private var toDo: ToDoItem?
    
    private var generalService: GeneralServiceProtocol
    
    private var buttonDeleteHeight: CGFloat = 56
    
    private var textViewHeight: CGFloat = 120
    
    weak var delegate: OneTaskViewControllerDelegate?
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    }()
    
    var isCurrentSame: Bool {
        currentToDo?.text == toDo?.text && currentToDo?.deadline == toDo?.deadline &&  currentToDo?.importance == toDo?.importance
    }
    
    var currentToDo: ToDoItem? {
        
        guard let text = textView.text else { return nil }
        
        let importance: ToDoItem.Importance

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
        let barButton = UIBarButtonItem(title: "??????????????????", style: .plain, target: self, action: #selector(saveToDo))
        barButton.tintColor = Constants.Colors.Color.blue
        barButton.isEnabled = false
        return barButton
    }()
    
    private lazy var undoBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "????????????????", style: .plain, target: self, action: #selector(close))
        barButton.tintColor = Constants.Colors.Color.blue
        return barButton
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private(set) lazy var textView: PlaceholderTextView = {
        let textView = PlaceholderTextView(with: "?????? ???????? ???????????????", text: toDo?.text) {
            self.setupSaveButton()
        }
        textView.backgroundColor = .white
        //textView.isScrollEnabled = false
        //textView.sizeToFit()
        textView.layer.cornerRadius = 16
        //textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
        textView.font = Constants.Fonts.body
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var accessoriesVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = Constants.Colors.Back.secondaryElevated
        stackView.layer.cornerRadius = 16
        //stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 12)
        stackView.spacing = 10
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
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var deadlineDateVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually//.equalCentering //
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    private lazy var deadlineHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill//.equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "????????????????"
        label.textColor = Constants.Colors.Label.primary
        label.font = Constants.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "?????????????? ????"
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
    
    var segmentItems = [Constants.Images.arrowDown ?? "<-", "??????", Constants.Images.exclamationmark ?? "!!"] as [Any]
    
    private lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItems)
        segment.layer.cornerRadius = 9
        segment.backgroundColor = Constants.Colors.Support.overlay
        segment.selectedSegmentTintColor = .white
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.isUserInteractionEnabled = true
        segment.addTarget(self, action: #selector(setupSaveButton), for: .valueChanged)
        return segment
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchDeadlineLabel), for: .touchUpInside)
        return switcher
    }()
    
    lazy var buttonDelete: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.tintColor = .black //?
        button.setTitleColor(Constants.Colors.Color.red, for: .normal)
        button.setTitleColor(Constants.Colors.Label.tertiary, for: .disabled)
        button.setTitle("??????????????", for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = !textView.isEmpty
        return button
    }()
    
    private lazy var calendar: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        calendar.preferredDatePickerStyle = .inline
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
    
    init(toDoItem: ToDoItem?, generalService: GeneralServiceProtocol) {
        self.toDo = toDoItem
        self.generalService = generalService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        //self.textViewDidChange(textView)
        switcher.isOn = toDo != nil && toDo?.deadline != nil
        calendar.isHidden = true
        calendarLabel.isHidden = !switcher.isOn
        calendarLabel.text = toDo?.deadline?.inString(withYear: true)
        if let deadline = toDo?.deadline {
            calendar.date = deadline
        }
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        
        view.addGestureRecognizer(tapRecognizer)
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let deleteButtonBottomPointY = buttonDelete.frame.origin.y + buttonDeleteHeight
            let keyboardOriginY = view.safeAreaLayoutGuide.layoutFrame.height - keyboardHeight
            
            var navBarHeight: CGFloat = 0
            if let barHeight = navigationController?.navigationBar.frame.height {
                navBarHeight = barHeight
            }
            let yOffset = keyboardOriginY <= deleteButtonBottomPointY ? deleteButtonBottomPointY - keyboardOriginY + 16 - navBarHeight : 0 - navBarHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        }
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        view.removeGestureRecognizer(tapRecognizer)
        
        var navBarHeight: CGFloat = 0
        if let barHeight = navigationController?.navigationBar.frame.height {
            navBarHeight = barHeight
        }
        let yOffset = 0 - navBarHeight
        scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
        textView.endEditing(true)
    }
    
    private func setupView() {
        
        title = "????????"
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
        
        NSLayoutConstraint.activate([scrollViewTop, scrollViewBottom, scrollViewLeading, scrollViewTrailing, contentViewTop, contentViewBottom, contentViewWidth, contentViewX])
        
        setTextView()
        
        setAccessoriesVerticalStack()
      
        setButtonDelete()
    }
    
    private func setTextView() {
        contentView.addSubview(textView)
        
//        let textViewHeightContent = textView.contentSize.height
//        let trueHeightTextView = textViewHeightContent > 120 ? textViewHeightContent : 120
        let textViewTop = textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        let textViewHeight = textView.heightAnchor.constraint(equalToConstant: textViewHeight)
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

        let separatorHeight = separator.heightAnchor.constraint(equalToConstant: 0.5)
        let separator2Height = separatorCalendar.heightAnchor.constraint(equalToConstant: 0.5)
        let segmentWidth = segment.widthAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([accessoriesStackViewTop, accessoriesStackViewX, accessoriesStackViewLeading, accessoriesViewTrailing, separatorHeight, separator2Height, segmentWidth])
    }
    
    private func setButtonDelete() {
        contentView.addSubview(buttonDelete)
        let buttonDeleteTop = buttonDelete.topAnchor.constraint(equalTo: accessoriesVerticalStack.bottomAnchor, constant: 15)
        let buttonDeleteHeight = buttonDelete.heightAnchor.constraint(equalToConstant: buttonDeleteHeight)
        let buttonDeleteLeading = buttonDelete.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let buttonDeleteTrailing = buttonDelete.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([buttonDeleteTop, buttonDeleteHeight, buttonDeleteLeading, buttonDeleteTrailing])
    }
    
    private func returnToTaskList() {
//        if let navController = navigationController {
//            navController.popViewController(animated: true)
//        } else {
//            DDLogInfo("nav controller is nil")
//        }
        delegate?.willDismiss(after: .none)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func close() {
        //returnToTaskList()
        //navigationController?.popViewController(animated: true)
        //delegate?.willDismiss(after: action)
        dismiss(animated: true)
    }
    
    @objc private func saveToDo() {
        
        guard let currentToDo = currentToDo else { return }
        
        if let todo = toDo {
            let item = ToDoItem(id: todo.id, text: currentToDo.text, importance: currentToDo.importance, deadline: currentToDo.deadline, isDone: todo.isDone, dateCreated: todo.dateCreated, dateChanged: currentToDo.dateChanged)

            generalService.redact(.edit, item: item) { result in
                self.handleResult(result) {
                    self.delegate?.willDismiss(after: .editing)
                    self.close()
                }
            }
        } else {
            generalService.redact(.add, item: currentToDo) { result in
                self.handleResult(result) {
                    self.delegate?.willDismiss(after: .adding)
                    self.close()
                }
            }
        }
    }
    
    @objc private func didTapDeleteButton() {
        
        guard let todo = toDo else { return }
        generalService.redact(.delete, item: todo) { result in
            self.handleResult(result) {
                self.delegate?.updateTableViewDeletingRow()
                self.close()
            }
        }
    }
    
    @objc private func setDeadlineDate(_: AnyObject/*calend: UIDatePicker*/) {
        calendarLabel.text = calendar.date.inString(withYear: true)
        setupSaveButton()
    }
    
    @objc func switchDeadlineLabel() {
        
        if !switcher.isOn {
            calendar.isHidden = true
            separatorCalendar.isHidden = true
        }
        
        let date = Date.now + 24 * 60 * 60
        calendarLabel.isHidden.toggle()
        calendarLabel.text = date.inString(withYear: true)
        calendar.date = date
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
