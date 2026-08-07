import Foundation
import Testing
@testable import ZedCore

@Test func projectsMultiRootReportsInStableOrder() {
    let reports = [
        ZedReport(schemaVersion: 1, workspaceRoot: "/zeta", zedVersion: "0.1", issues: [
            ZedIssue(id: "lock.stale", severity: "warning", title: "Stale", detail: "", files: [], actions: [])
        ]),
        ZedReport(schemaVersion: 1, workspaceRoot: "/alpha", zedVersion: "0.1", issues: [
            ZedIssue(id: "manifest.invalid", severity: "error", title: "Invalid", detail: "", files: [], actions: [])
        ])
    ]
    let snapshots = ZedWorkspaceModel.project(reports)
    #expect(snapshots.map(\.root) == ["/alpha", "/zeta"])
    #expect(snapshots[0].errors == 1)
    #expect(snapshots[1].warnings == 1)
}

@Test func previewsOnlyConfirmationGatedCommands() throws {
    let action = ZedAction(id: "install", title: "Install", kind: "command", command: "zed", arguments: ["install"], requiresConfirmation: true)
    let preview = try ZedWorkspaceModel.preview(action: action, root: "/tmp/work")
    #expect(preview.executable == "zed")
    #expect(preview.arguments == ["install"])
    #expect(preview.requiresConfirmation)
    #expect(throws: ZedWorkspaceModelError.confirmationRequired) {
        try ZedWorkspaceModel.preview(
            action: ZedAction(id: "bad", title: "Bad", kind: "command", command: "zed", arguments: ["install"], requiresConfirmation: false),
            root: "/tmp/work"
        )
    }
}
