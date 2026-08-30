# RawText

A lightweight Windows VBScript that uploads a companion file to a public raw-paste service and copies the returned URL to the clipboard.

**Default server:** `https://paste.rs/`

## What it does

1. Finds a companion file in the same directory with the **same base name** as the script but a different extension.
2. Reads that file as raw bytes.
3. Uploads the bytes with an HTTP `POST` request.
4. Copies the returned URL to the Windows clipboard.
5. Shows a success or error message box.

The script runs through WScript, so no console window is required.

## Workspace layout

Place the script and the file to upload in the same folder. Their base names must match.

```text
workspace_folder/
├── MyFile.vbs
└── MyFile.txt
```

For example, if the script is renamed to `Report.vbs`, it will look for the first non-VBS file in the same folder whose base name is `Report`, such as `Report.log` or `Report.txt`.

## Usage

1. Place `RawText.vbs` beside the file you want to upload.

2. Rename both files so they have the same base name.

   Example:

   ```text
   Report.vbs
   Report.log
   ```

3. Double-click the `.vbs` file.

4. On success, the returned URL is:

   * shown in a message box
   * copied to the clipboard automatically

## Configuration

The upload endpoint is defined at the top of the script:

```vbscript
Const SERVER = "https://paste.rs/"
```

You can change `SERVER` to another compatible endpoint if it:

* accepts an HTTP `POST` body containing the file bytes
* returns the resulting URL as plain text
* returns a URL beginning with `http`

## Requirements

* Windows
* VBScript / Windows Script Host
* Outbound HTTPS access to the configured server
* No additional installation required

## Technical details

* HTTP client: `WinHttp.WinHttpRequest.5.1`
* File reader: `ADODB.Stream`
* Request content type: `text/plain`
* User-Agent: `RawText-vbs/2.3`
* Success status codes: HTTP `200` or `201`
* The response must begin with `http`
* Network timeouts:

  * Resolve: 15 seconds
  * Connect: 15 seconds
  * Send: 60 seconds
  * Receive: 60 seconds

### Clipboard handling

The script first attempts to copy the URL using PowerShell's `Set-Clipboard`. If that fails, it falls back to the Windows `clip` command.

## Error handling

RawText reports failures through message boxes for:

* a missing companion file
* failure to read the file
* network errors
* unsuccessful HTTP responses
* responses that do not contain a URL

## Notes

* Only the first matching non-VBS companion file found in the directory is uploaded.
* The configured paste service is responsible for storage, retention, availability, and upload-size limits.
* Uploaded content is sent to the configured public service. Do not use it for sensitive data unless you understand and accept that service's privacy and retention policies.
