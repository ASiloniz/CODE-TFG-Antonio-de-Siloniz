//
//  PlanViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 18/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class PlanViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    

    @IBOutlet weak var navigationItemBar: UINavigationItem!


    @IBOutlet weak var pacienteText: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fechaLabel: UILabel!
    
    
    var database: CBLDatabase!
    var taskList: CBLDocument!
    var documentoEnviado: Bool!
    var documentoEditado: Bool!
    var fechaGuardada: String!
    
    override func viewDidLoad() {
        
        self.documentoEditado = false;
        
        super.viewDidLoad()
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        let nombrePaciente = docProperties?["name"] as? String
        pacienteText.text = nombrePaciente
        
        textView.delegate = self
        
        if (textView.text == "") {
            print("TONI -> PlanViewController viewDidLoad: \(textView.text)")
            textViewDidEndEditing(textView)
        }
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(PlanViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapDismiss)
        
        //Cambiar fuente al Navigation Item:
        
        self.navigationItemBar.title = "Plan Terapéutico"
        self.navigationItemBar.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        //Apariencia TextView y botones:
        textView.clipsToBounds = true;
        textView.layer.cornerRadius = 10.0;
        
        editButton.layer.cornerRadius = 10.0;
        submitButton.layer.cornerRadius = 10.0;
        submitButton.isEnabled = false;
        editButton.isEnabled = false;
        
        // Mostrar texto enviado al centro:
        
        //Creas un documento y luego rellenas su motivo
        let docPlanGuardado = database.document(withID: "plan."+taskList.documentID)
        let docPlanProperties = docPlanGuardado!.properties
        
        //Poner fecha del doc si guardado:
        let fechaPlanGuardada = docPlanProperties?["createdAt"] as? String
        
        if(fechaPlanGuardada != nil){
            print("TONI -> Fecha guardada: \(fechaPlanGuardada)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            let fechaSinOptional = fechaPlanGuardada!
            print("TONI -> \(fechaSinOptional)")
            
            let date = dateFormatter.date(from: fechaSinOptional)
            print("TONI -> Fecha guardada en Date: viewDidLoad \(date)")
            
            
            let outputDatedateFormatter = DateFormatter()
            outputDatedateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy "
            //leave the time zone at the default (user's time zone)
            
            
            let displayString = outputDatedateFormatter.string(from: date!)
            
            self.fechaLabel.text = displayString
        }
        else if(fechaPlanGuardada == nil){
            self.fechaLabel.text = "Ningún documento enviado"
        }
        
        
        let planConsultaGuardada = docPlanProperties?["Plan_terapeutico"] as? String
        
        if( planConsultaGuardada != nil){
            print("TONI -> Plan terapeutico guardado: \(planConsultaGuardada)")
            textView.text = planConsultaGuardada
            textView.textColor = UIColor.black
            textView.isEditable = false;
            textView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            editButton.isEnabled = true;
        }
        
        
        app.stopReplication()
        app.startReplication(withUsername: "user1", andPassword: nil)
        
        
        
    }
    
    @IBAction func buttonOnClick(_ sender: AnyObject) {
        
        if( self.documentoEditado == true ){
            let docAUpdatear = database.document(withID: "plan."+taskList.documentID)
            print("TONI -> Doc a updatear: \(taskList.documentID)")
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Plan_terapeutico"] = self.textView.text
                    newRev["createdAt"] = fechaJSON
                    return true
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: fechaJSON)
                print("TONI -> Fecha guardada en Date: \(date)")
                
                
                let outputDatedateFormatter = DateFormatter()
                outputDatedateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy "
                //leave the time zone at the default (user's time zone)
                let displayString = outputDatedateFormatter.string(from: date!)
                self.fechaLabel.text = displayString
                
            } catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
                
                Ui.showMessageDialog(onController: self, withTitle: "Error",
                                     withMessage: "Imposible actualizar plan terapeutico", withError: error)
                
            }
            
        }
        else if(self.documentoEditado != true){
            crearTexto(texto: textView.text)
            
            let fechaDateGuardada = Date()
            let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: fechaJSON)
            print("TONI -> Fecha guardada en Date: \(date)")
            
            
            let outputDatedateFormatter = DateFormatter()
            outputDatedateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy "
            //leave the time zone at the default (user's time zone)
            let displayString = outputDatedateFormatter.string(from: date!)
            self.fechaLabel.text = displayString
            
        }
        
        //self.getTimeYPonerTime()
        
        self.submitButton.isEnabled = false;
        self.textView.isEditable = false;
        self.textView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        self.editButton.isEnabled = true;
        self.documentoEditado = true;
        
    }
    
    
    
    func getTimeYPonerTime(){
        //Ponerle la fecha al label del doc:
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        
        // get the date time String from the date object
        let dateString = formatter.string(from: currentDateTime)
        
        self.fechaLabel.text = dateString
        self.fechaGuardada = dateString
    }
    @IBAction func editOnClick(_ sender: AnyObject) {
        
        
        self.textView.isEditable = true;
        self.textView.backgroundColor = UIColor.white
        self.documentoEditado = true;
        self.submitButton.isEnabled = true;
        self.editButton.isEnabled = false;
        
    }
    


    
    
    //Metodo para crear documento con Motivo de la consulta
    
    func crearTexto(texto: String) -> CBLSavedRevision? {
        let taskListInfo = [
            "id": taskList.documentID,
            "owner": taskList["owner"]!
        ]
        
        let properties: Dictionary<String, Any> = [
            "type": "Texto libre: Plan terapeutico",
            "Datos": taskListInfo,
            "createdAt": CBLJSON.jsonObject(with: Date()),
            "Plan_terapeutico": texto
        ]
        
        //let idDocMotivo = doc.documentID
        
        guard let doc = database.document(withID: "plan."+taskList.documentID) else {
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                                 withMessage: "Imposible crear documento Motivo")
            return nil
        }
        
        
        do {
            return try doc.putProperties(properties)
        } catch let error as NSError {
            /*
             Ui.showMessageDialog(onController: self, withTitle: "Error",
             withMessage: "Imposible guardar Motivo de la consulta", withError: error)
             */
            return nil
        }
    }
    
    
    // MARK: - Segue A COMPLETAR
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         if segue.identifier == "showTaskImage" {
         let navController = segue.destination as! UINavigationController
         let controller = navController.topViewController as! TaskImageViewController
         controller.task = taskForImage
         taskForImage = nil
         }
    }
    */
    
    // MARK: - KVO
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == tasksLiveQuery {
             TONI WARNING!
             reloadTasks()
 
        }
    }
    */
    func dismissKeyboard(){
        textView.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            print("TONI -> textViewDidEndEditing: \(textView.text)")
            textView.text = "    Escribe el plan terapéutico para el paciente"
            print("TONI -> textViewDidEndEditing: \(textView.text)")
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            submitButton.isEnabled = false;
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if(textView.text == "    Escribe el plan terapéutico para el paciente"){
            print("TONI -> Entro en el and")
            textView.text = ""
            textView.textColor = UIColor.black
            submitButton.isEnabled = true;
        }
        textView.becomeFirstResponder()
        print("TONI -> Plan: textView \(textView.text)")
    }
    
    
    
}

