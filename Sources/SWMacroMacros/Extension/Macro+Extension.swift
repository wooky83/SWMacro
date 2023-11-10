import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal enum MacroError: Swift.Error, CustomStringConvertible {
    case invalidInputType
    case message(String)

    var description: String {
      switch self {
      case .invalidInputType:
          return "only applicable to structs or classes"
      case .message(let text):
        return text
      }
    }
}

extension VariableDeclSyntax {
    var isStoredProperty: Bool {
        guard let binding = bindings.first, bindings.count == 1, !isLazyProperty, !isConstant else {
            return false
        }
        guard let _ = binding.accessorBlock else { return true }
        // TODO - Should Fix
        return false
    }

    var isLazyProperty: Bool {
        modifiers.contains { $0.name.tokenKind == .keyword(Keyword.lazy) } 
    }

    var isConstant: Bool {
        bindingSpecifier.tokenKind == .keyword(Keyword.let) && bindings.first?.initializer != nil
    }

    var getNameAndType: (name: String, type: String)? {
        guard let patternBinding = bindings.first?.as(PatternBindingSyntax.self) else { return nil }
        guard let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name else {
            return nil
        }
        return (name: name.text, type: type.text)
    }
}


extension DeclGroupSyntax {
    /// Get the stored properties from the declaration based on syntax.
    func storedProperties() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty else {
                return nil
            }
            return variable
        }
    }

    var hasInitFunction: Bool {
        memberBlock
            .members
            .contains { member in
                guard let function = member.decl.as(InitializerDeclSyntax.self) else {
                    return false
                }
                return true
            }
    }
}

extension AttributeListSyntax {
    func getAttributedElement(_ macroName: String) -> AttributeListSyntax.Element? {
        self.first {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .description == macroName
        }
    }
}

extension AttributeListSyntax.Element {
    func getExprSyntax(_ argumentName: String? = nil) -> ExprSyntax? {
        if let argumentName {
            self
                .as(AttributeSyntax.self)?
                .arguments?
                .as(LabeledExprListSyntax.self)?
                .first(where: {
                    $0.label?.text == argumentName
                })?
                .expression
        } else {
            self
                .as(AttributeSyntax.self)?
                .arguments?
                .as(LabeledExprListSyntax.self)?
                .first?
                .expression
        }
    }
}

