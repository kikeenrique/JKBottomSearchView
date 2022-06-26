import XCTest
@testable import JKBottomSearchView

final class JKBottomSearchViewTests: XCTestCase {

    var sut: JKBottomSearchView! = nil

    override func setUp() async throws {
        sut = await JKBottomSearchView()
    }

    func test_basic() throws {
        XCTAssertNotNil(sut.tableView, "")
    }
}
