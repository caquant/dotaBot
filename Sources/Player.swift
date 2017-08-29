//
//  Player.swift
//  BroBot
//
//  Created by Carlos Quant on 8/28/17.
//
//

import Foundation
import Alamofire
import Sword

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

class Player {
    
    let userName: UserName
    private var handler: (([Embed]) -> Void)?
    
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
    
    func getRecentMatches(completionHandler: @escaping ([Embed]) -> Void) {
        
        Alamofire.request("\(HOST)players/\(self.userName)/recentMatches").responseJSON(completionHandler: { (matchResponse) in
            if let data = matchResponse.result.value as? [[String: Any]] {
                
                let n = kMaxMatches
                let firstFive = data[0..<n]
                
                
                var embeds: [Embed] = []
                for (index, element) in firstFive.enumerated() {
                    
                    let heroID = element["hero_id"] as! Int64
                    let hero = CDManager.fetch(hero: heroID)!
                    
                    var laneName = "N/A"
                    if let lane = element["lane"] as? Int {
                        switch lane {
                        case 1:
                            laneName = "Off lane"
                        case 2:
                            laneName = "Mid lane"
                        case 3:
                            laneName = "Safe lane"
                            
                        default:
                            laneName = "N/A"
                        }
                    } else if let roaming = element["is_roaming"] as? Bool, roaming {
                        laneName = "Roaming/Jungle"
                    }
                
                    let embed = Embed([
                        "author": ["name" : "Match #\(index + 1)", "url" : "https://www.dotabuff.com/matches/\(element["match_id"] as! Int)", "icon_url" : hero.image!],
                        "type" : "rich",
                        "fields" : [["name" : "Hero", "value" : hero.localized_name!],
                                    ["name" : "K/D/A", "value" : "\(element["kills"] as! Int) / \(element["deaths"] as! Int) / \(element["assists"] as! Int)", "inline" : true],
                                    ["name" : "XP per minute", "value" : "\(element["xp_per_min"] as! Int)", "inline" : true],
                                    ["name" : "Gold per minute", "value" : "\(element["gold_per_min"] as! Int)", "inline" : true],
                                    ["name" : "Last hits", "value" : "\(element["last_hits"] as! Int)", "inline" : true],
                                    ["name" : "Lane", "value" : laneName, "inline" : true],
                                    ["name" : "Hero Damage", "value" : "\(element["hero_damage"] as! Int)", "inline" : true],
                                    ["name" : "Tower Damage", "value" : "\(element["tower_damage"] as! Int)", "inline" : true]
                            
                        ]
                        ])
                    
                    embeds.append(embed)
                    
                }
                
                completionHandler(embeds)
            }
        })
    }
}
