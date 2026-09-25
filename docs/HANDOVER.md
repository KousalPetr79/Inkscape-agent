# Project handover

## Mission

Build a safe, cross-platform agent that can inspect and control Inkscape comprehensively. Keep SVG/XML document logic platform-independent and isolate application communication behind transport adapters.

## Current state

Linux control has been verified against a running Inkscape AppImage through the session D-Bus.

Verified capabilities:

- discover the running `org.inkscape.Inkscape` service;
- invoke window actions such as `canvas-zoom-page`;
- replace the active document tree through the two-step `file-rebase` and `org.gtk.Application.Open` sequence;
- create and modify pages, guides, rectangles, and text through SVG/XML;
- observe the result immediately in the active Inkscape window.

The exact experiment and commands are recorded in [EXPERIMENT-2026-09-25.md](EXPERIMENT-2026-09-25.md).

## Important limitation

The current Linux prototype replaces the complete active SVG tree. It does not yet read unsaved live changes back from Inkscape. A rebase can therefore overwrite manual edits that have not been captured in the source SVG.

Use disposable documents or explicit backups only.

## Next task: Windows transport test

The Windows transport is unverified. On a Windows machine:

1. Clone this repository.
2. Record the Windows version, Inkscape version, and installation source.
3. Open a disposable document in Inkscape.
4. Confirm the command location:

   ```powershell
   Get-Command inkscape.com
   inkscape.com --version
   ```

5. Test a non-destructive active-window action:

   ```powershell
   inkscape.com --active-window --actions="canvas-zoom-page"
   ```

6. Run the prototype transport:

   ```powershell
   .\scripts\windows\rebase-active.ps1 `
     -SvgPath .\examples\a4-landscape-test.svg
   ```

7. Record all of the following:

   - command output and exit code;
   - whether the active document changed visibly;
   - whether a new window or document opened instead;
   - whether Inkscape Undo can revert the change;
   - any warnings or errors.

A zero exit code is not sufficient evidence. The visible document state must be verified.

## Decision after the Windows test

- If `--active-window` and `file-rebase` work reliably, implement a Windows CLI adapter.
- If they do not, prototype a standard Python/inkex Inkscape extension as the cross-platform bridge.
- Do not introduce GUI coordinate automation unless no semantic interface is available.

## Safety and repository rules

- The repository is public; never commit secrets, personal information, private paths, or confidential documents.
- Use English for all repository content and commit messages.
- Use synthetic test data only.
- Preserve user documents by default.
- Mark untested behavior explicitly.
- Read [AGENTS.md](../AGENTS.md) and [SECURITY.md](../SECURITY.md) before making changes.

## Recommended first files to read

1. [HANDOVER.md](HANDOVER.md)
2. [../README.md](../README.md)
3. [EXPERIMENT-2026-09-25.md](EXPERIMENT-2026-09-25.md)
4. [ARCHITECTURE.md](ARCHITECTURE.md)
5. [../scripts/windows/rebase-active.ps1](../scripts/windows/rebase-active.ps1)
