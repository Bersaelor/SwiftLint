//
//  NoBlankFirstClosureLineRule.swift
//  SwiftLint
//
//  Created by Konrad Feiler on 07/05/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct NoBlankFirstClosureLineRule: ConfigurationProviderRule, Rule, OptInRule {
    public var configuration = SeverityConfiguration(.warning)

    public init() {}

    public static let description = RuleDescription(
        identifier: "first_line_non_empty",
        name: "Non empty first line",
        description: "First line in method or closure should never be empty",
        kind: .style,
        nonTriggeringExamples: [
            "guard true else { return true }",
            "guard true else {\n return true\n}",
            "if true else {\n return true\n}",
            "method(name: String) {\n return name\n}",
            "method(name: String) { return name }",
            "[1, 2].map { $0 + 1 }",
            "[1, 2].map {\n $0 + 1\n}",
            "[1, 2].map { number in\n return number + 1 \n}"
        ],
        triggeringExamples: [
            "guard true else {\n↓\n return true\n}",
            "if true else {\n↓\n return true\n}",
            "method(name: String) {\n↓\n return name\n}",
            "[1, 2].map {\n↓\n $0 + 1\n}",
            "[1, 2].map { number in\n↓\n return number + 1 \n}"
        ]
    )

    private var patterns: [String] {
//        let spacingRegex = configuration.flexibleRightSpacing ? "(?:\\s{0})" : "(?:\\s{0}|\\s{2,})"

        return ["\\{" +     // Capture an opening bracket
            "\\s*" +        // followed by any amount of whitespace
            "\n" +          // first linebreak
            "\\s*" +        // followed by any amount of whitespace
            "\n",           // second linebreak

            "\\{" +         // Capture an opening closure bracket
            "[^\n]+" +      // anything in between but a linebreak
            "\\bin\\b" +    // match exactly the word 'in' at the end of the parameter list
            "\\s*" +        // followed by any amount of whitespace
            "\n" +          // first linebreak
            "\\s*" +        // followed by any amount of whitespace
            "\n"            // second linebreak
        ]
    }

    public func validate(file: File) -> [StyleViolation] {
        return patterns.flatMap { pattern -> [StyleViolation] in
            return file.match(pattern: pattern).flatMap { range, _ in

                let contents = file.contents.bridge()
                let match = contents.substring(with: range)
                let idx = match.lastIndex(of: "\n") ?? 0
                let location = idx + range.location

                return StyleViolation(ruleDescription: type(of: self).description,
                                      severity: configuration.severity,
                                      location: Location(file: file, characterOffset: location))
            }
        }
    }
}
