import Foundation
import Sword
import Alamofire

enum UserName: String, CustomStringConvertible {
    case quantumRanger = "quantumranger"
    case jerryZaz = "jerryzaz"
    case jojo = "jojo"
    case wininator = "wininator"
    
    var description: String {
        switch self {
        case .quantumRanger:
            return "114860465"
            
        case .jerryZaz:
            return "115189603"
            
        case .wininator:
            return "115184926"
            
        case .jojo:
            return "100243669"
        }
    }
}

let HOST = "https://api.opendota.com/api/"

class Player {
    
    let userName: UserName
    
    init(userName user: UserName) {
        userName = user
    }
    
    func getInfo(completionHandler: @escaping (Embed) -> Void) {
        Alamofire.request("\(HOST)players/\(userName)").responseJSON { (response) in
            if let json = response.result.value as? [String:Any]{
                
                let profile = json["profile"] as! [String: Any]
                let estimated = json["mmr_estimate"] as! [String: Int]
                
                var message = ""
                if let soloMMR = json["solo_competitive_rank"] as? Int {
                    message.append("\nSolo MMR: **\(soloMMR)**")
                }
                
                if let partyMMR = json["competitive_rank"] as? Int {
                    message.append("\nParty MMR: **\(partyMMR)**")
                }
                
                if let estimatedMMR = estimated["estimate"] {
                    message.append("\nEstimated Pub MMR: **\(estimatedMMR)**")
                }
                
                if let country = profile["loccountrycode"] as? String {
                    message.append("\nCountry: \(country)")
                }
                
                let userReply = Embed([
                    "author" : ["name" : profile["personaname"] as! String, "url" : profile["profileurl"] as! String, "icon_url": profile["avatar"] as! String],
                    "description" : message,
                    "type" : "rich"
                    ])
                
                
                completionHandler(userReply)
            }
        }
    }
    
    func getRecentMatches(completionHandler: @escaping (String) -> Void) {
        
    }
}

let bot = Sword(token: "MzUwNjkxNTU4NjI4MjYxODkw.DIHulg.kTQW7OL06pnaw9kOEtUEk5Wd4z0")

bot.on(.ready) { [unowned bot] _ in
    bot.editStatus(to: "online", playing: "Dota2")
}

bot.on(.messageCreate) { data in
    let msg = data as! Message
    var text = msg.content
    
    if text == "yo" {
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
