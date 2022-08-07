

import UIKit

class HeaderListView: UIView {

    private lazy var doneLabelButtonHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.backgroundColor = .init(_colorLiteralRed: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var doneCount = 0
    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнено - " + String(doneCount)
        label.font = UIFont(name: "SFProText-Regular", size: 15)
        label.textColor = .init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var shownDoneTasks = false // ? нужно еще?
    private lazy var showHideDoneTasksButton: UIButton = {
        let button = UIButton()
        //button.titleLabel = shownDoneTasks ? "Показать" : "Скрыть"
        button.setTitle("Показать", for: .normal)
        button.setTitle("Скрыть", for: .disabled)
        button.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 15)
        button.setTitleColor(.init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0), for: .normal)
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
