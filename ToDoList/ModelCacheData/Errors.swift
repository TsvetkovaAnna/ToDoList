//
//  NetworkError.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 21.08.2022.
//

import Foundation

enum CacheError: Error {
    case fetchError
    case noDelegate
    case badParameters
    case noItem
    case noStoreURL
}
enum NetworkError: Error {
    case incorrectUrl
    case incorrectToken
    case itemEncodeProblem
    case unknownError
    case serviceError(_ statusCode: Int)
    case notFound
    case itemDecoding
    case noConnection
    case badParsing
}
