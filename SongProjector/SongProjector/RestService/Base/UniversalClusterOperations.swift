//
//  UniversalClusterOperations.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

class UniversalClusterOperations {
    
    static var operations: [Foundation.Operation] {
        func churchDidFail() -> RequestError? {
            return nil
        }
        let churchFetcher = FetchChurchOperation(didFail: churchDidFail)
        let tagFetcher = FetchTagOperation(didFail: churchFetcher.operationDidFail)
        let themeFetcher = FetchThemeOperation(didFail: tagFetcher.operationDidFail)
        let tagSubmitter = SubmitTagOperation(didFail: themeFetcher.operationDidFail)
        let themeSubmitter = SubmitThemeOperation(didFail: tagSubmitter.operationDidFail)
        let clusterFetcher = ClusterFetcherOperation(didFail: themeSubmitter.operationDidFail)
        let uuaFetcher = FetchUUAOperation(didFail: clusterFetcher.operationDidFail)
        let uniFetcher = UniversalClusterFetcherOperation(didFail: uuaFetcher.operationDidFail)
        return [uniFetcher, uuaFetcher, clusterFetcher, themeSubmitter, tagSubmitter, themeFetcher, tagFetcher, churchFetcher]
    }
    
    static func fetch() {
        if hasInternet {
            Queues.main.async {
                RequestManager.add(operations: operations)
            }
        } else {
            UniversalClusterFetcher.observers.forEach({ $0.requesterDidFinish(requester: UniversalClusterFetcher, result: .failed(.notConnectedToNetwork), isPartial: false) })
        }
    }
}


class FetchUUAOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        UniversalUpdatedAtFetcher.addObserver(self)
        UniversalUpdatedAtFetcher.executeRequest()
    }
    
}



class UniversalClusterFetcherOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            UniversalClusterFetcher.observers.forEach({ $0.requesterDidFinish(requester: UniversalClusterFetcher, result: .failed(error), isPartial: false) })
            return
        }
        UniversalClusterFetcher.addObserver(self)
        UniversalClusterFetcher.executeRequest()
    }
}

class ClusterFetcherOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            ClusterFetcher.observers.forEach({ $0.requesterDidFinish(requester: ClusterFetcher, result: .failed(error), isPartial: false) })
            return
        }
        ClusterFetcher.addObserver(self)
        ClusterFetcher.executeRequest()
    }
}


class SubmitTagOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        if hasTag {
            didFinish()
        } else {
            let tag = VTag()
            tag.title = AppText.UploadUniversalSong.new
            tag.isDeletable = false
            TagSubmitter.body = [tag]
            TagSubmitter.requestMethod = .post
            TagSubmitter.addObserver(self)
            TagSubmitter.executeRequest()
        }
    }
    
    private var hasTag: Bool {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let moc = newMOCBackground
        let tag: Tag? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return [tag].compactMap({ $0 }).map({ VTag(tag: $0, context: moc) }).count > 0
    }
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        switch result {
        case .success(let result):
            if (result as? [VTag])?.count ?? 0 > 0 {
                didFinish()
            } else {
                self.didFail()
            }
        case .failed(_): didFail()
            
        }
    }
}


class SubmitThemeOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        if hasTheme {
            didFinish()
        } else {
            let theme = VTheme()
            theme.title = AppText.UploadUniversalSong.defaultTheme
            theme.isDeletable = false
            theme.isUniversal = true
            ThemeSubmitter.body = [theme]
            ThemeSubmitter.requestMethod = .post
            ThemeSubmitter.addObserver(self)
            ThemeSubmitter.executeRequest()
        }
    }
    
    private var hasTheme: Bool {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return theme != nil
    }
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        switch result {
        case .success(let result):
            if (result as? [VTheme])?.count ?? 0 > 0 {
                didFinish()
            } else {
                self.didFail()
            }
        case .failed(_): didFail()
            
        }
    }
}


class FetchThemeOperation: UniversalClusterOperation {
    
    let themeFetcher = ThemeFetcher
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        if hasTheme {
            didFinish()
        } else {
            themeFetcher.addObserver(self)
            themeFetcher.executeRequest()
        }
    }
    
    private var hasTheme: Bool {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return theme != nil
    }
}

class FetchTagOperation: UniversalClusterOperation {
    
    let tagFetcher = TagFetcher
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        if hasTag {
            didFinish()
        } else {
            tagFetcher.addObserver(self)
            tagFetcher.executeRequest()
        }
    }
    
    private var hasTag: Bool {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let moc = newMOCBackground
        let tag: Tag? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return [tag].compactMap({ $0 }).map({ VTag(tag: $0, context: moc) }).count > 0
    }
    
}

class FetchChurchOperation: UniversalClusterOperation {
    
    override func main() {
        if let error = dependencyDidFail() {
            self.error = error
            didFail()
            return
        }
        if hasChurch {
            didFinish()
        } else {
            ChurchFetcher.addObserver(self)
            ChurchFetcher.executeRequest()
        }
    }
    
    private var hasChurch: Bool {
        let context = newMOCBackground
        let church: Church? = DataFetcher().getEntity(moc: context, predicates: [.skipDeleted])
        let has = church != nil
        return has
    }
}


class UniversalClusterOperation: AsynchronousOperation, RequesterObserver1  {
    
    let dependencyDidFail: (() -> RequestError?)
    var error: RequestError?
    
    init(didFail: @escaping (() -> RequestError?)) {
        dependencyDidFail = didFail
    }
    
    func operationDidFail() -> RequestError? {
        return error
    }
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        
        if !isPartial {
            requester.removeObserver(self)
        }
        
        switch result {
        case .success(_):
            if !isPartial {
                didFinish()
            }
        case .failed(let error):
            self.error = error
            didFail()
        }
        
    }
}
