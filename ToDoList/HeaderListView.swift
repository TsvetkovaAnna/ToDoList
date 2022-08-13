import UIKit

class HeaderListView: UIView {

    private lazy var doneLabelButtonHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.backgroundColor = Constants.Colors.Back.primary
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var doneCount = 0
    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнено - " + String(doneCount)
        label.font = Constants.Fonts.subhead
        label.textColor = Constants.Colors.Label.tertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var shownDoneTasks = false // ? нужно еще?
    private lazy var showHideDoneTasksButton: UIButton = {
        let button = UIButton()
        //button.titleLabel = shownDoneTasks ? "Показать" : "Скрыть"
        button.setTitle("Показать", for: .normal)
        button.setTitle("Скрыть", for: .disabled)
        button.titleLabel?.font = Constants.Fonts.subhead
        button.setTitleColor(Constants.Colors.Color.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawSelf() {
        self.addSubview(doneLabelButtonHorizontalStack)
        doneLabelButtonHorizontalStack.addArrangedSubview(doneCountLabel)
        doneLabelButtonHorizontalStack.addArrangedSubview(showHideDoneTasksButton)
        let bottomStack = doneLabelButtonHorizontalStack.topAnchor.constraint(equalTo: self.topAnchor)
        let leadingStack = doneLabelButtonHorizontalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        let trailingStack = doneLabelButtonHorizontalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        let xStack = doneLabelButtonHorizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
        NSLayoutConstraint.activate([bottomStack, leadingStack, trailingStack, xStack])
    }
}
