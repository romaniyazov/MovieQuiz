import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        // Given
        let numbers = [0, 1, 2, 3]
        
        // When
        let number = numbers[safe: 2]
        
        // Then
        XCTAssertNotNil(number)
        XCTAssertEqual(number, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let numbers = [0, 1, 2, 3]
       
        // When
        let number = numbers[safe: 4]
       
        // Then
        XCTAssertNil(number)
    }
}
