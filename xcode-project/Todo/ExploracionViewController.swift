//
//  ExploracionViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 13/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class ExploracionViewController: UIViewController, UITextViewDelegate {

    var taskList: CBLDocument!
    var username: String!
    var database: CBLDatabase!
    
    
    @IBOutlet weak var nombrePacienteText: UILabel!
    @IBOutlet weak var temperaturaInput: UITextField!
    @IBOutlet weak var tensionInput: UITextField!
    @IBOutlet weak var pulsoInput: UITextField!
    @IBOutlet weak var oxigenoInput: UITextField!
    @IBOutlet weak var alergiasInput: UITextView!
    @IBOutlet weak var fumadorSelector: UISegmentedControl!
    @IBOutlet weak var drogasInput: UITextField!
    @IBOutlet weak var alcoholInput: UITextField!
    @IBOutlet weak var medicacionInput: UITextView!
    @IBOutlet weak var enviarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        username = Session.username
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        let nombrePaciente = docProperties?["name"] as? String
        nombrePacienteText.text = nombrePaciente

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enviarOnClick(_ sender: AnyObject) {
        print("TONI -> Exploracion: Temperatura \(temperaturaInput.text!)")
        
        let ExploracionInfo = [
            "id": taskList.documentID,
            "owner": taskList["owner"]!
        ]
        
        let HabitosToxicos = [
            "Drogas": drogasInput.text!,
            "Medicación": medicacionInput.text
            //"Fumador": fumadorSelector.
        ] as [String : Any]
        
        let properties: Dictionary<String, Any> = [
            "type": "Texto libre: Exploración física",
            "Datos": ExploracionInfo,
            "createdAt": CBLJSON.jsonObject(with: Date()),
            "Temperatura": temperaturaInput.text!,
            "Tensión": tensionInput.text!,
            "Pulso": pulsoInput.text!,
            "Saturación de oxígeno": oxigenoInput.text!,
            "Alergias": alergiasInput.text,
            "Hábitos Tóxicos": HabitosToxicos
        ]
        
        print("TONI -> Exploracion: Documento Temperatura \(properties)")
        
        let doc = database.document(withID: "exploracion."+taskList.documentID)
        
        do {
            try doc?.putProperties(properties)
        } catch let error as NSError {
            /*
             Ui.showMessageDialog(onController: self, withTitle: "Error",
             withMessage: "Imposible guardar Motivo de la consulta", withError: error)
             */
        }
        
        //crearExploracion()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    }*/
}
