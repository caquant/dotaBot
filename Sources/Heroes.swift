//
//  Heroes.swift
//  BroBot
//
//  Created by Carlos Quant on 8/28/17.
//
//

import Foundation
import Alamofire
import Sword

struct Heroes {
    static func downloadHeroes() {
        Alamofire.request("\(HOST)heroes").responseJSON { (response) in
            if let json = response.result.value as? [[String:Any]]{
                for heroDict in json {
                    CDManager.insertHero(heroDict)
                }
            }
        }
    }
    
    static func getHeroInfo(id: Int64) -> Embed? {
        guard let hero = CDManager.fetch(hero: id) else {
            return nil
        }
        
        return createEmbed(hero)
    }
    
    static func getHeroInfo(name: String) -> Embed?  {
        guard let hero = CDManager.fetch(hero: name) else {
            return nil
        }
        
        return createEmbed(hero)
    }
    
    private static func createEmbed(_ hero: Hero) -> Embed{
        let embed = Embed([
            "author": ["name" : hero.localized_name!, "url" : hero.url, "icon_url" : hero.image_vert!],
            "thumbnail" : ["url" : hero.image!, "height" : 35, "width" : 35],
            "description" : hero.roles!,
            "type" : "rich",
            "fields" : [["name": "Primary Attribute", "value": getAttributeName(hero.primary_attr!), "inline": true],
                        ["name": "Attack Type", "value": hero.attack_type!, "inline": true]]
            ])
        
        return embed
    }
    
    private static func getAttributeName(_ attributeShort: String) -> String {
        switch attributeShort {
        case "agi":
            return "Agility"
            
        case "str":
            return "Strength"
            
        case "int":
            return "Intelligence"
            
        default:
            return ""
        }
    }
}
