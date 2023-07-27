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


//@OptionSet<UInt8>
//struct ShippingOptions {
//  private enum Options: Int {
//    case nextDay
//    case secondDay
//    case priority
//    case standard
//  }
//}

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

@DictionaryStorage
struct MyPoint {
    var x: Int? = nil
    var y: Int = 2
}

var dictionaryStorage = MyPoint()
print(dictionaryStorage._storage)
dictionaryStorage.x = 5
print(dictionaryStorage._storage)


@CodingKeys
struct MyPerson {
    let id: String
    @CodingKeys(key: "_age")
    let age: Int
    let use: MyUse
    @CodingKeys
    struct MyUse {
        @CodingKeys(key: "_favorite")
        let favorite: String
    }
}

let jsonString =
"""
{
    "id" : "wow",
    "_age" : 25,
    "use" : { "_favorite": "movie" }
}
"""

let decoder = JSONDecoder()
var data = jsonString.data(using: .utf8)
if let data = data, let myPerson = try? decoder.decode(MyPerson.self, from: data) {
    print(myPerson.id)
    print(myPerson.age)
    print(myPerson.use.favorite)
}
