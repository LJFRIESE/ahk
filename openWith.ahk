#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance

; Registry paths
RegPath := "HKEY_CURRENT_USER\SOFTWARE\Classes\"
AppRegPath := RegPath . "Applications\nvim.exe\"

; Application details for Neovim in Windows Terminal
AppName := "Edit with Neovim"
WTPath := "wt.exe"  ; Windows Terminal executable

; This would be to use the Windows install of nvim. Probably don't combine this with WSL, but it does technically work...
NvimPath := "nvim.exe"
IconPath := NvimPath . ", 0"

; Assumes default WT profile is appropriate. Additional --profile needed to specify
Cmd := WTPath . ' new-tab  -d %L\.. wsl -e bash -c "nvim $(pwd)"'


; List of text file extensions to associate
TextExtensions := [
    ".txt", ".log", ".ini", ".cfg", ".conf", ".md", ".markdown",
    ".json", ".yml", ".yaml", ".xml", ".css", ".scss", ".less",
    ".js", ".ts", ".jsx", ".tsx", ".py", ".rb", ".php", ".pl",
    ".sh", ".bash", ".zsh", ".fish", ".ps1", ".vim", ".lua",
    ".gitignore", ".env", ".md", ".sql", ".rmd", ".qmd", ".plsql",
    ".ahk",".sh",".bat"
]


; Register Neovim as an application
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
        command := Cmd
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

        command := Cmd
        RegWrite command, "REG_SZ", cmdKey

        return true
    } catch Error as err {
        MsgBox "Error associating " . extension . ": " . err.Message
        return false
    }
}

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
        command := Cmd
        RegWrite command, "REG_SZ", shellKey

        ; Set default handler for no-extension files
        RegWrite "open", "REG_SZ", unknownKey . "\shell"

        return true
    } catch Error as err {
        MsgBox "Error registering for no extension files: " . err.Message
        return false
    }
}


; Helper function to check if registry key exists
RegKeyExist(key) {
    try {
        RegRead(key)
        return true
    } catch Error {
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
        command := Cmd
        RegWrite command, "REG_SZ", commandKey

        return true
    } catch Error as err {
        MsgBox "Error adding global context menu: " . err.Message
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
        RegWrite AppName, "REG_SZ", dirKey, "MUIVerb"

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
        command := Cmd
        RegWrite command, "REG_SZ", commandKey

        return true
    } catch Error as err {
        MsgBox "Error adding directory context menu: " . err.Message
        return false
    }
}

runOpenWithConfigurator(){

	; Register the application as a defaultable .exe
	if RegisterNeovimApp()
		MsgBox "Context menu item added successfully!"

    ; Add the context menu item for text files
    ;if AddContextMenu()
    ;    MsgBox "Context menu item added successfully!"

    if RegisterForNoExtension()
        MsgBox "Neovim successfully registered for files with no extension."

    if AddGlobalContextMenu()
        MsgBox "Neovim global context menu added successfully."

    if AddDirectoryContextMenu()
       MsgBox "Neovim directory context menu added successfully."
	   
	; Associate all text file types
    successCount := 0
    for ext in TextExtensions {
        if AssociateFileType(ext)
            successCount++
    }
    MsgBox "Successfully associated " . successCount . " of " . TextExtensions.Length . " file types with Neovim."
}

