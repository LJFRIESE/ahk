; F24 leader mode. The menu tree and input handling live in MenuEngine.

class Leader {
    static Timeout := 3

    static Root := {
        label: "Leader",
        entries: [
            {key: "b", label: "Previous window", action: ActivatePreviousWindow}
        ]
    }

    static Toggle() {
        if MenuEngine.Active && MenuEngine.Id = "Leader"
            MenuEngine.Close()
        else
            this.Open()
    }

    static Open() {
        MenuEngine.Open(this.Root, {
            id: "Leader",
            timeout: this.Timeout,
            exitKeys: "{Esc}{vk87}",
            footer: "Backspace: back · F24/Esc: exit"
        })
    }
}
