# RawText

A lightweight Windows VBScript that uploads a companion data file to a public raw-paste host and copies the returned URL to the clipboard.

Default host: **[paste.c-net.org](https://paste.c-net.org/)**  
(API is a simple raw POST; response is a plain HTTPS link to the uploaded content.)

## What it does

1. **Finds the companion file** — same base name as the `.vbs`, any other extension.
2. **Uploads the file** as raw binary via `WinHttp.WinHttpRequest.5.1`.
3. **Copies the URL** to the clipboard on success.
4. **Shows a message box** for success or failure (no console window).

## Workspace layout

Place the script and the data file in the same folder. Base names must match; extensions must differ.

```
workspace_folder/
 ├── MyLog.vbs          ← the script (rename as needed)
 └── MyLog.txt          ← the payload (any extension)
```

## Usage

1. Rename `pasters.vbs` and your data file so they share the same base name  
   (example: `Report.vbs` + `Report.log`).
2. Double-click the `.vbs` file.
3. On success: message box with the URL; the link is already on the clipboard (`Ctrl+V`).
4. On failure: message box with the reason (missing companion file, read error, network error, or non-URL response).

## Configuration

At the top of the script:

```
Const SERVER = "https://paste.c-net.org/"
```

Change `SERVER` to another raw-POST host if needed (must accept a binary body and return a URL starting with `http`).

Optional alternate:

```
Const SERVER = "https://pst.rs.abhicracker.com/"
```

## Requirements

- Windows with VBScript / WScript
- Outbound HTTPS access to the paste host
- No extra software install

## Notes

- Dialog title: **RawText**
- User-Agent: `RawText-vbs/2.2`
- Success: HTTP 200 or 201, response body starting with `http`
- Upload size limits and uptime depend on the public host
