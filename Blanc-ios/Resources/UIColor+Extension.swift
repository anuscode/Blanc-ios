import Foundation
import UIKit

extension UIColor {

    static let red1: UIColor = UIColor(hexCode: "f40145")

    static let kakaoTalk: UIColor = UIColor(red: 254 / 255, green: 229 / 255, blue: 0 / 255, alpha: 1)
    static let kakaoBrown: UIColor = UIColor(red: 71 / 255, green: 42 / 255, blue: 43 / 255, alpha: 1)

    // pink
    static let tinderPink: UIColor = UIColor(hexCode: "F82E69")
    static let primaryPink: UIColor = UIColor(hexCode: "FE036B")
    static let babyPink: UIColor = UIColor(hexCode: "ff1493")

    // yellow
    static let bumble0: UIColor = UIColor(hexCode: "FEE9BB")
    static let bumble1: UIColor = UIColor(hexCode: "FFCD5B")
    static let bumble2: UIColor = UIColor(hexCode: "FFCB37")
    static let bumble3: UIColor = UIColor(hexCode: "FFB100")
    static let bumble4: UIColor = UIColor(hexCode: "FF9D00")
    static let bumble5: UIColor = UIColor(hexCode: "FF8C00")

    static let slateYellow: UIColor = UIColor(hexCode: "d7ac40")

    // blue
    static let lightFaceBook: UIColor = UIColor(hexCode: "#0088CC")
    static let faceBook: UIColor = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1.0)
    static let silverBlue: UIColor = UIColor(hexCode: "E0E0E8")
    static let darkSilverBlue: UIColor = UIColor(hexCode: "909098")
    static let navyBlue: UIColor = UIColor(hexCode: "00008b")
    static let slateBlue: UIColor = UIColor(hexCode: "737CA1")
    static let steelBlue: UIColor = UIColor(hexCode: "4863A0")
    static let darkNavy: UIColor = UIColor(hexCode: "323651")

    // black
    static let black0: UIColor = UIColor(hexCode: "#0F0F0F")
    static let black1: UIColor = UIColor(hexCode: "#1F1F1F")
    static let black2: UIColor = UIColor(hexCode: "#2F2F2F")
    static let black3: UIColor = UIColor(hexCode: "#3F3F3F")
    static let black4: UIColor = UIColor(hexCode: "#4F4f4F")
    static let customBlack1: UIColor = UIColor(hexCode: "000000")
    static let customBlack2: UIColor = UIColor(hexCode: "030303")
    static let customBlack3: UIColor = UIColor(hexCode: "191919")
    static let customBlack4: UIColor = UIColor(hexCode: "252525")
    static let userCardGradientBlack: UIColor = UIColor(hexCode: "181818")

    // gray
    static let deepGray: UIColor = UIColor(hexCode: "#4D4D4D")
    static let customGray0: UIColor = UIColor(hexCode: "EFEFEF")
    static let customGray1: UIColor = UIColor(hexCode: "CDCDCD")
    static let customGray2: UIColor = UIColor(hexCode: "A6A6A6")
    static let customGray3: UIColor = UIColor(hexCode: "999999")
    static let customGray4: UIColor = UIColor(hexCode: "666666")
    static let customGray5: UIColor = UIColor(hexCode: "606266")
    static let customGray6: UIColor = UIColor(hexCode: "606060")
    static let customGray7: UIColor = UIColor(hexCode: "5F6267")
    static let customGray8: UIColor = UIColor(hexCode: "585858")
    static let slateGray: UIColor = UIColor(hexCode: "657383")

    static var lightBlue: UIColor {
        return UIColor(red: 0, green: 184 / 255, blue: 1.0, alpha: 1.0)
    }

    static let thirdlySystemBackground: UIColor = UIColor(hexCode: "f9faf9")

    static func random() -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: .random(in: 0...1))
    }
}