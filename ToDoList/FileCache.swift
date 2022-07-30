////
////  FileCache.swift
////  ToDoList
////
////  Created by Anna Tsvetkova on 29.07.2022.
////
//
//import Foundation
//
//@discardableResult func parseFromFile1(pathForFile: String) -> [ToDoItem]? {
//
//    var d: Data?
//
//    do {
//        d = try Data(contentsOf: URL(fileURLWithPath: pathForFile))
//    } catch {
//        print("Error of getting Data \(error.localizedDescription)")
//    }
//
//    guard let data = d else {
//        print("Error - no data in file")
//        return nil
//    }
//
//    var dictionary = [String: Any]()
//
//    do {
//        guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//                print("Error to transform to [String: Any]")
//                return nil
//            }
//        dictionary = dict
//    } catch {
//        print("error of parsing: \(error.localizedDescription)")
//        return nil
//    }
//
//    guard let getArray = dictionary["list"] as? [[String: Any]] else {
//        print("error")
//        return nil
//    }
//
//    var arrayOfToDoItems = [ToDoItem]()
//    for item in getArray {
//        arrayOfToDoItems.append(ToDoItem(dict: item))
//    }
//    //print(dict)
//    return arrayOfToDoItems
//}
//
//func parseFromFile2(pathForFile: String) -> [ToDoItem] {
//    let data = try! Data(contentsOf: URL(fileURLWithPath: pathForFile))
//    let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//    let getArray = dict["id"] as! [[String: Any]]
//    var arrayOfToDoItems = [ToDoItem]()
//    for item in getArray {
//        arrayOfToDoItems.append(ToDoItem(dict: item))
//    }
//    return arrayOfToDoItems
//}
