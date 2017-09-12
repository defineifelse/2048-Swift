//
//  SettingViewController.swift
//  2048-Swift
//
//  Created by Pan on 20/08/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    let settingTypes = Global.settingTypes
    var settingNames: [[String]] {
        return [Global.gameTypes, Global.boardSizes, Global.difficultys]
    }
    
    var selecteds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selecteds = [Global.gameTypeName(), Global.boardSizeName(), Global.difficultyName()]
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.detailTextLabel?.text = self.selecteds[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let i = indexPath.row
        let names = settingNames[i]
        let alert = UIAlertController(title: settingTypes[i], message: nil, preferredStyle: .alert)
        let handler: (UIAlertAction) -> () =  { (action) -> Void in
            UserDefaults.standard.set(action.title, forKey: self.settingTypes[i])
            self.selecteds[i] = action.title!
            self.tableView.reloadData()
        }
        for title in names {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: handler))
        }
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

