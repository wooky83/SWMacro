import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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
