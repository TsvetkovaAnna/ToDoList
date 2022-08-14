//
//  MockData.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 14.08.2022.
//

import Foundation

class MockServer {
    
    static let mockServerDataString = "{\"list\":[{\"dateCreated\":1660492375.4800282,\"id\":\"7CE2115C-F940-4527-B35C-66D2642CA0F4\",\"text\":\"Dream\",\"deadline\":1660751575.480015,\"toDoDone\":false,\"importance\":\"low\"},{\"toDoDone\":false,\"dateCreated\":1660492375.4800329,\"id\":\"16DACD43-50E4-4705-8812-D54E27C5196E\",\"deadline\":1660924375.480031,\"text\":\"Work\"},{\"id\":\"AF97BEE5-EC8F-4696-969A-38294933FD7F\",\"text\":\"Sleep\",\"importance\":\"important\",\"deadline\":1661097175.4800339,\"toDoDone\":false,\"dateCreated\":1660492375.4800348}]}"
    
    static var mockServerData: Data? {
        mockServerDataString.data(using: .utf8)
    }
}
