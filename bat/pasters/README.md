# pasters

A lightweight Windows utility that dynamically streams the binary contents of any companion data file in the same directory directly to an external raw text host, copying the resulting web link directly onto the system clipboard.

It executes completely in the background via a hidden instance of PowerShell—preventing command-line window flashes—and handles status tracking purely through native Windows Desktop toast notifications.

## 📁 Workspace Structure

To use this utility, place it inside its own workspace directory alongside a single target data payload. **You must rename the `.bat` file to have the exact same base name as the target file.** 

The specific extension of your data file does not matter, as long as the base names match perfectly.

```text
📁 workspace_folder/
 ├── pasters.bat
 └── pasters.<any_extension>
```

## 🚀 Usage

- **Setup:** Rename `pasters.bat` and your target file to any matching name of your choice (e.g., `Diagnostic.bat` and `Diagnostic.txt`).
- **Execution:** Double-click or trigger the `.bat` script.
- **Success:** A native system toast notification alerts you that the pipeline succeeded. Press `Ctrl + V` anywhere to share the direct, raw data web link.
- **Failure:** A warning toast notification reports whether the sibling data payload could not be located or if a network communication timeout occurred.
