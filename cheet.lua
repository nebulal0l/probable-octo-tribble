local ChatService = game:GetService("Chat")
local player = game.Players.LocalPlayer

local messages = {
    "im using china.cs rn, its soo good, specially priv,",
    "china.cs top!",
    "my gun is lgbt"
}

for _, msg in ipairs(messages) do
    ChatService:Chat(player.Character or player.CharacterAdded:Wait(), msg)
    wait(5) -- waits 3 seconds between each message
end
