//
// Created by Yongwoo Lee on 2020/12/17.
//

import Foundation
import UIKit

class FragmentConfig {
    static let titleHeight: CGFloat = 20
    static let verticalMargin: CGFloat = 30
    static let contentMarginTop: CGFloat = 20
    static let warningTextMarginTop: CGFloat = 5
    static let confirmButtonMarginTop: CGFloat = 20
    static let confirmButtonHeight: CGFloat = 40

    static let textFieldCornerRadius: CGFloat = 8.0

    static let transition: CATransition = {
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.duration = 0.3
        return transition
    }()
}