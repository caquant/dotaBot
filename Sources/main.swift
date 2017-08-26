import Foundation
import Sword

let bot = Sword(token: "MzUwNjkxNTU4NjI4MjYxODkw.DIHulg.kTQW7OL06pnaw9kOEtUEk5Wd4z0")

bot.on(.ready) { [unowned bot] _ in
    bot.editStatus(to: "online", playing: "with Sword!")
}

bot.on(.messageCreate) { data in
    let msg = data as! Message
    
    if msg.content == "!ping" {
        msg.reply(with: "Pong!")
    }
}

bot.connect()
