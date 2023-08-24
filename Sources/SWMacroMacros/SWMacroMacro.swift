import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SWMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        UnwrapMacro.self,
        SingleTonMacro.self,
        PublicMemberwiseInitMacro.self,
        URLMacro.self,
        AssociatedObjectMacro.self,
        DictionaryStorageMacro.self,
        DictionaryAccessorMacro.self,
        CodeableMacro.self,
        CodingKeyMacro.self,
    ]
}
