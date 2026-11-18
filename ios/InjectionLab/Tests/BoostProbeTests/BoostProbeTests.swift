import XCTest
@testable import BoostProbe

final class BoostProbeTests: XCTestCase {
    func testModuleReportsExpectedIdentity() {
        let info = BoostProbe.diagnostics()
        XCTAssertEqual(info["module"], "RivalsBoost.BoostProbe")
        XCTAssertEqual(info["platform"], "iOS")
        XCTAssertEqual(info["status"], "loaded by the host app's normal signed framework loader")
    }

    func testSelfTest() {
        XCTAssertTrue(BoostProbe.selfTest())
    }
}
