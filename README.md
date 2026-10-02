# VS Code Workspace Trust & Lifecycle Hooks Verification

This repository is an educational reference and diagnostic test case demonstrating how VS Code extensions handle lifecycle hooks in untrusted workspaces.

---

## Background: The VS Code Workspace Trust Model

VS Code provides [Workspace Trust](https://code.visualstudio.com/docs/editor/workspace-trust) ("Restricted Mode") as a core defensive boundary to protect developers when opening unvetted repositories.

In Restricted Mode (`vscode.workspace.isTrusted === false`):
- Automatic build tasks, debuggers, and unvetted workspace configurations are suppressed.
- Extensions are expected to restrict or disable features that automatically execute code defined inside the workspace root.

---

## Architectural Analysis: Cline Lifecycle Hooks

Cline supports workspace-level lifecycle hooks defined inside:
- `.clinerules/hooks/`
- `.cline/hooks/`

Supported hook events include:
- `TaskStart`
- `UserPromptSubmit`
- `PreToolUse`
- `PostToolUse`
- `TaskComplete`

In `apps/vscode/src/core/storage/disk.ts`, workspace hook directories are resolved via `getWorkspaceHooksDirs()` without evaluating `vscode.workspace.isTrusted`. When a task begins, `HookProcess` spawns the hook script using the host operating system shell.

---

## Test It Yourself (Controlled Verification)

This repository includes a benign demonstration hook to verify whether workspace lifecycle hooks execute while in Restricted Mode.

### Prerequisites
- VS Code
- Cline Extension installed

### Verification Steps

1. **Clone or Open this Repository**:
   Open this folder in VS Code.

2. **Select Restricted Mode**:
   When VS Code prompts *"Do you trust the authors of the files in this folder?"*, click:
   **"No, I do not trust the authors (Restricted Mode)"**.
   *(Verify that the blue/yellow shield icon indicates Restricted Mode in the bottom status bar.)*

3. **Initiate a Task in Cline**:
   Open the Cline sidebar panel and send any message (for example: `hello`).

4. **Observe the Result**:
   - On Windows: `.clinerules/hooks/TaskStart.ps1` executes via PowerShell, launching `calc.exe` and creating a diagnostic timestamp log in the local workspace directory.
   - On macOS/Linux: `.clinerules/hooks/TaskStart` executes via `/bin/sh`, creating a diagnostic log file.

---

## Recommended Defensive Remediation

To honor the VS Code Workspace Trust contract, extension developers should check trust state before discovering or executing workspace-level hooks:

```typescript
import * as vscode from "vscode";

export async function getWorkspaceHooksDirs(workspaceRootPaths?: string[]): Promise<string[]> {
    // Suppress repository-level hooks in untrusted workspaces
    if (!vscode.workspace.isTrusted) {
        return [];
    }
    workspaceRootPaths ??= await getWindowWorkspaceRoots();
    // Proceed with resolution...
}
```

Global user hooks (located outside the repository in `~/.cline/hooks/`) can safely remain active as they are configured directly by the workstation owner.
