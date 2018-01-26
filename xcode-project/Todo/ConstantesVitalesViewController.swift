//
//  ConstantesVitalesViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 24/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit
import QuartzCore

class ConstantesVitalesViewController: UIViewController, UITabBarDelegate{
    
    @IBOutlet weak var tensionView: UIView!
    @IBOutlet weak var siastolicaView: UIView!
    @IBOutlet weak var diastolicaView: UIView!
    
    @IBOutlet weak var temperaturaInput: UITextField!
    @IBOutlet weak var pulsoInput: UITextField!
    @IBOutlet weak var oxigenoInput: UITextField!
    @IBOutlet weak var sistolicaInput: UITextField!
    @IBOutlet weak var diastolicaInput: UITextField!
    
    @IBOutlet weak var editButton: UIButton!
    
    var taskList: CBLDocument!
    var database: CBLDatabase!
    
    var numeroDeUnos: Int = 0
    var lengthTensiones: Int = 0
    var documentoEditado: Bool = false
    var editarPulsado: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.isHidden = true;
        
        //Coger el documento traido del TabBar
        if let tbc = tabBarController as? tabBarCustomViewController{
            self.taskList = tbc.taskList
            print("TONI -> TABBAR: taskList en ConstantesVitales => \(taskList)")
        }
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        //Get document saved
        let doc = database.document(withID: "exploracion.constantesVitales." + self.taskList.documentID)
        
        //Conseguir Documento de Constantes Vitales
        
        let docProperties = doc!.properties
        
         if(docProperties?["Temperatura"] != nil){
            let temperaturaDB = docProperties?["Temperatura"] as? String
            let pulsoDB = docProperties?["Pulso"] as? String
            let pulsiosimetriaDB = docProperties?["Pulsiosimetria"] as? String
            let tensionDiastolicaDB = docProperties?["Tension_Diastolica"] as? String
            let tensionSistolicaDB = docProperties?["Tension_Sistolica"] as? String
            
            temperaturaInput.text = temperaturaDB
            temperaturaInput.isEnabled = false
            temperaturaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            pulsoInput.text = pulsoDB
            pulsoInput.isEnabled = false
            pulsoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            oxigenoInput.text = pulsiosimetriaDB
            oxigenoInput.isEnabled = false
            oxigenoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)

            sistolicaInput.text = tensionSistolicaDB
            sistolicaInput.isEnabled = false
            sistolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            diastolicaInput.text = tensionDiastolicaDB
            diastolicaInput.isEnabled = false
            diastolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            editButton.isHidden = false;
            editButton.layer.cornerRadius = 10.0;
            editButton.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)

            
            print("TONI -> Constantes Vitales DB: TEMP=> \(temperaturaDB)")
        }
        
        
        
        temperaturaInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        pulsoInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        oxigenoInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        sistolicaInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        diastolicaInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        

    }

    func deshabilitarInputs(){
        temperaturaInput.isEnabled = false
        temperaturaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)

        pulsoInput.isEnabled = false
        pulsoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        
        oxigenoInput.isEnabled = false
        oxigenoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        
        sistolicaInput.isEnabled = false
        sistolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        
        diastolicaInput.isEnabled = false
        diastolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        
        temperaturaInput.text = temperaturaInput.text! + "º"
        pulsoInput.text = pulsoInput.text! + " (Lat/min)"
        oxigenoInput.text = oxigenoInput.text! + "%"

    }
    func compruebaTensiones(texto: String) -> Bool{
        if(texto == "1"){
            self.numeroDeUnos =  self.numeroDeUnos + 1
            self.lengthTensiones += 1
            
            if(numeroDeUnos == 1){
                print("TONI -> Constantes: PRIMER 1")
                return false
            }
            else if(numeroDeUnos == 2){
                print("TONI -> Constantes: SEGUNDO 1")
                return false
            }
            else if(numeroDeUnos == 3){
                print("TONI -> Constantes: TERCER 1")
                self.numeroDeUnos = 0
                return true
            }
        }
        return false
    }
    
    
    @IBAction func editButtonOnClick(_ sender: AnyObject) {
        self.editarPulsado = editarPulsado + 1
        
            print("TONI -> Constantes Vitales: editarPulsado = \(self.editarPulsado)")
        if(self.editarPulsado % 2 != 0){
            print("TONI -> Constantes Vitales: repinto los inputs")
            print("TONI -> Constantes Vitales: Pulso Editar")
            
            //Repinto y quito las unidades de los inputs de la pantalla de constantes vitales
            temperaturaInput.isEnabled = true;
            temperaturaInput.backgroundColor = UIColor.white
            //Con estas sentencias quito el último caracter de temp, es decir, el "º"
            let endIndexTemp = temperaturaInput.text!.index(temperaturaInput.text!.endIndex, offsetBy: -1)
            let truncatedTemp = temperaturaInput.text!.substring(to: endIndexTemp)
            temperaturaInput.text! = truncatedTemp
            
            pulsoInput.isEnabled = true;
            pulsoInput.backgroundColor = UIColor.white
            let endIndexPulso = pulsoInput.text!.index(pulsoInput.text!.endIndex, offsetBy: -10)
            let truncatedPulso = pulsoInput.text!.substring(to: endIndexPulso)
            pulsoInput.text! = truncatedPulso

            oxigenoInput.isEnabled = true;
            oxigenoInput.backgroundColor = UIColor.white
            let endIndexOxigeno = oxigenoInput.text!.index(oxigenoInput.text!.endIndex, offsetBy: -1)
            let truncatedOxigeno = oxigenoInput.text!.substring(to: endIndexOxigeno)
            oxigenoInput.text! = truncatedOxigeno
            
            sistolicaInput.isEnabled = true;
            sistolicaInput.backgroundColor = UIColor.white

            diastolicaInput.isEnabled = true;
            diastolicaInput.backgroundColor = UIColor.white
            
            //Equivalente a decir cuando se pulsa en enviar:
            editButton.setTitle("Enviar", for: .normal)
            editButton.backgroundColor = UIColor.white
            
            //Quito que dejen de estar atentos los input a cualquier cambio.
            temperaturaInput.removeTarget(nil, action: nil, for: .allEvents)
            pulsoInput.removeTarget(nil, action: nil, for: .allEvents)
            oxigenoInput.removeTarget(nil, action: nil, for: .allEvents)
            sistolicaInput.removeTarget(nil, action: nil, for: .allEvents)
            diastolicaInput.removeTarget(nil, action: nil, for: .allEvents)
        }
            
        else if(self.editarPulsado % 2 == 0){
            print("TONI -> Constantes Vitales: Pulso Enviar")
            comprobadorDeCambios()
        }
        

    }
    func comprobadorDeCambios(){
    
        //Comprobación de los valores guardados en el documento:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        let doc = database.document(withID: "exploracion.constantesVitales." + self.taskList.documentID)
        let docProperties = doc!.properties
        
        let temperaturaDB = docProperties?["Temperatura"] as? String
        let pulsoDB = docProperties?["Pulso"] as? String
        let pulsiosimetriaDB = docProperties?["Pulsiosimetria"] as? String
        let tensionDiastolicaDB = docProperties?["Tension_Diastolica"] as? String
        let tensionSistolicaDB = docProperties?["Tension_Sistolica"] as? String
        
        let docConAlgunaVariacion = ((temperaturaDB! != self.temperaturaInput.text!+"º") || (pulsoDB! != self.pulsoInput.text!+" (Lat/min)") || (pulsiosimetriaDB! != self.oxigenoInput.text!+"%") || (tensionSistolicaDB! != self.sistolicaInput.text!) || (tensionDiastolicaDB! != self.diastolicaInput.text!))
        
        if(docConAlgunaVariacion == true){
            editButton.setTitle("Editar", for: .normal)
            print("TONI -> Constantes Vitales: título botón => \(editButton.titleLabel?.text!)")
            editButton.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            self.documentoEditado = true
            crearDocumentoConstantesVitales()
            deshabilitarInputs()
            //Ui.showMessageDialog(onController: self, withTitle: "Documento Constantes Vitales", withMessage: "Documento actualizado con éxito")
            
        }
        else{
            Ui.showMessageDialog(onController: self, withTitle: "Error de envío", withMessage: "Ninguna constante vital actualizada")
            self.editarPulsado = editarPulsado - 1
        }
        
        //self.editarPulsado = self.editarPulsado + 1

    }
    func editingChanged(_ textField: UITextField) {
        
        
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let temperaturaAGuardar = temperaturaInput.text, !temperaturaAGuardar.isEmpty,
            let pulsoAGuardar = pulsoInput.text, !pulsoAGuardar.isEmpty,
            let oxigenoAGuardar = oxigenoInput.text, !oxigenoAGuardar.isEmpty,
            let sistolicaAGuardar = sistolicaInput.text, !sistolicaAGuardar.isEmpty,
            let diastolicaAGuardar = diastolicaInput.text, ((diastolicaAGuardar.characters.count == 2 && (diastolicaAGuardar[diastolicaAGuardar.startIndex] != "1")) || (diastolicaAGuardar.characters.count == 3))
            
            /*
                let goal = goalField.text, !goal.isEmpty,
                let frequency = frequencyField.text, !frequency.isEmpty
            */
            else {
                var contador = 0
                print("TONI -> ConstantesVitales: Temperatura No escrita: \(contador)")
                return
        }
        print("TONI -> ConstantesVitales: Temperatura Escrita= \(textField.text)")
        Ui.showMessageDialog(onController: self, withTitle: "Documento guardado", withMessage: "Constantes guardadas con éxito.")
        
        //Crear botón de editar:
        editButton.isHidden = false;
        editButton.layer.cornerRadius = 10.0;
        editButton.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        
        //Deshabilitar y repintar los textFields
        temperaturaInput.text = temperaturaInput.text! + "º"
        temperaturaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        temperaturaInput.isEnabled = false
        
        pulsoInput.text = pulsoInput.text! + " (Lat/min)"
        pulsoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        pulsoInput.isEnabled = false
        
        oxigenoInput.text = oxigenoInput.text! + "%"
        oxigenoInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        oxigenoInput.isEnabled = false
        
        sistolicaInput.text = sistolicaInput.text!
        sistolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        sistolicaInput.isEnabled = false
        
        diastolicaInput.text = diastolicaInput.text!
        diastolicaInput.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        diastolicaInput.isEnabled = false
        
        editButton.isHidden = false;
        editButton.layer.cornerRadius = 10.0;
        
        //Crear el documento de la DB.
        crearDocumentoConstantesVitales()
        
        
        //doneBarButton.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Pintar línea separatoria de Tensiones
        let anchoTodaView = self.siastolicaView.bounds.width * (63/64)
        let anchoView = self.siastolicaView.frame.size.width
        print("TONI -> AnchoTodaView: \(anchoTodaView)")
        print("TONI -> AnchoView: \(anchoView)")
        let border = CALayer()
        border.backgroundColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: 0, width: anchoTodaView, height: 2)
        diastolicaView.layer.addSublayer(border)
    }
    
    func changeBackground(){
        self.view.backgroundColor = UIColor.red
    }
    
    func crearDocumentoConstantesVitales(){
        if(self.documentoEditado == false){
            let ExploracionInfo = [
                "id": taskList.documentID,
                "owner": taskList["owner"]!
            ]
            
            let properties: Dictionary<String, Any> = [
                "type": "Texto libre: Constantes Vitales",
                "Datos": ExploracionInfo,
                "createdAt": CBLJSON.jsonObject(with: Date()),
                "Temperatura": temperaturaInput.text!,
                "Tension_Sistolica": sistolicaInput.text!,
                "Tension_Diastolica": diastolicaInput.text!,
                "Pulso": pulsoInput.text!,
                "Pulsiosimetria": oxigenoInput.text!
            ]
            
            print("TONI -> Exploracion: Documento Temperatura \(properties)")
            
            let doc = database.document(withID: "exploracion.constantesVitales."+taskList.documentID)
            
            do {
                try doc?.putProperties(properties)
            } catch let error as NSError {
                /*
                 Ui.showMessageDialog(onController: self, withTitle: "Error",
                 withMessage: "Imposible guardar Motivo de la consulta", withError: error)
                 */
            }
        }
        
        else{
            let docAUpdatear = database.document(withID: "exploracion.constantesVitales."+taskList.documentID)
            print("TONI -> Doc a updatear: \(taskList.documentID)")
            
            do {
                let fechaDateGuardada = Date()
                let fechaJSON = CBLJSON.jsonObject(with: fechaDateGuardada)
                
                try docAUpdatear?.update { newRev in
                    newRev["Temperatura"] = self.temperaturaInput.text!+"º"
                    newRev["Pulso"] = self.pulsoInput.text!+" (Lat/min)"
                    newRev["Pulsiosimetria"] = self.oxigenoInput.text!+"%"
                    newRev["Tension_Sistolica"] = self.sistolicaInput.text!
                    newRev["Tension_Diastolica"] = self.diastolicaInput.text!
                    newRev["createdAt"] = fechaJSON
                    
                    return true
                    
                }
            }
            catch let error as NSError {
                print("TONI -> Error raro de updates: \(error)")
                
                Ui.showMessageDialog(onController: self, withTitle: "Error",
                                     withMessage: "Imposible actualizar constantes", withError: error)
                
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        diastolicaView.contentMode = .redraw

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        let tap1 = UITapGestureRecognizer(target: self, action: "onSingleTap")
        let tap2 = UITapGestureRecognizer(target: self, action: "onDoubleTap")
        tap2.numberOfTapsRequired = 2
        
        // create a view and put it on top of the textfield
        // here created at viewDidAppear for example but you can do it better
        
        let dummieView = UIView(frame: self.temperaturaInput.frame)
        dummieView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25)
        self.temper.addSubview(dummieView)
        dummieView.addGestureRecognizer(tap1)
        dummieView.addGestureRecognizer(tap2)
    }
    
    func onSingleTap(){
        print("TONI -> ConstantesVitales: custom single tap")
        if self.temperaturaInput.isFirstResponder {
            print("TONI -> ConstantesVitales: temperatura isFirstResponder")
            self.temperaturaInput.resignFirstResponder()
        }
    }
    
    func onDoubleTap(){
        print("TONI -> ConstantesVitales: custom double tap")
        self.temperaturaInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.temperaturaInput.isFirstResponder {
            self.temperaturaInput.resignFirstResponder()
        }
        return true
    }

    */
    
    

}
