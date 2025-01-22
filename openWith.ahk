#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance

; Registry paths
RegPath := "HKEY_CURRENT_USER\SOFTWARE\Classes\"
AppRegPath := RegPath . "Applications\nvim.exe\"

; Application details for Neovim in Windows Terminal
AppName := "Edit with Neovim"
WTPath := "wt.exe"  ; Windows Terminal executable

; We're creating an 'app' of nvim that is not a Windows install of Neovim. it's a bash command
NvimPath := "nvim.exe"
; Didn't get this working yet.
IconPath := NvimPath . ", 0"

; *** HOW THIS WORKS *** ;
; Works on Windows 10/11
;
; Assumption: Default WT profile is appropriate. I've tested with Ubuntu, cmd, and bash
;   - Add '--profile {name}'to specify
; WT will open according to your settings. I use:
;   - New instance behaviour = Attach to most recently used window. This seems to help
;     with speed.
;   - When Terminal Starts = Open a new tab with the default profile.
;
; What's happening:
; 1. Call the Windows Terminal .exe
; 2. Pass args of `new-tab` and `-d`.
;    - The %L var, which is the full path context of the call
;    - %L\.. gets the parent dir of the file selected
; 3. Call the wsl exe
;    - Assumes wsl is on the path
;    - `-e` tells wsl to execute the following command
; 4. Call bash
;    - `-c` lets us pass a bash script as a string
; 5. %L uses Windows style pathing that is not compatible with bash.
;    - Process it with sed to isolate the filename. This cannot be gotten any other way
;      as a 1-liner that can be used in the bash -c string.
;    - The sed command removes everything prior to the final `\` and replaces it with
;      `:e `. This gets passed to the nvim call
; 6. Pass the `:e {filename}` string to nvim -s -
;    -s tells nvim to read stdin in normal mode.
;    - `-` tells nvim to take input from stdin
;
; Result:
;    - Launch WSL in the file's directory
;    - Call `nvim -s ":e {filename}"`

; Directories are easy. Just lauch in the working dir
DirCmd := WTPath . ' new-tab  -d %L wsl -e bash -c "nvim $(pwd)"'

; Files are less so.
; The whole variable just needs to be a single string exactly like this:
; wt.exe new-tab -d %L\.. wsl -e bash -c "echo  '%L' | sed 's_\(.*\)\\_:e _g' | nvim -s -"
FileCmd := WTPath . " new-tab -d %L\.. wsl -e bash -x -c " . '"' . "echo  '%L' | sed 's_\(.*\)\\_:e _g' | nvim -s -" . '"'

; This is the list of extensions that will open with a double-click
; List of text file extensions to associate
; Thanks Claude lol
TextExtensions := [
    ; Text and Documentation
    ".txt", ".log", ".ini", ".cfg", ".conf", ".md", ".markdown", ".rst", ".adoc",
    ".tex", ".ltx", ".org", ".wiki", ".dokuwiki", ".mediawiki", ".man",

    ; Web and Styling
    ".json", ".yml", ".yaml", ".xml", ".css", ".scss", ".less", ".sass", ".styl",
    ".htm", ".html", ".xhtml", ".svg", ".wasm", ".vue", ".svelte",

    ; JavaScript/TypeScript
    ".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs", ".d.ts", ".coffee", ".flow",

    ; Other Programming Languages
    ".py", ".rb", ".php", ".pl", ".java", ".kt", ".kts", ".scala", ".go", ".rs",
    ".cpp", ".c", ".h", ".hpp", ".cs", ".fs", ".fsx", ".elm", ".erl", ".ex",
    ".exs", ".dart", ".swift", ".m", ".mm", ".r", ".jl", ".clj", ".cljs", ".ahk"

    ; Shell and Scripts
    ".sh", ".bash", ".zsh", ".fish", ".ps1", ".bat", ".cmd", ".vbs", ".lua",
    ".tcl", ".awk", ".sed",

    ; Configuration and Data
    ".gitignore", ".env", ".sql", ".rmd", ".qmd", ".plsql", ".toml", ".properties",
    ".plist", ".inf", ".reg", ".ahk", ".csv", ".tsv",

    ; Build and Project Files
    ".cmake", ".make", ".mk", ".rake", ".gradle", ".ant", ".maven",
    ".project", ".classpath", ".csproj", ".vbproj", ".vcxproj", ".sln",

    ; Container and Deploy
    ".dockerfile", ".dockerignore", ".nomad", ".tf", ".tfvars", ".hcl",

    ; General Purpose
    ".bak", ".tmp", ".temp", ".cache", ".lock"
]

; Each of the following functions edits a different part of the registry.
; It  could probably be consolidated a lot, but I don't know much about how the regirsty
; works really. Just what I've read and fiddled with personally.

; Helper function to check if registry key exists
RegKeyExist(key) {
    try {
        RegRead(key)
        return true
    } catch Error {
        return false
    }
}

; Register our fake Neovim as an application
RegisterNeovimApp() {
    try {
        ; Create application registration
        if !RegKeyExist(AppRegPath)
            RegCreateKey AppRegPath

        ; Set up default icon
        iconKey := AppRegPath . "DefaultIcon"
        if !RegKeyExist(iconKey)
            RegCreateKey iconKey
        RegWrite IconPath, "REG_SZ", iconKey

        ; Set up shell command
        shellKey := AppRegPath . "shell\open\command"
        if !RegKeyExist(shellKey)
            RegCreateKey shellKey
        command := FileCmd
        RegWrite command, "REG_SZ", shellKey

        return true
    } catch Error as err {
        MsgBox "Error registering Neovim app: " . err.Message
        return false
    }
}

; Associate file type with Neovim
AssociateFileType(extension) {
    try {
        ; Create file type registration
        extKey := RegPath . extension
        if !RegKeyExist(extKey)
            RegCreateKey extKey

        ; Set default program to Neovim
        RegWrite "nvim.exe", "REG_SZ", extKey, "PerceivedType"
        RegWrite "Applications\nvim.exe", "REG_SZ", extKey . "\OpenWithProgids"

        ; Set up context menu
        shellKey := extKey . "\shell\" . AppName
        if !RegKeyExist(shellKey)
            RegCreateKey shellKey

        ; Set display name and icon
        RegWrite AppName, "REG_SZ", shellKey, "MUIVerb"

        ; Create command key
        cmdKey := shellKey . "\command"
        if !RegKeyExist(cmdKey)
            RegCreateKey cmdKey

        command := FileCmd
        RegWrite command, "REG_SZ", cmdKey

        return true
    } catch Error as err {
        MsgBox "Error associating " . extension . ": " . err.Message
        return false
    }
}

; Also open files with no extension.
RegisterForNoExtension() {
    try {
        ; Define Unknown registry path
        unknownKey := RegPath . "Unknown"

        ; Create the Unknown key if it doesn't exist
        if !RegKeyExist(unknownKey)
            RegCreateKey unknownKey

        ; Set the default description
        RegWrite "File without extension", "REG_SZ", unknownKey

        ; Set the default icon
        iconKey := unknownKey . "\DefaultIcon"
        if !RegKeyExist(iconKey)
            RegCreateKey iconKey
        RegWrite IconPath, "REG_SZ", iconKey

        ; Create the shell command for opening files
        shellKey := unknownKey . "\shell\open\command"
        if !RegKeyExist(shellKey)
            RegCreateKey shellKey
        command := FileCmd
        RegWrite command, "REG_SZ", shellKey

        ; Set default handler for no-extension files
        RegWrite "open", "REG_SZ", unknownKey . "\shell"

        return true
    } catch Error as err {
        MsgBox "Error registering for no extension files: " . err.Message
        return false
    }
}

AddDirectoryContextMenu() {
    try {
        ; Define the registry path for directories context menu
        dirKey := RegPath . "Directory\shell\" . AppName

        ; Create the registry key if it doesn't exist
        if !RegKeyExist(dirKey)
            RegCreateKey dirKey

        ; Set display name
        RegWrite "Open directory in NeoVim", "REG_SZ", dirKey, "MUIVerb"

        ; Set icon for the context menu item
        iconKey := dirKey . "\DefaultIcon"
        if !RegKeyExist(iconKey)
            RegCreateKey iconKey
        RegWrite IconPath, "REG_SZ", iconKey

        ; Set position to appear prominently
        RegWrite "Top", "REG_SZ", dirKey, "Position"

        ; Set the command for the context menu
        commandKey := dirKey . "\command"
        if !RegKeyExist(commandKey)
            RegCreateKey commandKey
        command := DirCmd
        RegWrite command, "REG_SZ", commandKey

        return true
    } catch Error as err {
        MsgBox "Error adding directory context menu: " . err.Message
        return false
    }
}

AddGlobalContextMenu() {
    try {
        ; Define the registry path for all files context menu
        globalKey := RegPath . "*\shell\" . AppName

        ; Create the registry key if it doesn't exist
        if !RegKeyExist(globalKey)
            RegCreateKey globalKey

        ; Set display name
        RegWrite AppName, "REG_SZ", globalKey, "MUIVerb"

        ; Set icon for the context menu item
        iconKey := globalKey . "\DefaultIcon"
        if !RegKeyExist(iconKey)
            RegCreateKey iconKey
        RegWrite IconPath, "REG_SZ", iconKey

        ; Set position to appear prominently
        RegWrite "Top", "REG_SZ", globalKey, "Position"

        ; Set the command for the context menu
        commandKey := globalKey . "\command"
        if !RegKeyExist(commandKey)
            RegCreateKey commandKey
        command := FileCmd
        RegWrite command, "REG_SZ", commandKey

        return true
    } catch Error as err {
        MsgBox "Error adding global context menu: " . err.Message
        return false
    }
}

runOpenWithConfigurator(){
    if RegisterNeovimApp()
	MsgBox "Application registered successfully!"

    if RegisterForNoExtension()
        MsgBox "Neovim successfully registered for files with no extension."

    if AddDirectoryContextMenu()
       MsgBox "Neovim directory context menu added successfully."

    if AddGlobalContextMenu()
        MsgBox "Neovim global context menu added successfully."

    ; Associate all text file types
    successCount := 0
    for ext in TextExtensions {
        if AssociateFileType(ext)
            successCount++
    }
    MsgBox "Successfully associated " . successCount . " of " . TextExtensions.Length . " file types with Neovim."
}

