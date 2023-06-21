import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SWMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        DirectMacro.self,
        UnwrapMacro.self,
        SingleTonMacro.self,
        PublicMemberwiseInitMacro.self,
    ]
}
