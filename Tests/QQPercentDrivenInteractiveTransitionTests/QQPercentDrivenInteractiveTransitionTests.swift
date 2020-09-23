import XCTest
@testable import QQPercentDrivenInteractiveTransition

final class QQPercentDrivenInteractiveTransitionTests: XCTestCase {

    func testInstantiation() {
        class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {

            func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
                return 0.18
            }

            func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
        }
        let transition = QQPercentDrivenInteractiveTransition(animator: CustomAnimator())

        XCTAssertEqual(transition.duration, 0.18)
        XCTAssertEqual(transition.percentComplete, 0)
    }

    static var allTests = [
        ("testInstantiation", testInstantiation),
    ]
}
