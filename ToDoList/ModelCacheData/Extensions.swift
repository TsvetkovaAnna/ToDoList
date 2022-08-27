//
//  Data+Extensions.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 14.08.2022.
//

import Foundation
import CocoaLumberjack
import UIKit

extension Data {
    func parseToItems() -> [ToDoItem]? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any]
            else { return nil }
            return ToDoItemList(dict).todoItems
        } catch {
            DDLogInfo(error)
        }
        
        return nil
    }
}

extension UIViewController {
    func handleResult(_ result: VoidResult, successCompletion: () -> Void) {
        switch result {
        case .failure(let error):
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        case .success:
            successCompletion()
        }
    }
}
