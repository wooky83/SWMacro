import SWMacro
import Foundation

let a = 17
let b = 25



let (result, code) = #stringify(a + b)
print("The value \(result) was produced by the code \"\(code)\"")

let optionalValue: Int? = 5
let unwrapValue = #unwrap(optionalValue, message: "❌")

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

let url = #URL("http://www.naver.com")

class AssociatedClass { }

extension AssociatedClass {
    @AssociatedObject(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    var intValue: Int

    @AssociatedObject(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    var arrayValue: Array<Int>
}

let asClass = AssociatedClass()
asClass.intValue = 83
print("AssociatedClass", asClass.intValue)
