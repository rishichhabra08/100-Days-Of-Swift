//
//  Petition.swift
//  Project7
//
//  Created by Rishi Chhabra on 11/08/22.
//

import Foundation


class Petition : Codable {
    
    var id: String
    var title: String
    var body: String
    var signatureCount : Int
}

class Petitions : Codable {
    var results : [Petition]
}
