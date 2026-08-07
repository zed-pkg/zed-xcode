import Foundation

public struct ZedPackageSnapshot: Sendable, Equatable {
    public let root: String
    public let errors: Int
    public let warnings: Int
    public let issues: [ZedIssue]

    public init(root: String, errors: Int, warnings: Int, issues: [ZedIssue]) {
        self.root = root
        self.errors = errors
        self.warnings = warnings
        self.issues = issues
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.root == rhs.root && lhs.errors == rhs.errors && lhs.warnings == rhs.warnings && lhs.issues.map(\.id) == rhs.issues.map(\.id)
    }
}

public struct ZedActionPreview: Sendable, Equatable {
    public let executable: String
    public let arguments: [String]
    public let workingDirectory: String
    public let requiresConfirmation: Bool
}

public enum ZedWorkspaceModelError: Error, Equatable {
    case nonCommandAction
    case confirmationRequired
    case missingExecutable
}

public enum ZedWorkspaceModel {
    public static func project(_ reports: [ZedReport]) -> [ZedPackageSnapshot] {
        reports.map { report in
            let errors = report.issues.filter { $0.severity.lowercased() == "error" }.count
            let warnings = report.issues.filter { $0.severity.lowercased() == "warning" }.count
            return ZedPackageSnapshot(
                root: URL(fileURLWithPath: report.workspaceRoot).standardizedFileURL.path,
                errors: errors,
                warnings: warnings,
                issues: report.issues
            )
        }.sorted { $0.root < $1.root }
    }

    public static func preview(action: ZedAction, root: String) throws -> ZedActionPreview {
        guard action.kind == "command" else { throw ZedWorkspaceModelError.nonCommandAction }
        guard action.requiresConfirmation else { throw ZedWorkspaceModelError.confirmationRequired }
        guard !action.command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ZedWorkspaceModelError.missingExecutable }
        return ZedActionPreview(
            executable: action.command,
            arguments: action.arguments,
            workingDirectory: URL(fileURLWithPath: root).standardizedFileURL.path,
            requiresConfirmation: true
        )
    }
}
