//
//  NetworkError.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 21.08.2022.
//

import Foundation

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
