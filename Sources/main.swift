import Foundation
import Sword


let bot = Sword(token: "MzUwNjkxNTU4NjI4MjYxODkw.DIHulg.kTQW7OL06pnaw9kOEtUEk5Wd4z0")

bot.on(.ready) { [unowned bot] _ in
    bot.editStatus(to: "online", playing: "Dota2")
    Heroes.downloadHeroes()
}

bot.on(.messageCreate) { data in
    let msg = data as! Message
    var text = msg.content
    
    if text.lowercased() == "yo" {
        msg.reply(with: "Yo! what up broski!")
    }
    
    if text == "!!" {
        msg.reply(with: "I'm here if you need me bruh!")
    }
    
    if text.lowercased() == "nice bro" {
        msg.reply(with: "Thank you son, glad I can help! bleep-bloop!")
    }
    
    if let first = text.characters.first, first == "!" {
        text.remove(at: text.startIndex)
        let args = text.components(separatedBy: " ")
        let cmd = args[0]
        switch cmd {
        case "dota":
            if args.count >= 2 {
                if let userName =  UserName(rawValue: args[1].lowercased()) {
                    let player = Player(userName: userName)
                    
                    if args.count == 2 {
                        player.getInfo(){ (embed) in
                            DispatchQueue.main.async {
                                msg.reply(with: "Here is some info about:")
                                msg.reply(with: embed)
                            }
                        }
                    } else {
                        let userInfo = args[2]
                        
                    }
                } else {
                    msg.reply(with: "I don't recornize that name Bro-man, bleep-bloop!")
                }
                
            } else {
                msg.reply(with: "Bruh! I can give you dota info, bleep-bloop!")
            }
            
        default:
            break
        }
    }
    
}

bot.connect()
