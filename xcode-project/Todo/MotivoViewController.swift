//
//  CitiesTableViewController.swift
//  El Vuelo del Grajo
//
//  Created by Santiago Pavón on 7/12/14.
//  Copyright (c) 2014 UPM. All rights reserved.
//

import UIKit



class MotivoViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {

    var searchController: UISearchController!
    var username: String!
    var database: CBLDatabase!
    var taskList: CBLDocument!
    var tasksLiveQuery: CBLLiveQuery!
    var taskRows : [CBLQueryRow]?
    var taskForImage: CBLDocument?
    var dbChangeObserver: AnyObject?
    var documentoEnviado: Bool!
     var documentoEditado: Bool!
     var fechaGuardada: String!
    
    @IBOutlet weak var navigationItemBar: UINavigationItem!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pacienteText: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var textoAEnviar: UILabel!
    
     @IBOutlet weak var fechaLabel: UILabel!

    override func viewDidLoad() {
     
     self.documentoEditado = false;

        super.viewDidLoad()
     
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        username = Session.username
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        let nombrePaciente = docProperties?["name"] as? String
        pacienteText.text = nombrePaciente
        
          textView.delegate = self
     
        if (textView.text == "") {
            print("TONI -> MotivoViewController viewDidLoad: \(textView.text)")
            textViewDidEndEditing(textView)
        }
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(MotivoViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapDismiss)
     
          //Cambiar fuente al Navigation Item:
        
        self.navigationItemBar.title = "Motivo de la Consulta"
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
     let docConsultaGuardada = database.document(withID: "motivo."+taskList.documentID)
     let docMotivoProperties = docConsultaGuardada!.properties
     
          //Poner fecha del doc si guardado:
          let fechaConsultaGuardada = docMotivoProperties?["createdAt"] as? String
     
     if(fechaConsultaGuardada != nil){
          print("TONI -> Fecha guardada: \(fechaConsultaGuardada)")
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
          
          let fechaSinOptional = fechaConsultaGuardada!
          print("TONI -> \(fechaSinOptional)")
          
          let date = dateFormatter.date(from: fechaSinOptional)
          print("TONI -> Fecha guardada en Date: viewDidLoad \(date)")
          
          
          let outputDatedateFormatter = DateFormatter()
          outputDatedateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy "
          //leave the time zone at the default (user's time zone)
          
          
          let displayString = outputDatedateFormatter.string(from: date!)
          
          self.fechaLabel.text = displayString
     }
     else if(fechaConsultaGuardada == nil){
          self.fechaLabel.text = "Ningún documento enviado"
     }

     
     let motivoConsultaGuardada = docMotivoProperties?["Motivo_de_la_consulta"] as? String
     
     if( motivoConsultaGuardada != nil){
            print("TONI -> Motivo de la consulta guardada: \(motivoConsultaGuardada)")
            textView.text = motivoConsultaGuardada
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
          let docAUpdatear = database.document(withID: "motivo."+taskList.documentID)
          print("TONI -> Doc a updatear: \(taskList.documentID)")
          
          do {
               let fechaDateGuardada = Date()
               let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
               
               try docAUpdatear?.update { newRev in
                    newRev["Motivo_de_la_consulta"] = self.textView.text
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
                                    withMessage: "Imposible actualizar motivo de la consulta", withError: error)
               
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
            "type": "Texto libre: motivo de Consulta",
            "Datos": taskListInfo,
            "createdAt": CBLJSON.jsonObject(with: Date()),
            "Motivo_de_la_consulta": texto
        ]
     
               //let idDocMotivo = doc.documentID
     
          guard let doc = database.document(withID: "motivo."+taskList.documentID) else {
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
    
    func updateMotivo(motivo: CBLDocument, conTexto texto:String){
        do {
            try motivo.update {
                newRev in newRev["Motivo_de_la_consulta"] = texto
                return true
            }
        }
        catch let error as NSError {
          /*
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                                 withMessage: "Imposible actualizar motivos", withError: error)
           */
        }
    }
    
    // MARK: - Segue A COMPLETAR
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if segue.identifier == "showTaskImage" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! TaskImageViewController
            controller.task = taskForImage
            taskForImage = nil
        }*/
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == tasksLiveQuery {
            /* TONI WARNING!
            reloadTasks()
             */
        }
    }
    
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
            textView.text = "    Escribe el motivo de la consulta"
            print("TONI -> textViewDidEndEditing: \(textView.text)")
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            submitButton.isEnabled = false;
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
     if(textView.text == "    Escribe el motivo de la consulta"){
          print("TONI -> Entro en el and")
          textView.text = ""
          textView.textColor = UIColor.black
          submitButton.isEnabled = true;
     }
        textView.becomeFirstResponder()
        print("TONI -> MOTIVO: textView \(textView.text)")
    }

    
    
}

