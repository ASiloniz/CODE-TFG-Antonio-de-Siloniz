//
//  HabitosToxicosViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 28/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class HabitosToxicosViewController: UIViewController, UITextViewDelegate  {

    
    @IBOutlet weak var tabacoSelector: UISegmentedControl!
    @IBOutlet weak var alcoholSelector: UISegmentedControl!
    @IBOutlet weak var alcoholTextView: UITextView!
    @IBOutlet weak var edadLabel: UILabel!
    @IBOutlet weak var edadPicker: UIDatePicker!
    @IBOutlet weak var enviarButton: UIButton!
    
    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    var seleccionTabaco: String = "No Fumador"
    var seleccionAlcohol: String = "No Consumidor"
    var seleccionTextoAlcohol: String = "Consumo no relevante para la consulta"

    var consumidorAlcohol: Bool = false
    var sinVariacion: Bool = false
    
    var enviarPulsado: Int = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alcoholTextView.delegate = self
        
        //Coger el documento traido del TabBar
        if let tbc = tabBarController as? tabBarCustomViewController{
            self.taskList = tbc.taskList
            print("TONI -> TABBAR: taskList en ConstantesVitales => \(taskList)")
        }

        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        let doc = database.document(withID: "exploracion.HabitosToxicos." + self.taskList.documentID)
        let docProperties = doc!.properties
        let textoAlcoholDB = docProperties?["Descripcion_consumo_alcohol"] as? String
        let edadDB = docProperties?["Edad"] as? String
        
        //Apariencia TextView y botones:
        alcoholTextView.clipsToBounds = true;
        alcoholTextView.layer.cornerRadius = 10.0;
        
        if(textoAlcoholDB != nil){
            edadLabel.text = edadDB
            alcoholSelector.selectedSegmentIndex = 1
            alcoholTextView.isEditable = false;
            alcoholTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            
            if(textoAlcoholDB == "Consumo no relevante para la consulta"){
               alcoholTextView.textColor = UIColor.lightGray
            }
            else{
                alcoholTextView.text = textoAlcoholDB!
                alcoholTextView.textColor = UIColor.black
            }
            
            alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            self.seleccionTextoAlcohol = textoAlcoholDB!
            
            self.enviarPulsado = self.enviarPulsado + 1
            enviarButton.isEnabled = true;
            enviarButton.layer.cornerRadius = 10.0;
            enviarButton.setTitle("Editar", for: .normal)
            enviarButton.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
           
            tabacoSelector.isEnabled = false;
            alcoholSelector.isEnabled = false;
            

        }
        else if(textoAlcoholDB == nil){
            alcoholTextView.text = "Consumo no relevante para la consulta"
            alcoholTextView.textColor = UIColor.lightGray
            alcoholTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            alcoholTextView.isEditable = false;
            self.seleccionTextoAlcohol = "Consumo no relevante para la consulta"
            enviarButton.isEnabled = false;

        }
        
        
            enviarButton.layer.cornerRadius = 10.0;
        
        
        edadPicker.setValue(UIColor.white, forKey: "textColor")
        //comprobadorDeCambios()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tabacoSegmentedAction(_ sender: AnyObject) {
        if(tabacoSelector.selectedSegmentIndex == 0){
            self.seleccionTabaco = "No Fumador"
        }
        else if(tabacoSelector.selectedSegmentIndex == 1){
            self.seleccionTabaco = "Fumador"

        }
    }
    
    
    @IBAction func calculaEdadDatePicker(_ sender: AnyObject) {
        let gregorian = Calendar(identifier: .gregorian)
        let ageComponents = gregorian.dateComponents([.year], from: edadPicker.date, to: Date())
        let age = ageComponents.year!
        edadLabel.text = age.description + " años"
        enviarButton.isEnabled = true;
        
    }
    
    @IBAction func alcoholSegmentedAction(_ sender: AnyObject) {
        if(alcoholSelector.selectedSegmentIndex == 0){
            self.seleccionAlcohol = "No Consumidor"
            alcoholTextView.text = "Consumo no relevante para la consulta"
            alcoholTextView.textColor = UIColor.lightGray
            alcoholTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            alcoholTextView.isEditable = false;
            alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            //self.seleccionTextoAlcohol = "Consumo no relevante para la consulta"


        }
        else if(alcoholSelector.selectedSegmentIndex == 1){
            self.seleccionAlcohol = "Consumidor"
            
            let app = UIApplication.shared.delegate as! AppDelegate
            database = app.database
            let doc = database.document(withID: "exploracion.HabitosToxicos." + self.taskList.documentID)
            let docProperties = doc!.properties
            let textoAlcoholDB = docProperties?["Descripcion_consumo_alcohol"] as? String
            
            //Apariencia TextView y botones:
            alcoholTextView.clipsToBounds = true;
            alcoholTextView.layer.cornerRadius = 10.0;
            
            if(textoAlcoholDB != nil){
                
                if(textoAlcoholDB == "Consumo no relevante para la consulta"){
                    alcoholTextView.text = ""
                }
                else{
                    alcoholTextView.text = textoAlcoholDB!
                }
                alcoholTextView.text = textoAlcoholDB
                alcoholTextView.textColor = UIColor.black
                alcoholTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
                alcoholTextView.isEditable = true;
                alcoholTextView.backgroundColor = UIColor.white
            }
            else{
                alcoholTextView.text = ""
                
                alcoholTextView.textColor = UIColor.black
                alcoholTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
                alcoholTextView.isEditable = true;
                alcoholTextView.backgroundColor = UIColor.white
 
            }
            self.consumidorAlcohol = true
        }

    }
    
    @IBAction func enviarButtonOnClick(_ sender: AnyObject) {
        
        //Pulso enviar y lo transformo a Editar
        if(self.enviarPulsado % 2 == 0){
            print("TONI -> Habitos toxicos: pulso Enviar => \(self.enviarPulsado)")
            if(self.consumidorAlcohol == true){
                self.seleccionTextoAlcohol = self.alcoholTextView.text
            }
            
            
            comprobadorDeCambios()
            self.enviarPulsado = self.enviarPulsado + 1
            if(self.sinVariacion == false){
                edadPicker.isEnabled = false;
                alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
                alcoholTextView.isEditable = false;
                tabacoSelector.isEnabled = false;
                alcoholSelector.isEnabled = false;
                
                enviarButton.setTitle("Editar", for: .normal)
                enviarButton.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            }
            else if(self.sinVariacion == true){
                print("Ahora veo!")
            }
            
            print("TONI -> Habitos toxicos: tras pulsar Enviar, ahora vale => \(self.enviarPulsado)")
        }
            
        //Pulso Editar y lo transformo en enviar
        else if(self.enviarPulsado % 2 != 0){
            print("TONI -> Habitos toxicos: pulso Editar => \(self.enviarPulsado)")
            edadPicker.isEnabled = true;
            tabacoSelector.isEnabled = true;
            alcoholSelector.isEnabled = true;
            
                
            enviarButton.setTitle("Enviar", for: .normal)
            enviarButton.backgroundColor = UIColor.white
            self.enviarPulsado = self.enviarPulsado + 1
            print("TONI -> Habitos toxicos: tras pulsar Editar, ahora vale => \(self.enviarPulsado)")
        }
        
    }
    
    func comprobadorDeCambios(){
        
        //Comprobación de los valores guardados en el documento:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        let doc = database.document(withID: "exploracion.HabitosToxicos." + self.taskList.documentID)
        let docProperties = doc!.properties
        
        let fumadorDB = docProperties?["Fumador"] as? String
        let alcoholDB = docProperties?["Alcohol"] as? String
        let textoAlcoholDB = docProperties?["Descripcion_consumo_alcohol"] as? String
        let edadDB = docProperties?["Edad"] as? String
        

        if(fumadorDB != nil){
            
            let docConAlgunaVariacion = ((fumadorDB! != self.seleccionTabaco) || (alcoholDB! != self.seleccionAlcohol) || (textoAlcoholDB! != self.alcoholTextView.text!) || (edadDB! != self.edadLabel.text!))
            if(docConAlgunaVariacion == true){
                //self.enviarPulsado = self.enviarPulsado + 1
                crearTexto(textoAlcohol: self.alcoholTextView.text)
                self.sinVariacion = false;
                print("TONI -> HabitosToxicos => comprobadorDeCambios: DOC CON CAMBIOS!")
                print("TONI -> HabitosToxicos => fumadorDB => \(fumadorDB)")
                print("TONI -> HabitosToxicos => alcoholDB => \(alcoholDB)")
                print("TONI -> HabitosToxicos => textoAlcoholDB => \(textoAlcoholDB)")
                print("TONI -> HabitosToxicos => edadDB => \(edadDB)")
                
                //Ui.showMessageDialog(onController: self, withTitle: "Documento Constantes Vitales", withMessage: "Documento actualizado con éxito")
                
            }
            else if(docConAlgunaVariacion != true){
                print("TONI -> HabitosToxicos => comprobadorDeCambios: WARNING! Doc sin cambios!")
                Ui.showMessageDialog(onController: self, withTitle: "Error de envío", withMessage: "Ningún hábito tóxico actualizado")
                self.sinVariacion = true;
                self.enviarPulsado = self.enviarPulsado - 1
            }
        }else{
            crearTexto(textoAlcohol: self.alcoholTextView.text)
        }
    }


    //Metodo para crear documento de habitos toxicos
    func crearTexto(textoAlcohol: String){

        if(self.enviarPulsado == 0){
            let taskListInfo = [
                "id": taskList.documentID,
                "owner": taskList["owner"]!
            ]
            
            let properties: Dictionary<String, Any> = [
                "type": "Texto libre: Hábitos Tóxicos",
                "Datos": taskListInfo,
                "createdAt": CBLJSON.jsonObject(with: Date()),
                "Fumador": self.seleccionTabaco,
                "Alcohol": self.seleccionAlcohol,
                "Descripcion_consumo_alcohol": self.alcoholTextView.text!,
                "Edad": self.edadLabel.text!
            ]
            
            //let idDocMotivo = doc.documentID
            
            let doc = database.document(withID: "exploracion.HabitosToxicos." + taskList.documentID)
            
            do {
                try doc?.putProperties(properties)
                //return
            } catch let error as NSError {
                /*
                 Ui.showMessageDialog(onController: self, withTitle: "Error",
                 withMessage: "Imposible guardar hábitos tóxicos", withError: error)
                */
                //return nil
            }
        }
        else if(self.enviarPulsado != 0){
            //let doc = database.document(withID: "exploracion.HabitosToxicos." + taskList.documentID)
            //comprobadorDeCambios()
            let docAUpdatear = database.document(withID: "exploracion.HabitosToxicos."+taskList.documentID)
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Fumador"] = self.seleccionTabaco
                    newRev["Edad"] = self.edadLabel.text!
                    newRev["Alcohol"] = self.seleccionAlcohol
                    newRev["Descripcion_consumo_alcohol"] = self.alcoholTextView.text!
                    newRev["createdAt"] = fechaJSON
                    
                    return true
                }
            }
            catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
                
                Ui.showMessageDialog(onController: self, withTitle: "Error",
                                     withMessage: "Imposible actualizar hábitos tóxicos", withError: error)
             
                //return nil
            }
        }
}
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
