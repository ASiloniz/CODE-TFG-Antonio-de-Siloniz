//
//  FirstPageViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 1/10/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController {

    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    @IBOutlet weak var nombreLabel: UILabel!
    
    @IBOutlet weak var motivoTextView: UITextView!
    
    @IBOutlet weak var temperaturaLabel: UILabel!
    
    @IBOutlet weak var pulsoLabel: UILabel!
    
    @IBOutlet weak var pulsiosimetriaLabel: UILabel!
    
    @IBOutlet weak var tensionLabel: UILabel!
    
    var myPageViewController: InformePageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        myPageViewController = self.parent! as? InformePageViewController
        
        print("TONI -> FirstPageViewController self.parent!: \(self.parent!)")
        print("TONI -> FirstPageViewController myPageViewController: \(myPageViewController!.taskList)")
        
        
        //print("TONI -> FirstPageViewController \(self.taskList)")
        self.taskList = myPageViewController!.taskList!
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        self.database = app.database
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        
        let nombrePaciente = docProperties?["name"] as? String
        nombreLabel.text = nombrePaciente
        
        //Mostrar motivo de la consulta:
        
        let docConsultaGuardada = database.document(withID: "motivo."+taskList.documentID)
        
        motivoTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        motivoTextView.clipsToBounds = true;
        motivoTextView.layer.cornerRadius = 10.0;
        motivoTextView.isEditable = false;
        
        
            let docMotivoProperties = docConsultaGuardada!.properties
        
        if( docMotivoProperties?["Motivo_de_la_consulta"] != nil){
            let motivoConsultaGuardada = docMotivoProperties?["Motivo_de_la_consulta"] as? String
            print("TONI -> Motivo de la consulta guardada: \(motivoConsultaGuardada)")
            motivoTextView.textColor = UIColor.black
            motivoTextView.backgroundColor = UIColor.white
            self.motivoTextView.text = motivoConsultaGuardada
        }
        else{
            self.motivoTextView.text = "Motivo de la consulta no especificado."
            motivoTextView.textColor = UIColor.lightGray
            motivoTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
        }
        
        //Mostrar ConstantesVitales:
        let docConstantesVitalesGuardadas = database.document(withID: "exploracion.constantesVitales."+taskList.documentID)
        
        
            let docPlanProperties = docConstantesVitalesGuardadas!.properties
        
        if( docPlanProperties?["Temperatura"] != nil){
            let temperaturaGuardada = docPlanProperties?["Temperatura"] as? String
            let pulsoGuardado = docPlanProperties?["Pulso"] as? String
            let oxigenoGuardado = docPlanProperties?["Pulsiosimetria"] as? String
            let sistolicaGuardada = docPlanProperties?["Tension_Sistolica"] as? String
            let diastolicaGuardada = docPlanProperties?["Tension_Diastolica"] as? String
            
            self.temperaturaLabel.text = temperaturaGuardada!
            self.temperaturaLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            self.temperaturaLabel.textColor = UIColor.black
            self.temperaturaLabel.backgroundColor = UIColor.white
            
            self.pulsoLabel.text = pulsoGuardado!
            self.pulsoLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            self.pulsoLabel.textColor = UIColor.black
            self.pulsoLabel.backgroundColor = UIColor.white

            
            self.pulsiosimetriaLabel.text = oxigenoGuardado!
            self.pulsiosimetriaLabel.textColor = UIColor.black
            self.pulsiosimetriaLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            self.pulsiosimetriaLabel.backgroundColor = UIColor.white

            
            self.tensionLabel.text = sistolicaGuardada!+"/"+diastolicaGuardada!
            self.tensionLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            self.tensionLabel.textColor = UIColor.black
            self.tensionLabel.backgroundColor = UIColor.white

        }
        else {
            self.temperaturaLabel.text = "-"
            self.temperaturaLabel.textColor = UIColor.lightGray
            self.temperaturaLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)

            self.pulsoLabel.text = "-"
            self.pulsoLabel.textColor = UIColor.lightGray
            self.pulsoLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            self.pulsiosimetriaLabel.text = "-"
            self.pulsiosimetriaLabel.textColor = UIColor.lightGray
            self.pulsiosimetriaLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
            
            self.tensionLabel.text = "-"
            self.tensionLabel.textColor = UIColor.lightGray
            self.tensionLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
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
