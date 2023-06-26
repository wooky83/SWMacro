import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DictionaryStorageMacro { }

extension DictionaryStorageMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {

        return []
    }
    
}
