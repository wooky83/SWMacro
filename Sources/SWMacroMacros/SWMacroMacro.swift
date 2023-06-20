import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct DirectMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "\(argument)"
    }
}

public struct UnwrapMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression, let message = node.argumentList.last?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        return """
        { [wrappValue = \(argument)] in
            guard let wrappValue else {
                preconditionFailure(\(message))
            }
            return wrappValue
        }()
        """
    }
}

public struct SingleTonMacro: MemberMacro {
    public static func expansion<Declaration, Context>(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: Declaration, in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard let clsDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let initializer = try InitializerDeclSyntax("private init()") { }
        return [DeclSyntax(initializer),
                "static let shared = \(clsDecl.identifier)()"
        ]
    }
}

@main
struct SWMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        DirectMacro.self,
        UnwrapMacro.self,
        SingleTonMacro.self,
    ]
}
