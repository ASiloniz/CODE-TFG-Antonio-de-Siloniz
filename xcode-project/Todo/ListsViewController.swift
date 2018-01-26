//
//  TaskListsViewController.swift
//  Todo
//
//  Created by Pasin Suriyentrakorn on 2/8/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import UIKit

class ListsViewController: UITableViewController, UISearchResultsUpdating {
    var searchController: UISearchController!
    
    var username: String!
    var database: CBLDatabase!
    
    var listsLiveQuery: CBLLiveQuery!
    var listRows : [CBLQueryRow]?
    
    var incompTasksCountsLiveQuery: CBLLiveQuery!
    var incompTasksCounts : [String : Int]?
    var refresher: UIRefreshControl!
    
    var app: AppDelegate!
    
    var docMotivoId: String!
    
    var timer = Timer()
    
    var numeroDocumentos : UInt!
    
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TONI: Hacer que la tabla solo despliegue celdas con contenido
        
        tableView.tableFooterView = UIView()
        
        //TONI: Fondo con el icono de medical sync:
        let backgroundImage = UIImage(named: "logo-medSync-1-fondo.jpg")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.2
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "logo-medSync-1-fondo.jpg")!)
        
        
        /*
         let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
         */
        
        
        //TONI: Comprobación del número de documentos
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.refreshParaTimer), userInfo: nil, repeats: false)
        
        // Setup Navigation bar:
        if !kLoginFlowEnabled {
            // Remove logout button:
            self.navigationItem.leftBarButtonItem = nil
        }
        
        // Setup SearchController:
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        //self.tableView.tableHeaderView = searchController.searchBar
        
        // Get database and username:
        app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        username = Session.username
        
        // Setup view and query
        setupViewAndQuery()
        
        numeroDocumentos = database.documentCount
        
        print("TONI -> Lists Número de documentos es: \(numeroDocumentos!)")
        
        refreshSinButton()
        
        
    }

    deinit {
        if listsLiveQuery != nil {
            listsLiveQuery.removeObserver(self, forKeyPath: "rows")
            listsLiveQuery.stop()
        }
        
        if incompTasksCountsLiveQuery != nil {
            incompTasksCountsLiveQuery.removeObserver(self, forKeyPath: "rows")
            incompTasksCountsLiveQuery.stop()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let iconosViewController = segue.destination as? IconosViewController {
            let pacienteSeleccionado = listRows![self.tableView.indexPathForSelectedRow!.row].document
            
            
            iconosViewController.taskList = pacienteSeleccionado
            let valuePacienteSeleccionado = pacienteSeleccionado!.documentID
            
            print("TONI -> IconosViewController seleccionado: \(valuePacienteSeleccionado)")
            
            
        }
        
    }
    
    // MARK: - KVO
    
    // TRAINING: Responding to Live Query changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == listsLiveQuery {
            reloadTaskLists()
        } else if object as? NSObject == incompTasksCountsLiveQuery {
            reloadIncompleteTasksCounts()
        }
    }

    // MARK: - UITableViewController
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRows?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        // MARK: - Apariencia de las celdas de la tabla
        cell.backgroundColor = UIColor(white: 1, alpha: 0.8)

        
        // TONI -> the following code increases cell border on all sides of the cell
        /*
        cell.layer.borderWidth = 15.0
        
        cell.layer.borderColor = UIColor.white.cgColor
  
        */
        
        // TONI -> Ponerle un fondo con un gradiente
        /*
        let gradientView = GradientView()
        
        let cellBounds = cell.bounds
        let gradientLayer = gradientView.viewGradiente(rect: cellBounds)
        
        
        cell.backgroundView = UIView()
        cell.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
        */
        

        /*
        let grisFondo = UIColor(red:0.22, green:0.22, blue:0.21, alpha:1.0)
        cell.backgroundColor = grisFondo
         */
        let row = listRows![indexPath.row] as CBLQueryRow
        
        cell.textLabel?.text = row.value(forKey: "key") as? String
        
        let incompleteCount = incompTasksCounts?[row.documentID!] ?? 0
        cell.detailTextLabel?.text = incompleteCount > 0 ? "\(incompleteCount)" : ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Eliminar") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
            // Delete list document:
            let doc = self.listRows![indexPath.row].document!
            self.deleteTaskList(list: doc)
            
            // BORRAR Motivo consulta asociado
            let idMotivoAsociado = "motivo."+doc.documentID
            print("TONI -> idMotivoAsociado \(idMotivoAsociado)")
            let motivoDoc = self.database.document(withID: idMotivoAsociado)
            self.deleteTaskList(list: motivoDoc!)
            
            // BORRAR Constantes Vitales asociadas
            let idExploracionAsociada = "exploracion.constantesVitales."+doc.documentID
            let exploracionDoc = self.database.document(withID: idExploracionAsociada)
            self.deleteTaskList(list: exploracionDoc!)
            
            // BORRAR Medicación y alergias asociadas.
            let idMedicacionYAlergiasAsociadas = "exploracion.medicacionYAlergias."+doc.documentID
            let medicacionYAlergiasDoc = self.database.document(withID: idMedicacionYAlergiasAsociadas)
            self.deleteTaskList(list: medicacionYAlergiasDoc!)
            
            // BORRAR Medicación y alergias asociadas.
            let idHabitosToxicosAsociadas = "exploracion.HabitosToxicos."+doc.documentID
            let habitosToxicosDoc = self.database.document(withID: idHabitosToxicosAsociadas)
            self.deleteTaskList(list: habitosToxicosDoc!)

            
            // BORRAR Plan terapéutico asociado
            let idPlanAsociado = "plan."+doc.documentID
            print("TONI -> idPlanAsociado \(idPlanAsociado)")
            let planDoc = self.database.document(withID: idPlanAsociado)
            self.deleteTaskList(list: planDoc!)
            
            // BORRAR Informe completo asociado
            let idInformeCompletoAsociado = "informe."+doc.documentID
            print("TONI -> idInformeCompletoAsociado \(idInformeCompletoAsociado)")
            let informeDoc = self.database.document(withID: idInformeCompletoAsociado)
            self.deleteTaskList(list: informeDoc!)
            
            
            
            
        }
        delete.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        
        let update = UITableViewRowAction(style: .normal, title: "Editar") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
            // Display update list dialog:
            let doc = self.listRows![indexPath.row].document!
            
            Ui.showTextInputDialog(
                onController: self,
                withTitle: "Editar paciente",
                withMessage:  nil,
                withTextFieldConfig: { textField in
                    textField.placeholder = "Nombre y Apellidos"
                    textField.text = doc["name"] as? String
                    textField.autocapitalizationType = .words
                },
                onOk: { (name) -> Void in
                    self.updateTaskList(list: doc, withName: name)
                }
            )
        }
        update.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        return [delete, update]
    }
    
    // MARK: - UISearchController
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if !text.isEmpty {
            listsLiveQuery.startKey = text
            listsLiveQuery.prefixMatchLevel = 1
        } else {
            listsLiveQuery.startKey = nil
            listsLiveQuery.prefixMatchLevel = 0
        }
        listsLiveQuery.endKey = listsLiveQuery.startKey
        listsLiveQuery.queryOptionsChanged()
    }
    
    // MARK: - Action
    @IBAction func addAction(_ sender: AnyObject) {
        Ui.showTextInputDialog(
            onController: self,
            withTitle: "Nuevo Paciente",
            withMessage:  nil,
            withTextFieldConfig: { textField in
                textField.placeholder = "Introducir nombre y apellidos"
            },
            onOk: { name in
                _ = self.createTaskList(name: name)
        })
    }
    


    
    @IBAction func logoutAction(sender: AnyObject) {
        //let app = UIApplication.shared.delegate as! AppDelegate
        //app.logout()
    }

    // MARK: - Database

    func setupViewAndQuery() {
        
        // TRAINING: Writing a View
        let listsView = database.viewNamed("list/listsByName")
        
        if listsView.mapBlock == nil {
            listsView.setMapBlock({ (doc, emit) in
                if let type: String = doc["type"] as? String, let name = doc["name"]
                    , type == "task-list" {
                        emit(name, nil)
                }
            }, version: "1.0")
        }

        // TRAINING: Running a Query
        listsLiveQuery = listsView.createQuery().asLive()
        listsLiveQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        listsLiveQuery.start()
        
        // TRAINING: Writing an Aggregation View
        let incompTasksCountView = database.viewNamed("list/incompleteTasksCount")
        if incompTasksCountView.mapBlock == nil {
            incompTasksCountView.setMapBlock({ (doc, emit) in
                if let type: String = doc["type"] as? String , type == "task" {
                    if let list = doc["taskList"] as? [String: AnyObject], let listId = list["id"],
                        let complete = doc["complete"] as? Bool , !complete {
                        emit(listId, nil)
                    }
                }
                }, reduce: { (keys, values, reredeuce) in
                return values.count
            }, version: "1.0")
        }
        
        // TRAINING: Running a Query
        incompTasksCountsLiveQuery = incompTasksCountView.createQuery().asLive()
        incompTasksCountsLiveQuery.groupLevel = 1
        incompTasksCountsLiveQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        incompTasksCountsLiveQuery.start()
    }

    func reloadTaskLists() {
        
        listRows = listsLiveQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
    
        print("TONI -> listRows reloadTaskLists: \(listRows)")
        
        tableView.reloadData()
        
    }
    
    func reloadIncompleteTasksCounts() {
        var counts : [String : Int] = [:]
        let rows = incompTasksCountsLiveQuery.rows
        while let row = rows?.nextRow() {
            if let listId = row.value(forKey: "key") as? String, let count = row.value as? Int {
                counts[listId] = count
            }
        }
        incompTasksCounts = counts
        tableView.reloadData()
    }

    // MARK: TONI Creación de un Documento
    
    func createTaskList(name: String) -> CBLSavedRevision? {
        //properties es el objeto jSON que se guarda en la db.
        
        let properties: [String : Any] = [
            "type": "task-list",
            "name": name,
            "owner": username
        ]
        print("TONI -> ListsViewController createTaskList: properties = \(properties as [String: Any])")
        
        let docId = username + "." + NSUUID().uuidString
        
        guard let doc = database.document(withID: docId) else {
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                withMessage: "Couldn't save task list")
            return nil
        }
        
        do {
            return try doc.putProperties(properties)
        } catch let error as NSError {
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                withMessage: "Couldn't save task list", withError: error)
            return nil
        }
    }
    
    //MARK: Actualizar documento de DB
    
    func updateTaskList(list: CBLDocument, withName name: String) {
        
        // TRAINING: Update a document
        do {
            try list.update { newRev in
                newRev["name"] = name
                return true
            }
        } catch let error as NSError {
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                withMessage: "Couldn't update task list", withError: error)
        }
        
    }
    
    func deleteTaskList(list: CBLDocument) {
        // TRAINING: Delete a list
        if(list.userProperties?["owner"] as? String != username) {
            let moderatorDocId = "moderator." + username;
            //TONI WARNING : ANTES PONÍA == NIL
            if(database.existingDocument(withID: moderatorDocId) != nil) {
                Ui.showMessageDialog(onController: self, withTitle: "Error", withMessage: "Required access to delete list missing");
                return;
            }
        }
        
        do {
            try list.delete()
        } catch let error as NSError {
            /*
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                withMessage: "Couldn't delete task list", withError: error)
            */
        }
    }
    
    // MARK: - Conflicts
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // TRAINING: Create task list conflict (for development only)
            let savedRevision = createTaskList(name: "Test Conflicts List")
            let newRev1 = savedRevision?.createRevision()
            let propsRev1 = newRev1?.properties
            propsRev1?.setValue("Foosball", forKey: "name")
            let newRev2 = savedRevision?.createRevision()
            let propsRev2 = newRev2?.properties
            propsRev2?.setValue("Table Football", forKey: "name")
            do {
                try newRev1?.saveAllowingConflict()
                try newRev2?.saveAllowingConflict()
            } catch let error as NSError {
                NSLog("Could not create document %@", error)
            }
        }
    }
    
    func refreshSinButton(){
        app.stopReplication()
        app.startReplication(withUsername: "user1", andPassword: nil)
        
        
        do{
            
            let queryAllDocs = database?.createAllDocumentsQuery()
            queryAllDocs?.allDocsMode = CBLAllDocsMode.allDocs
            let result = try queryAllDocs?.run()
            while let row = result?.nextRow(){
                print("TONI -> REFRESCANDO BOTON Filas: \(row.documentID!)")
            }
        } catch let error as NSError {
            print("TONI -> Error Refrescando!")
        }
        self.tableView.reloadData()
        self.reloadTaskLists()
        
        //app.startReplication(withUsername: "user1")
    }
    
    func refreshParaTimer(){
        
        if(database.documentCount != numeroDocumentos!){
            app.stopReplication()
            app.startReplication(withUsername: "user1", andPassword: nil)
        }
        
        
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        
        app.stopReplication()
        app.startReplication(withUsername: "user1", andPassword: nil)
        
        
        do{
            
            let queryAllDocs = database?.createAllDocumentsQuery()
            queryAllDocs?.allDocsMode = CBLAllDocsMode.allDocs
            let result = try queryAllDocs?.run()
            while let row = result?.nextRow(){
                print("TONI -> REFRESCANDO BOTON Filas: \(row.documentID!)")
            }
        } catch let error as NSError {
            print("TONI -> Error Refrescando!")
        }
        self.tableView.reloadData()
        self.reloadTaskLists()
        
        //app.startReplication(withUsername: "user1")
        
    }
    
}


/*
    @IBAction func refresh(_ sender: UIButton) {
        
        app.stopReplication()
        app.startReplication(withUsername: "user1", andPassword: nil)
        

        do{

            let queryAllDocs = database?.createAllDocumentsQuery()
            queryAllDocs?.allDocsMode = CBLAllDocsMode.allDocs
            let result = try queryAllDocs?.run()
            while let row = result?.nextRow(){
                print("TONI -> REFRESCANDO BOTON Filas: \(row.documentID!)")
            }
        } catch let error as NSError {
            print("TONI -> Error Refrescando!")
        }
        self.tableView.reloadData()
        self.reloadTaskLists()
        
        //app.startReplication(withUsername: "user1")
        
    }
 */

