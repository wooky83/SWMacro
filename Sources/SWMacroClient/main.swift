import SWMacro
import Foundation

let a = 17
let b = 25

let optionalValue: Int? = 5

let (result, code) = #stringify(a + b)
print("The value \(result) was produced by the code \"\(code)\"")

let unwrapValue = #unwrap(optionalValue, message: "Fail")
print("wrapped : \(unwrapValue)")

@SingleTon
class MySingleTone {
    var variable1: Int?
    var variable2: Int?
}

let number: Int? = 6
let unWrap = #unwrap(number, message: "fail")

@OptionSet<UInt>
struct ShippingOptions {
    private enum Options: Int {
        case nextDay
        case secondDay
        case priority
        case standard
    }
}

#warning("Warning👆")
let warning = 10

@publicMemberwiseInit
class MemberWiseInit {
    let intType: Int
    var stringType: Bool
}

let url1 = #URL("http://www.naver.com")

