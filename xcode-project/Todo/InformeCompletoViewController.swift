//
//  InformeCompletoViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 18/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class InformeCompletoViewController: UIViewController {
    
    var database: CBLDatabase!
    var taskList: CBLDocument!
    

    
    @IBOutlet weak var edadLabel: UILabel!
    @IBOutlet weak var nombrePacienteText: UILabel!
    
    @IBOutlet weak var motivoDataText: UITextView!
    
    @IBOutlet weak var planDataText: UITextView!
    
    
    @IBOutlet weak var temperaturaText: UILabel!
    @IBOutlet weak var pulsoText: UILabel!
    
    @IBOutlet weak var pulsiosimetriaLabel: UILabel!
    @IBOutlet weak var tensionLabel: UILabel!
    
    @IBOutlet weak var medicacionTextView: UITextView!
    
    @IBOutlet weak var alergiasTextView: UITextView!
    
    @IBOutlet weak var fumadorLabel: UILabel!
    
    @IBOutlet weak var alcoholLabel: UILabel!
    
    @IBOutlet weak var alcoholTextView: UITextView!
    
    @IBOutlet weak var planTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        let doc = database.document(withID: taskList.documentID)
        let docProperties = doc!.properties
        let nombrePaciente = docProperties?["name"] as? String
        nombrePacienteText.text = nombrePaciente
        
        //Mostrar motivo de la consulta:
        
        let docConsultaGuardada = database.document(withID: "motivo."+taskList.documentID)
        
        if( docConsultaGuardada != nil){
            let docMotivoProperties = docConsultaGuardada!.properties
            let motivoConsultaGuardada = docMotivoProperties?["Motivo_de_la_consulta"] as? String
            print("TONI -> Motivo de la consulta guardada: \(motivoConsultaGuardada)")
            self.motivoDataText.text = motivoConsultaGuardada
        }
        
        //Mostrar plan terapeutico:
        let docPlanGuardado = database.document(withID: "plan."+taskList.documentID)
        
        if( docPlanGuardado != nil){
            let docPlanProperties = docPlanGuardado!.properties
            let textoPlanGuardado = docPlanProperties?["Plan_terapeutico"] as? String
            print("TONI -> PlanViewController plan: \(textoPlanGuardado)")
            self.planDataText.text = textoPlanGuardado
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
