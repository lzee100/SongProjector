//
//  SongServicePlayDateSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

let SongServicePlayDateSubmitter = SngServicePlayDateSubmitter()

class SngServicePlayDateSubmitter: Requester<VSongServicePlayDate>  {
    
    override var id: String {
        return "SongServicePlayDateSubmitter"
    }
    
    override var path: String {
        return "songserviceplaydate"
    }
    
    func subMitPlayDate() {
        if let appInstallId = UserDefaults.standard.object(forKey: ApplicationIdentifier) as? String {
            DispatchQueue.main.async {
                let playDate: SongServicePlayDate? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
                let playDateEntity = [playDate].compactMap({ $0 }).map({ VSongServicePlayDate(entity: $0, context: moc) }).first ?? VSongServicePlayDate()
                playDateEntity.appInstallId = appInstallId
                playDateEntity.userUID = Auth.auth().currentUser?.uid ?? ""
                playDateEntity.playDate = Date()
                self.submit([playDateEntity], requestMethod: .post)
            }
        }
    }
        
}
