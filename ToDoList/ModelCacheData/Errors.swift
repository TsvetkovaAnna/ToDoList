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

extension CacheError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fetchError:
            return NSLocalizedString("Ошибка получения локальных данных", comment: "CacheError")
        case .noDelegate:
            return NSLocalizedString("Делегат не найден", comment: "CacheError")
        case .badParameters:
            return NSLocalizedString("Неверные параметры", comment: "CacheError")
        case .noItem:
            return NSLocalizedString("Задача отсутствует", comment: "CacheError")
        case .noStoreURL:
            return NSLocalizedString("Локальный путь отсутствует", comment: "CacheError")
        }
    }
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

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectUrl:
            return NSLocalizedString("Неверный путь сети", comment: "NetworkError")
        case .incorrectToken:
            return NSLocalizedString("Неверный токен авторизации", comment: "NetworkError")
        case .itemEncodeProblem:
            return NSLocalizedString("Проблема записи задачи для сети", comment: "NetworkError")
        case .unknownError:
            return NSLocalizedString("Неизвестная ошибка", comment: "NetworkError")
        case .serviceError(let statusCode):
            return NSLocalizedString("Ошибка сервиса \(statusCode)", comment: "NetworkError")
        case .notFound:
            return NSLocalizedString("Не найден", comment: "NetworkError")
        case .itemDecoding:
            return NSLocalizedString("Проблема чтения задачи из сети", comment: "NetworkError")
        case .noConnection:
            return NSLocalizedString("Отсутствует соединение", comment: "NetworkError")
        case .badParsing:
            return NSLocalizedString("Плохой парсинг из сети", comment: "NetworkError")
        }
    }
}
