
import XCTest
@testable import ToDoList

class ToDoListTests: XCTestCase {
    
    func testAddFunc() {
        let math = MathFunc()
        
        let result = math.addNumb(x: 1, y: 2)
        XCTAssertEqual(result, 3)
    }
    
    func testMultipleFunc() {
        let math = MathFunc()
        
        let result = math.multipleNumb(x: 2, y: 3)
        XCTAssertEqual(result, 6)
    }
    
    func testdivideFunc() {
        let math = MathFunc()
        
        let result = math.divideNumb(x: 10, y: 2)
        XCTAssertEqual(result, 5)
    }

//    override func setUpWithError() throws {
//        // перед тестом Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // после теста Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
