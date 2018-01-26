//
//  IconosViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 20/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class IconosViewController: UIViewController {

    var database: CBLDatabase!
    var taskList: CBLDocument!

    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var motivoLabel: UILabel!
    
    @IBOutlet weak var exploreImage: UIImageView!
    @IBOutlet weak var exploreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database and username:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        let doc = database.document(withID: taskList.documentID)
        print("TONI -> IconosViewController doc->\(doc!)")
        
        let docProperties = doc!.properties
        print("TONI -> IconosViewController docProperties->\(docProperties!)")
        
        let nombrePaciente = docProperties?["name"] as? String

        
        // Do any additional setup after loading the view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        //navigationItem.title = "Resumen Clínico"
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
                if let exploracionTabBarViewController = segue.destination as? tabBarCustomViewController {
                    
                    exploracionTabBarViewController.taskList = taskList
                    print("TONI -> ConstantesVitalesViewController: Exploración Segue \(taskList)")
                }

            case "planSegue":
                if let planViewController = segue.destination as? PlanViewController {
                    planViewController.taskList = taskList
                    print("TONI -> PlanViewController: Plan Segue \(taskList)")
                }
                
            case "informeSegue":
                if let informeViewController = segue.destination as? InformePageViewController {
                    informeViewController.taskList = taskList
                    print("TONI -> ResumenViewController: Informe Segue \(taskList)")
                }
                
            default:
                break
            }
            
        }
    }


}
