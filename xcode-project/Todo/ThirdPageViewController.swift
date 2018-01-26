//
//  ThirdPageViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 1/10/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class ThirdPageViewController: UIViewController {

    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    @IBOutlet weak var nombreLabel: UILabel!
    
    @IBOutlet weak var planTextView: UITextView!
    
    @IBOutlet weak var edadLabel: UILabel!
    
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
        let docPlanGuardado = database.document(withID: "plan."+taskList.documentID)

        planTextView.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        planTextView.clipsToBounds = true;
        planTextView.layer.cornerRadius = 10.0;
        planTextView.isEditable = false;
        
        
        let docPlanProperties = docPlanGuardado!.properties

        
        if( docPlanProperties?["Plan_terapeutico"] != nil){
            
            let planGuardado = docPlanProperties?["Plan_terapeutico"] as? String
            planTextView.textColor = UIColor.black
            planTextView.backgroundColor = UIColor.white
            self.planTextView.text = planGuardado
        }
        else{
            self.planTextView.text = "Plan terapéutico para el paciente sin especificar."
            planTextView.textColor = UIColor.lightGray
            planTextView.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
        }

        //Mostrar Edad:
        let docHabitosToxicosGuardados = database.document(withID: "exploracion.HabitosToxicos."+taskList.documentID)
        
        edadLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
        
        let docHabitosProperties = docHabitosToxicosGuardados!.properties
        
        if( docHabitosProperties?["Edad"] != nil){
            
            let edadGuardada = docHabitosProperties?["Edad"] as? String
            
            self.edadLabel.text = edadGuardada!
            self.edadLabel.textColor = UIColor.black
            self.edadLabel.backgroundColor = UIColor.white
            self.edadLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 15)
            
        }
        else{
            self.edadLabel.text = "-"
            self.edadLabel.textColor = UIColor.lightGray
            self.edadLabel.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.69, alpha:1.0)
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
