//
//  TaskTableViewCell.swift
//  YaToDoList
//
//  Created by Anna Tsvetkova on 04.08.2022.
//

import UIKit

//protocol TaskTableViewCellDelegate: AnyObject {
//    func openCurrentTask()
//}

class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"
    
    //weak var delegate: TaskTableViewCellDelegate?
    
    //var taskModel = ToDoItem(dict: ToDoItem().json) //как привязать Модель?
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelDeadlineVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var labelExclamationHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fillProportionally
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Новое"
        label.textColor = .black//UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        label.backgroundColor = .clear
        label.font = UIFont(name: "SFProText-Regular", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var exclamationMark: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(systemName: "exclamationmark.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.withTintColor(.red, renderingMode: .alwaysOriginal)
//        image.tintColor = .red
        //image.sizeThatFits(CGSize(width: 13, height: 12)) //??
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var deadlineHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fillProportionally
        stack.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var calendarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .left
        image.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.withTintColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), renderingMode: .alwaysOriginal)
        //image.sizeThatFits(CGSize(width: 13, height: 12))
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        //label.text = "00.00.0000"
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        label.font = UIFont(name: "SFProText-Regular", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var circleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "circle")?.withTintColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), renderingMode: .alwaysOriginal)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var chevronButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.right")?.withTintColor(UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)), for: .normal)
        //button.addTarget(self, action: #selector(openTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    @objc private func openTask() {
//        print("shevron pushed")
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(with item: ToDoItem) {
        label.text = item.text
        //calendarImage.isHidden = deadlineLabel.text?.isEmpty
        deadlineLabel.text = item.deadline?.inString(withYear: false)
        exclamationMark.isHidden = !(item.importance == .important)
        guard let textDeadline = deadlineLabel.text else { return }
        calendarImage.isHidden = textDeadline.isEmpty
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
        let markHeight = exclamationMark.heightAnchor.constraint(equalToConstant: 30)
        labelExclamationHorizontalStack.addArrangedSubview(label)
        
        deadlineHorizontalStack.addArrangedSubview(calendarImage)
        deadlineHorizontalStack.addArrangedSubview(deadlineLabel)
        
//        backView.addSubview(label)
//        let leftlabelConct = label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 52)
//        let rightlabelConct = label.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 38.95)
//        let toplabelConst = label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 16)
//        let bottomlabelConst = label.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -16)
        
        backView.addSubview(chevronButton)
        let leftButtonConct = chevronButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16)
        let centerYButton = chevronButton.centerYAnchor.constraint(equalTo: backView.centerYAnchor)
        let widthButton = chevronButton.widthAnchor.constraint(equalToConstant: 6.95)
        let heightButton = chevronButton.heightAnchor.constraint(equalToConstant: 11.9)
        
        NSLayoutConstraint.activate([leftBV, rightBV, topBV, bottomBV, leftImageConct, centerYImage, widthImage, heightImage, leftStackConct, rightStackConct, topStackConst, bottomStackConst, leftButtonConct, centerYButton, widthButton, heightButton, markHeight].compactMap({ $0 }))
    }

}
