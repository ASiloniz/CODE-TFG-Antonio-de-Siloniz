//
//  SecondPageViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 1/10/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class SecondPageViewController: UIViewController {

    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var medicacionTextView: UITextView!
    
    @IBOutlet weak var alergiasTextView: UITextView!
    
    @IBOutlet weak var consumoTabacoLabel: UILabel!
    
    @IBOutlet weak var consumoAlcoholLabel: UILabel!
    
    @IBOutlet weak var alcoholTextView: UITextView!
    
    var myPageViewController: InformePageViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPageViewController = self.parent! as? InformePageViewController
        //print("TONI -> FirstPageViewController \(self.taskList)")
        self.taskList = myPageViewController!.taskList!
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        self.database = app.database
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        
        let nombrePaciente = docProperties?["name"] as? String
        nombreLabel.text = nombrePaciente
        
        //Mostrar Medicación:
         let docMedicacionGuardada = database.document(withID: "exploracion.medicacionYAlergias."+taskList.documentID)
         
         print("TONI -> Medicacion Guardada: \(docMedicacionGuardada)")
         medicacionTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
         medicacionTextView.clipsToBounds = true;
         medicacionTextView.layer.cornerRadius = 10.0;
         medicacionTextView.isEditable = false;
         
         
         let docMedicacionProperties = docMedicacionGuardada!.properties
         print("TONI -> Medicacion Guardada: \(docMedicacionProperties)")
         
         if( docMedicacionProperties?["Medicacion"] != nil){
         
            let medicacionGuardada = docMedicacionProperties?["Medicacion"] as? String
            print("TONI -> Medicacion Guardada: \(medicacionGuardada)")
            medicacionTextView.textColor = UIColor.black
            medicacionTextView.backgroundColor = UIColor.white
            self.medicacionTextView.text = medicacionGuardada
         }
         else{
            self.medicacionTextView.text = "Medicación del paciente sin especificar."
            medicacionTextView.textColor = UIColor.lightGray
            medicacionTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
         }
        
        //Mostrar Alergias:
        let docAlergiaGuardada = database.document(withID: "exploracion.medicacionYAlergias."+taskList.documentID)
        
        print("TONI -> Medicacion Guardada: \(docAlergiaGuardada)")
        alergiasTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        alergiasTextView.clipsToBounds = true;
        alergiasTextView.layer.cornerRadius = 10.0;
        alergiasTextView.isEditable = false;
        
        let docAlergiasProperties = docAlergiaGuardada!.properties
        print("TONI -> Medicacion Guardada: \(docAlergiasProperties)")
        
        if( docAlergiasProperties?["Alergias"] != nil){
            
            let alergiaGuardada = docAlergiasProperties?["Alergias"] as? String
            alergiasTextView.textColor = UIColor.black
            alergiasTextView.backgroundColor = UIColor.white
            self.alergiasTextView.text = alergiaGuardada
        }
        else{
            self.alergiasTextView.text = "Alergias del paciente sin especificar."
            alergiasTextView.textColor = UIColor.lightGray
            alergiasTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        }
        
        //Mostrar Hábitos Tóxicos:
        //Mostrar Tabaco:
        let docHabitosToxicosGuardados = database.document(withID: "exploracion.HabitosToxicos."+taskList.documentID)
        consumoTabacoLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        consumoAlcoholLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        
        let docHabitosProperties = docHabitosToxicosGuardados!.properties
        
        if( docHabitosProperties?["Fumador"] != nil){
            
            let fumadorGuardado = docHabitosProperties?["Fumador"] as? String
            
            self.consumoTabacoLabel.text = fumadorGuardado!
            self.consumoTabacoLabel.textColor = UIColor.black
            self.consumoTabacoLabel.backgroundColor = UIColor.white
            self.consumoTabacoLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)

        }
        else{
            self.consumoTabacoLabel.text = "-"
            self.consumoTabacoLabel.textColor = UIColor.lightGray
            self.consumoTabacoLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        }
        
        //Mostrar Alcohol:
        if(docHabitosProperties?["Alcohol"] != nil){
            let alcoholGuardado = docHabitosProperties?["Alcohol"] as? String
            if(alcoholGuardado == "No Consumidor"){
                
                consumoAlcoholLabel.text = alcoholGuardado
                consumoAlcoholLabel.backgroundColor = UIColor.white
                
                self.alcoholTextView.text = "Consumo no relevante para la consulta."
                alcoholTextView.textColor = UIColor.lightGray
                alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
                alcoholTextView.clipsToBounds = true;
                alcoholTextView.layer.cornerRadius = 10.0;
                
            }
            else if(alcoholGuardado == "Consumidor"){
                let alcoholGuardado = docHabitosProperties?["Descripcion_consumo_alcohol"] as? String
                consumoAlcoholLabel.text = "Consumidor"
                
                self.alcoholTextView.text = alcoholGuardado
                alcoholTextView.textColor = UIColor.black
                alcoholTextView.backgroundColor = UIColor.white
                
                self.consumoTabacoLabel.textColor = UIColor.black
                self.consumoTabacoLabel.backgroundColor = UIColor.white
                self.consumoTabacoLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            }
            
        }
        else{
            self.consumoAlcoholLabel.text = "-"
            self.consumoAlcoholLabel.textColor = UIColor.lightGray
            self.consumoAlcoholLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            self.alcoholTextView.text = "Consumo de alcohol no especificado."
            alcoholTextView.textColor = UIColor.lightGray
            alcoholTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            alcoholTextView.clipsToBounds = true;
            alcoholTextView.layer.cornerRadius = 10.0;
        }
        
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
