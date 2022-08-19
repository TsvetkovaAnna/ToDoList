import UIKit
import CocoaLumberjack

protocol HeaderOutput: AnyObject { //хедер сообщает кому-то
    func toggleShown()
}

protocol HeaderInput: AnyObject { //хереду сообщает кто-то
    func setShowHide(_ isShown: Bool)
    func setDonesCount(_ count: Int)
}

final class HeaderListView: UIView {

    var delegate: HeaderOutput?
    
    private lazy var doneLabelButtonHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        //stack.alignment = .center
        stack.distribution = .equalCentering
        stack.backgroundColor = Constants.Colors.Back.primary
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.subhead
        label.textColor = Constants.Colors.Label.tertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isShown = true
    
    private lazy var showHideDoneTasksButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.Fonts.subheadBold
        button.setTitleColor(Constants.Colors.Color.blue, for: .normal)
        button.addTarget(self, action: #selector(showHideDone), for: .touchUpInside)
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
    
    func setShowHideButton(_ isShown: Bool? = nil) {
        let isShown = isShown ?? self.isShown
        showHideDoneTasksButton.setTitle(isShown ? "Скрыть" : "Показать", for: .normal)
    }
    
    @objc private func showHideDone() {
        isShown.toggle()
        // setShowHideButton()
        delegate?.toggleShown()
        DDLogInfo("Show tapped")
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
        
        setShowHideButton()
    }
}

extension HeaderListView: HeaderInput {
    
    func setShowHide(_ isShown: Bool) {
        setShowHideButton(isShown)
    }
    
    func setDonesCount(_ count: Int) {
        doneCountLabel.text = "Выполнено - " + String(count)
    }
}
