//
//  AppDelegate.swift
//  TodoSaneado
//
//
//

import UIKit

let kLoginFlowEnabled = false
let kEncryptionEnabled = false
let kSyncEnabled = true
let kSyncGatewayUrl = URL(string: "http://localhost:4984/todolite/")!
let kLoggingEnabled = false
let kUsePrebuiltDb = false
let kConflictResolution = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var database: CBLDatabase!
    var pusher: CBLReplication!
    var puller: CBLReplication!
    var syncError: NSError?
    var conflictsLiveQuery: CBLLiveQuery?
    var accessDocuments: Array<CBLDocument> = [];
    
    // MARK: - Application Life Cycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        do {
                try startSession(username: "user1")
            } catch let error as NSError {
                NSLog("Cannot start a session: %@", error)
                return false
        }
        
        //UINavigationBar.appearance().size
        
        UINavigationBar.appearance().barTintColor = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSStrokeWidthAttributeName: -1.0]

        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        if let font = UIFont(name: "SanFranciscoDisplay-Regular", size: 25) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.white]
        }
        
 

        /*
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 25.0)!]
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        */
        return true
    }
    
    
    // MARK: - Logging
    func enableLogging() {
        CBLManager.enableLogging("CBLDatabase")
        CBLManager.enableLogging("View")
        CBLManager.enableLogging("ViewVerbose")
        CBLManager.enableLogging("Query")
        CBLManager.enableLogging("Sync")
        CBLManager.enableLogging("SyncVerbose")
    }
    
    // MARK: - Session
    /*
     *  TONI: Esta función es llamada en el Application Life Cycle
     *
     */
    
    func startSession(username:String, withPassword password:String? = nil, withNewPassword newPassword:String? = nil) throws {
        
        //TONI: installPrebuiltDb()
        
        try openDatabase(username: username, withKey: password, withNewKey: newPassword)
        Session.username = username
        startReplication(withUsername: username, andPassword: newPassword ?? password)
        showApp()
        startConflictLiveQuery()
    }
    
    
    /******************************************************************************************
     *  
     *  TONI: He borrado la funcion installPrebuiltDb()
     *
     ******************************************************************************************/
    
    
    // MARK: Creacion DB
    
    func openDatabase(username:String, withKey key:String?, withNewKey newKey:String?) throws {

        //username: user1, definido en func application()
        let dbname = username
        print("TONI -> AppDelegate____openDatabase: dbname = \(dbname as NSString)")
        
        //opciones predefinidas para definir una db usando el metodo "Manager" openDatabase(_:_:_)
        let options = CBLDatabaseOptions()
        options.create = true
        
        try database = CBLManager.sharedInstance().openDatabaseNamed(dbname, with: options)
        
        
        let queryAllDocs = database.createAllDocumentsQuery()
        queryAllDocs.allDocsMode = CBLAllDocsMode.allDocs
        let result = try queryAllDocs.run()
        while let row = result.nextRow(){
            print("TONI -> Filas: \(row.documentID)")

        }
        
        
        
        print("TONI -> AppDelegate____openDatabase: database = \(database.description)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.observeDatabaseChange), name:Notification.Name.cblDatabaseChange, object: database)
    }
    
    func observeDatabaseChange(notification: Notification) {
        if(!(notification.userInfo?["external"] as! Bool)) {
            return;
        }
        //print("TONI -> entro en observerDatabse)")
        for change in notification.userInfo?["changes"] as! Array<CBLDatabaseChange> {
            if(!change.isCurrentRevision) {
                continue;
            }
            
            let changedDoc = database.existingDocument(withID: change.documentID);
            print("TONI -> changeDoc \(changedDoc)")
            if(changedDoc == nil) {
                return;
            }
            
            let docType = changedDoc?.properties?["type"] as! String?;
            let datosVarios = changedDoc?.properties?["Datos"] as! String?;
            print("TONI -> datos en la db \(datosVarios)")
            
            if(docType == nil) {
                continue;
            }
            
            if(docType != "task-list.user") {
                continue;
            }
            
            let username = changedDoc?.properties?["username"] as! String?;
            if(username != database.name) {
                continue;
            }
            
            accessDocuments.append(changedDoc!);
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleAccessChange), name: NSNotification.Name.cblDocumentChange, object: changedDoc);
        }
    }
    
    func handleAccessChange(notification: Notification) throws {
        let change = notification.userInfo?["change"] as! CBLDatabaseChange;
        let changedDoc = database.document(withID: change.documentID);
        if(changedDoc == nil || !(changedDoc?.isDeleted)!) {
            return;
        }
        
        let deletedRev = try changedDoc?.getLeafRevisions()[0];
        let listId = (deletedRev?["taskList"] as! Dictionary<String, NSObject>)["id"] as! String?;
        if(listId == nil) {
            return;
        }
        
        accessDocuments.remove(at: accessDocuments.index(of: changedDoc!)!);
        let listDoc = database.existingDocument(withID: listId!);
        try listDoc?.purgeDocument();
        try changedDoc?.purgeDocument()
    }
    
    func closeDatabase() throws {
        stopConflictLiveQuery()
        try database.close()
    }
    
    func showApp() {
        guard let root = window?.rootViewController, let storyboard = root.storyboard else {
            return
        }
        
        let controller = storyboard.instantiateInitialViewController()
        window!.rootViewController = controller
    }
    
    
    func deleteDatabase(dbName: String) {
        // Delete the database by using file manager. Currently CBL doesn't have
        // an API to delete an encrypted database so we remove the database
        // file manually as a workaround.
        let dir = NSURL(fileURLWithPath: CBLManager.sharedInstance().directory)
        let dbFile = dir.appendingPathComponent("\(dbName).cblite2")
        do {
            try FileManager.default.removeItem(at: dbFile!)
        } catch let err as NSError {
            NSLog("Error when deleting the database file: %@", err)
        }
    }
    
    // MARK: - Replication
    
    func startReplication(withUsername username:String, andPassword password:String? = "") {
        guard kSyncEnabled else {
            return
        }
        
        syncError = nil
        
        print("TONI -> Start Replication user: \(username) y password: \(password)")
        
        // TRAINING: Start push/pull replications
        pusher = database.createPushReplication(kSyncGatewayUrl)
        pusher.continuous = true  // Runs forever in background
        NotificationCenter.default.addObserver(self, selector: #selector(replicationProgress(notification:)),
                                               name: NSNotification.Name.cblReplicationChange, object: pusher)
        
        puller = database.createPullReplication(kSyncGatewayUrl)
        puller.continuous = true  // Runs forever in background
        NotificationCenter.default.addObserver(self, selector: #selector(replicationProgress(notification:)),
                                               name: NSNotification.Name.cblReplicationChange, object: puller)
        
        if kLoginFlowEnabled {
            let authenticator = CBLAuthenticator.basicAuthenticator(withName: username, password: password!)
            pusher.authenticator = authenticator
            puller.authenticator = authenticator
        }
        
        pusher.start()
        puller.start()
    }
    
    func stopReplication() {
        print("TONI -> Stop replication!")
        guard kSyncEnabled else {
            return
        }
        
        pusher.stop()
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.cblReplicationChange, object: pusher)
        
        puller.stop()
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.cblReplicationChange, object: puller)
    }
    
    func replicationProgress(notification: NSNotification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible =
            (pusher.status == .active || puller.status == .active)
        
        let error = pusher.lastError as? NSError;
        if (error != syncError) {
            syncError = error
            if let errorCode = error?.code {
                NSLog("Replication Error: \(error!)")
                if errorCode == 401 {
                    Ui.showMessageDialog(
                        onController: self.window!.rootViewController!,
                        withTitle: "Authentication Error",
                        withMessage:"Your username or password is not correct.",
                        withError: nil,
                        onClose: {
                            //self.logout()
                    })
                }
            }
        }
    }
    
    // MARK: - Conflicts Resolution
    
    // TRAINING: Responding to Live Query changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == conflictsLiveQuery {
            resolveConflicts()
        }
    }
    
    func startConflictLiveQuery() {
        guard kConflictResolution else {
            return
        }
        
        // TRAINING: Detecting when conflicts occur
        conflictsLiveQuery = database.createAllDocumentsQuery().asLive()
        conflictsLiveQuery!.allDocsMode = .onlyConflicts
        conflictsLiveQuery!.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        conflictsLiveQuery!.start()
    }
    


    
    func stopConflictLiveQuery() {
        conflictsLiveQuery?.removeObserver(self, forKeyPath: "rows")
        conflictsLiveQuery?.stop()
        conflictsLiveQuery = nil
    }
    
    func resolveConflicts() {
        let rows = conflictsLiveQuery?.rows
        while let row = rows?.nextRow() {
            if let revs = row.conflictingRevisions, revs.count > 1 {
                let defaultWinning = revs[0]
                let type = (defaultWinning["type"] as? String) ?? ""
                switch type {
                // TRAINING: Automatic conflict resolution
                case "task-list", "task-list.user":
                    let props = defaultWinning.userProperties
                    let image = defaultWinning.attachmentNamed("image")
                    resolveConflicts(revisions: revs, withProps: props, andImage: image)
                // TRAINING: N-way merge conflict resolution
                case "task":
                    let merged = nWayMergeConflicts(revs: revs)
                    resolveConflicts(revisions: revs, withProps: merged.props, andImage: merged.image)
                default:
                    break
                }
            }
        }
    }
    
    func resolveConflicts(revisions revs: [CBLRevision], withProps desiredProps: [String: Any]?,
                          andImage desiredImage: CBLAttachment?) {
        database.inTransaction {
            var i = 0
            for rev in revs as! [CBLSavedRevision] {
                let newRev = rev.createRevision()  // Create new revision
                if (i == 0) { // That's the current / winning revision
                    
                    
                    newRev.userProperties = desiredProps // Set properties to desired properties
                    if rev.attachmentNamed("image") != desiredImage {
                        newRev.setAttachmentNamed("image", withContentType: "image/jpg",
                                                  content: desiredImage?.content)
                    }
                } else {
                    // That's a conflicting revision, delete it
                    newRev.isDeletion = true
                }
                
                do {
                    try newRev.saveAllowingConflict()  // Persist the new revisions
                } catch let error as NSError {
                    NSLog("Cannot resolve conflicts with error: %@", error)
                    return false
                }
                i += 1
            }
            return true
        }
    }
    
    func nWayMergeConflicts(revs: [CBLRevision]) ->
        (props: [String: Any]?, image: CBLAttachment?) {
            guard let parent = findCommonParent(revisions: revs) else {
                let defaultWinning = revs[0]
                let props = defaultWinning.userProperties
                let image = defaultWinning.attachmentNamed("image")
                return (props, image)
            }
            
            var mergedProps = parent.userProperties ?? [:]
            var mergedImage = parent.attachmentNamed("image")
            var gotTask = false, gotComplete = false, gotImage = false
            for rev in revs {
                if let props = rev.userProperties {
                    if !gotTask {
                        let task = props["task"] as? String
                        if task != mergedProps["task"] as? String {
                            mergedProps["task"] = task
                            gotTask = true
                        }
                    }
                    
                    if !gotComplete {
                        let complete = props["complete"] as? Bool
                        if complete != mergedProps["complete"] as? Bool {
                            mergedProps["complete"] = complete
                            gotComplete = true
                        }
                    }
                }
                
                if !gotImage {
                    let attachment = rev.attachmentNamed("image")
                    let attachmentDiggest = attachment?.metadata["digest"] as? String
                    if (attachmentDiggest != mergedImage?.metadata["digest"] as? String) {
                        mergedImage = attachment
                        gotImage = true
                    }
                }
                
                if gotTask && gotComplete && gotImage {
                    break
                }
            }
            return (mergedProps, mergedImage)
    }
    
    func findCommonParent(revisions: [CBLRevision]) -> CBLRevision? {
        var minHistoryCount = 0
        var histories : [[CBLRevision]] = []
        for rev in revisions {
            let history = (try? rev.getHistory()) ?? []
            histories.append(history)
            minHistoryCount =
                minHistoryCount > 0 ? min(minHistoryCount, history.count) : history.count
        }
        
        if minHistoryCount == 0 {
            return nil
        }
        
        var commonParent : CBLRevision? = nil
        for i in 0...minHistoryCount {
            var rev: CBLRevision? = nil
            for history in histories {
                if rev == nil {
                    rev = history[i]
                } else if rev!.revisionID != history[i].revisionID {
                    rev = nil
                    break
                }
            }
            if rev == nil {
                break
            }
            commonParent = rev
        }
        
        if let deleted = commonParent?.isDeletion , deleted {
            commonParent = nil
        }
        return commonParent
    }
}
