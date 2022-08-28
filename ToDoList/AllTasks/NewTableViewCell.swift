import UIKit

final class NewTableViewCell: UITableViewCell {

    static let identifier = "NewTableViewCell"
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.Back.secondaryElevated
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelDeadlineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Новое"
        label.textColor = Constants.Colors.Label.tertiary
        label.backgroundColor = .clear
        label.font = Constants.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func drawSelf() {
        
        contentView.backgroundColor = .white
        self.contentView.addSubview(backView)
        let leftBV = backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        let rightBV = backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        let topBV = backView.topAnchor.constraint(equalTo: self.contentView.topAnchor)
        let bottomBV = backView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        
        backView.addSubview(labelDeadlineStack)
        let leftStackConct = labelDeadlineStack.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 52)
        let rightStackConct = labelDeadlineStack.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -38.95)
        let topStackConst = labelDeadlineStack.topAnchor.constraint(equalTo: backView.topAnchor, constant: 16)
        let bottomStackConst = labelDeadlineStack.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -16)

        labelDeadlineStack.addArrangedSubview(label)
       
        NSLayoutConstraint.activate([leftBV, rightBV, topBV, bottomBV, leftStackConct, rightStackConct, topStackConst, bottomStackConst])
    }
}
