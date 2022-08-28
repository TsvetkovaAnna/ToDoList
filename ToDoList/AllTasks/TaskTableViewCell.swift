import UIKit

enum CircleState {
    case notDone
    case done
    case passedDeadline
}

protocol TaskTableViewCellDelegate: AnyObject {
    func changeIsDone(_ indexPath: IndexPath?)
}

final class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"
    
    weak var delegate: TaskTableViewCellDelegate?
    
    var indexPath: IndexPath?
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.Back.secondaryElevated
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelDeadlineVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var labelExclamationHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        label.textColor = Constants.Colors.Label.primary
        label.backgroundColor = .clear
        label.font = Constants.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var exclamationMark: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = Constants.Images.exclamationmark
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var deadlineHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var calendarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .left
        image.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))?.withTintColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), renderingMode: .alwaysOriginal)
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.Colors.Label.tertiary
        label.font = Constants.Fonts.subhead
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func makeCircleImage(state: CircleState) -> UIImageView {
        let image = UIImageView()
        image.backgroundColor = Constants.Colors.Back.secondaryElevated
        image.tag = tag
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }
    
    private lazy var circleImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = Constants.Colors.Back.secondaryElevated
        image.image = Constants.Images.circleGray
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeIsDone)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var chevronImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .right
        image.image = Constants.Images.chevron
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(with item: ToDoItem, for indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        label.text = item.text
        deadlineLabel.text = item.deadline?.inString(withYear: false)
        exclamationMark.isHidden = !(item.importance == .important)
        
        var state: CircleState = .notDone
        
        if item.isDone {
            state = .done
        } else if let deadline = item.deadline, deadline < Date.now {
            state = .passedDeadline
        }
        
        switch state {
        case .passedDeadline:
            circleImage.image = Constants.Images.circleRed
        case .notDone:
            circleImage.image = Constants.Images.circleGray
        case .done:
            circleImage.image = Constants.Images.circleGreen
        }
        
        calendarImage.isHidden = item.deadline == nil
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
        
        backView.addSubview(circleImage)
        let leftImageConct = circleImage.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16)
        let centerYImage = circleImage.centerYAnchor.constraint(equalTo: backView.centerYAnchor)
        let widthImage = circleImage.widthAnchor.constraint(equalToConstant: 24)
        let heightImage = circleImage.heightAnchor.constraint(equalToConstant: 24)
        
        backView.addSubview(labelDeadlineVerticalStack)
        let leftStackConct = labelDeadlineVerticalStack.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 52)
        let rightStackConct = labelDeadlineVerticalStack.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -38.95)
        let topStackConst = labelDeadlineVerticalStack.topAnchor.constraint(equalTo: backView.topAnchor, constant: 16)
        let bottomStackConst = labelDeadlineVerticalStack.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -16)
        
        labelDeadlineVerticalStack.addArrangedSubview(labelExclamationHorizontalStack)
        labelDeadlineVerticalStack.addArrangedSubview(deadlineHorizontalStack)
        
        labelExclamationHorizontalStack.addArrangedSubview(exclamationMark)
        labelExclamationHorizontalStack.addArrangedSubview(label)
        
        deadlineHorizontalStack.addArrangedSubview(calendarImage)
        deadlineHorizontalStack.addArrangedSubview(deadlineLabel)
        
        backView.addSubview(chevronImage)
        let leftButtonConct = chevronImage.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16)
        let centerYButton = chevronImage.centerYAnchor.constraint(equalTo: backView.centerYAnchor)
        let widthButton = chevronImage.widthAnchor.constraint(equalToConstant: 6.95)
        let heightButton = chevronImage.heightAnchor.constraint(equalToConstant: 11.9)
        
        NSLayoutConstraint.activate([leftBV, rightBV, topBV, bottomBV, leftImageConct, centerYImage, widthImage, heightImage, leftStackConct, rightStackConct, topStackConst, bottomStackConst, leftButtonConct, centerYButton, widthButton, heightButton].compactMap({ $0 }))
    }
    
    @objc private func changeIsDone() {
        delegate?.changeIsDone(indexPath)
    }

}
