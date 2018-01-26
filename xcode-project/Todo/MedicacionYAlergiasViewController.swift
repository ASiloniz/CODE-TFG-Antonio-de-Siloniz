//
//  MedicacionYAlergiasViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 27/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class MedicacionYAlergiasViewController: UIViewController, UITextViewDelegate  {

    
    @IBOutlet weak var medicacionTextView: UITextView!
    @IBOutlet weak var editarMedicationButton: UIButton!
    
    @IBOutlet weak var alergiasTextView: UITextView!
    @IBOutlet weak var editarAlergiasButton: UIButton!
    
    @IBOutlet weak var enviarButton: UIButton!
    
    var taskList: CBLDocument!
    var database: CBLDatabase!
    
    var documentoMedicacionEditado: Bool = false
    var documentoAlergiasEditado: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         medicacionTextView.delegate = self
         alergiasTextView.delegate = self
        
        
        //Coger el documento traido del TabBar
        if let tbc = tabBarController as? tabBarCustomViewController{
            self.taskList = tbc.taskList
            print("TONI -> TABBAR: taskList en Medicacion y Alergias => \(taskList)")
        }
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        
        //Preparacion de los textViews de Medicacion y Alergias
        if (medicacionTextView.text == "") {
            print("TONI -> Medicacion y alergias viewDidLoad=> medicacion: \(medicacionTextView.text)")
            textViewDidEndEditing(medicacionTextView)
        }
        let tapMedicacionDismiss = UITapGestureRecognizer(target: self, action: #selector(MedicacionYAlergiasViewController.medicacionDismissKeyboard))
        self.view.addGestureRecognizer(tapMedicacionDismiss)

        if (alergiasTextView.text == "") {
            print("TONI -> Medicacion y alergias viewDidLoad=> alergias: \(alergiasTextView.text)")
            textViewDidEndEditing(alergiasTextView)
        }
        let tapAlergiasDismiss = UITapGestureRecognizer(target: self, action: #selector(MedicacionYAlergiasViewController.alergiasDismissKeyboard))
        self.view.addGestureRecognizer(tapAlergiasDismiss)
        

        //Apariencia TextView y botones:
        medicacionTextView.clipsToBounds = true;
        medicacionTextView.layer.cornerRadius = 10.0;
        editarMedicationButton.layer.cornerRadius = 10.0;
        editarMedicationButton.isEnabled = false;
        
        alergiasTextView.clipsToBounds = true;
        alergiasTextView.layer.cornerRadius = 10.0;
        editarAlergiasButton.layer.cornerRadius = 10.0;
        editarAlergiasButton.isEnabled = false;
        
        enviarButton.layer.cornerRadius = 10.0;
        enviarButton.isEnabled = false;
        

        // Mostrar texto enviado al centro:
        
        //Creas un documento y luego rellenas su motivo
        let docMedicacionYAlergiasGuardadas = database.document(withID: "exploracion.medicacionYAlergias." + self.taskList.documentID)
        let docProperties = docMedicacionYAlergiasGuardadas!.properties
        
        let medicacionGuardada = docProperties?["Medicacion"] as? String
        let alergiasGuardadas = docProperties?["Alergias"] as? String
        
        if( medicacionGuardada != nil){
            print("TONI -> Medicación y Alergias View=> Medicación Guardada: \(medicacionGuardada)")
            medicacionTextView.text = medicacionGuardada
            medicacionTextView.textColor = UIColor.black
            medicacionTextView.isEditable = false;
            medicacionTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            editarMedicationButton.isEnabled = true;
        }
        
        if( alergiasGuardadas != nil){
            print("TONI -> Medicación y Alergias View=> Alergias Guardadas: \(medicacionGuardada)")
            alergiasTextView.text = alergiasGuardadas
            alergiasTextView.textColor = UIColor.black
            alergiasTextView.isEditable = false;
            alergiasTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            editarAlergiasButton.isEnabled = true;
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Metodo para crear documento con Medicacion y Alergias
    func crearTexto(textoMedicacion: String, textoAlergias: String ) -> CBLSavedRevision? {
        let taskListInfo = [
            "id": taskList.documentID,
            "owner": taskList["owner"]!
        ]
        
        let properties: Dictionary<String, Any> = [
            "type": "Texto libre: Medicación y Alergias",
            "Datos": taskListInfo,
            "createdAt": CBLJSON.jsonObject(with: Date()),
            "Medicacion": textoMedicacion,
            "Alergias": textoAlergias
        ]
        
        //let idDocMotivo = doc.documentID
        
        guard let doc = database.document(withID: "exploracion.medicacionYAlergias." + taskList.documentID) else {
            /*
            Ui.showMessageDialog(onController: self, withTitle: "Error",
                                 withMessage: "Imposible crear documento Motivo")*/
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

    @IBAction func medicacionEditButtonOnClick(_ sender: AnyObject) {
        self.medicacionTextView.isEditable = true;
        self.medicacionTextView.backgroundColor = UIColor.white
        self.documentoMedicacionEditado = true;
        self.enviarButton.isEnabled = true;
        self.editarMedicationButton.isEnabled = false;

    }
    
    @IBAction func editarAlergiasButtonOnClick(_ sender: AnyObject) {
        self.alergiasTextView.isEditable = true;
        self.alergiasTextView.backgroundColor = UIColor.white
        self.documentoAlergiasEditado = true;
        self.enviarButton.isEnabled = true;
        self.editarAlergiasButton.isEnabled = false;

    }
    
    @IBAction func enviarButtonOnClick(_ sender: AnyObject) {
        
        if((self.documentoMedicacionEditado == true) && (self.documentoAlergiasEditado != true) ){
            let docAUpdatear = database.document(withID: "exploracion.medicacionYAlergias."+taskList.documentID)
            print("TONI -> Doc de medicacion a updatear: \(taskList.documentID)")
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Medicacion"] = self.medicacionTextView.text
                    newRev["createdAt"] = fechaJSON
                    return true
                }
                
            } catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
            }
            
        }
            
        if((self.documentoMedicacionEditado != true) && (self.documentoAlergiasEditado == true) ){
            let docAUpdatear = database.document(withID: "exploracion.medicacionYAlergias."+taskList.documentID)
            print("TONI -> Doc de medicacion a updatear: \(taskList.documentID)")
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Alergias"] = self.alergiasTextView.text
                    newRev["createdAt"] = fechaJSON
                    return true
                }
                
            } catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
            }
            
        }
            
        if((self.documentoMedicacionEditado == true) && (self.documentoAlergiasEditado == true) ){
            let docAUpdatear = database.document(withID: "exploracion.medicacionYAlergias."+taskList.documentID)
            print("TONI -> Doc de medicacion a updatear: \(taskList.documentID)")
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Alergias"] = self.alergiasTextView.text
                    newRev["Medicacion"] = self.medicacionTextView.text
                    newRev["createdAt"] = fechaJSON
                    return true
                }
                
            } catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
            }
            
        }
            
        else if((self.documentoMedicacionEditado != true) && (self.documentoAlergiasEditado != true)){
            crearTexto(textoMedicacion: medicacionTextView.text, textoAlergias: alergiasTextView.text)
            
        }
        
        //self.getTimeYPonerTime()
        
        self.enviarButton.isEnabled = false;
        
        self.medicacionTextView.isEditable = false;
        self.medicacionTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        self.editarMedicationButton.isEnabled = true;
        
        self.alergiasTextView.isEditable = false;
        self.alergiasTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        self.editarAlergiasButton.isEnabled = true;
        
        
        self.documentoMedicacionEditado = true;
        self.documentoAlergiasEditado = true;

    }
    
    func updateMedicacion(medicacionYAlergiasDoc: CBLDocument, conTexto texto: String){
        do {
            try medicacionYAlergiasDoc.update {
                newRev in newRev["Medicacion"] = texto
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
    
    func updateAlergias(medicacionYAlergiasDoc: CBLDocument, conTexto texto: String){
        do {
            try medicacionYAlergiasDoc.update {
                newRev in newRev["Alergias"] = texto
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

    
    func medicacionDismissKeyboard(){
        medicacionTextView.resignFirstResponder()
    }
    
    func alergiasDismissKeyboard(){
        alergiasTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView == medicacionTextView){
            if (textView.text == "") {
                print("TONI -> textViewDidEndEditing: \(textView.text)")
                textView.text = "    Escribir la medicación consumida por el paciente"
                print("TONI -> textViewDidEndEditing: \(textView.text)")
                textView.textColor = UIColor.lightGray
                textView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
                enviarButton.isEnabled = false;
            }
            textView.resignFirstResponder()
        }
        else if(textView == alergiasTextView){
            if (textView.text == "") {
                print("TONI -> textViewDidEndEditing: \(textView.text)")
                textView.text = "    Escribir las alergias del paciente"
                print("TONI -> textViewDidEndEditing: \(textView.text)")
                textView.textColor = UIColor.lightGray
                textView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
                enviarButton.isEnabled = false;
            }
            textView.resignFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if(textView == medicacionTextView){
            print("TONI -> Entro en el medicacionBeginEditing")
            if(textView.text == "    Escribir la medicación consumida por el paciente"){
                textView.text = ""
                textView.textColor = UIColor.black
                //submitButton.isEnabled = true;
            }
            textView.becomeFirstResponder()
            print("TONI -> MOTIVO: textView \(textView.text)")
        }
        else if(textView == alergiasTextView){
            if(textView.text == "    Escribir las alergias del paciente"){
                textView.text = ""
                textView.textColor = UIColor.black
                enviarButton.isEnabled = true;
            }
            textView.becomeFirstResponder()
            print("TONI -> MOTIVO: textView \(textView.text)")
        }
    }
    
    /*
    func alergiasTextViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            print("TONI -> textViewDidEndEditing: \(textView.text)")
            textView.text = "    Escribir las alergias del paciente"
            print("TONI -> textViewDidEndEditing: \(textView.text)")
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            enviarButton.isEnabled = false;
        }
        textView.resignFirstResponder()
    }
    
    func alergiasTextViewDidBeginEditing(_ textView: UITextView){
        if(textView.text == "    Escribir las alergias del paciente"){
            textView.text = ""
            textView.textColor = UIColor.black
            enviarButton.isEnabled = true;
        }
        textView.becomeFirstResponder()
        print("TONI -> MOTIVO: textView \(textView.text)")
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
