import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        sleep(3)

        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstIndexText = app.staticTexts["Index"].label
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondIndexText = app.staticTexts["Index"].label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(firstIndexText, "1/10")
        XCTAssertEqual(secondIndexText, "2/10")
    }
    
    func testNoButton() {
        sleep(3)

        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstIndexText = app.staticTexts["Index"].label
        
        app.buttons["No"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondIndexText = app.staticTexts["Index"].label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(firstIndexText, "1/10")
        XCTAssertEqual(secondIndexText, "2/10")
    }
    
    func testEndGameAlert() {
        sleep(3)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.exists)
        XCTAssertEqual("Этот раунд окончен!", alert.label)
        
        let button = alert.buttons.firstMatch
        XCTAssertTrue(button.exists)
        XCTAssertEqual("Сыграть ещё раз", button.label)
        
        button.tap()
        sleep(3)
            
        let index = app.staticTexts["Index"]
        XCTAssertTrue(index.exists)
        XCTAssertEqual(index.label, "1/10")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
