import SWMacro

let a = 17
let b = 25

let optionalValue: Int? = 5

let (result, code) = #stringify(a + b)
print("The value \(result) was produced by the code \"\(code)\"")

let directValue = #direct(optionalValue)
print("DirectValue : \(String(describing: directValue))")

let unwrapValue = #unwrap(optionalValue, message: "Fail")
print("wrapped : \(unwrapValue)")

@SingleTon
class MySingleTone {
    var variable1: Int?
    var variable2: Int?
}

let xx: Int? = 6
let x = #unwrap(xx, message: "fail")
