//
//  Placeholderswift
//  YaToDoList
//
//  Created by Anna Tsvetkova on 07.08.2022.
//

import UIKit

class PlaceholderTextView: UITextView, UITextViewDelegate {
    
    var placeholder: String?
    var changedClosure: (() -> Void)?
    
    var isEmpty: Bool {
        text.isEmpty || isPlaceholderState
    }
    
    var isPlaceholderState: Bool {
        text == placeholder
    }
    
    init(with placeholder: String, text: String?, changedClosure: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.changedClosure = changedClosure
        super.init(frame: .zero, textContainer: nil)
        delegate = self
        text != nil ? setTextViewReady() : setTextViewPlaceholder()
        self.text = text ?? placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextViewReady() {
        if text == placeholder {
            text = ""
        }
        textColor = .black
    }
    
    func setTextViewPlaceholder() {
        text = placeholder
        textColor = .lightGray
        
        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
    }
    
    func checkForPlaceholder() {
        if text.isEmpty || text == placeholder {
            setTextViewPlaceholder()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        print(#function)
        if isPlaceholderState {
            setTextViewReady()
        }

        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        print(#function)
        checkForPlaceholder()
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text.count)
        !text.isEmpty ? setTextViewReady() : checkForPlaceholder()
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        print(#function)
        if isPlaceholderState {
            setTextViewPlaceholder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        checkForPlaceholder()
        changedClosure?()
    }
    
}
