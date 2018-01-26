//
//  ResumenViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 12/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class ResumenViewController: UITableViewController {

    @IBOutlet weak var pacienteText: UILabel!
    
    var username: String!
    var database: CBLDatabase!
    var taskList: CBLDocument!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        self.motivoConsultaLabel.adjustsFontSizeToFitWidth = true*/
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        username = Session.username
        
        let doc = database.document(withID: taskList.documentID)
        print("TONI -> ResumenViewController doc->\(doc!)")
        
        let docProperties = doc!.properties
        print("TONI -> ResumenViewController docProperties->\(docProperties!)")
        
        let nombrePaciente = docProperties?["name"] as? String
        pacienteText.text = nombrePaciente
        
        print("TONI -> ResumenViewController ->\(taskList.documentID)")
        print("TONI -> ResumenViewController Key->\(nombrePaciente)")
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "motivoSegue":
                    if let motivoViewController = segue.destination as? MotivoViewController {
                        motivoViewController.taskList = taskList
                    }
                
                
                case "exploracionSegue":
                    if let exploracionViewController = segue.destination as? ExploracionViewController {
                        exploracionViewController.taskList = taskList
                        print("TONI -> ResumenViewController: Exploración Segue \(taskList)")
                    }
                
                case "planSegue":
                    if let planViewController = segue.destination as? PlanViewController {
                        planViewController.taskList = taskList
                        print("TONI -> ResumenViewController: Plan Segue \(taskList)")
                }
                
                case "informeSegue":
                    if let informeViewController = segue.destination as? InformeCompletoViewController {
                        informeViewController.taskList = taskList
                        print("TONI -> ResumenViewController: Informe Segue \(taskList)")
                    }
                
                default:
                    break
            }
        
        }
    }

    

}
