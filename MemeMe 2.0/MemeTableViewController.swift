//
//  MemeTableViewController.swift
//  MemeMe 1.0
//
//  Created by Ondrej Winter on 29/09/2020.
//  Copyright © 2020 Levit8. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
        
     var memes: [Meme]! {
         let object = UIApplication.shared.delegate
         let appDelegate = object as! AppDelegate
         return appDelegate.memes
     }
    
    override func viewDidLoad() {
        print(view.frame)
        self.tableView.rowHeight = 120;
        }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! MemeTableViewCell
        let dataforRow = memes[(indexPath as NSIndexPath).row]
        cell.labelOne?.text = dataforRow.topText
        cell.labelTwo?.text = dataforRow.bottomText
        cell.imageViewTableCell?.image = dataforRow.originalImage
        cell.labelOne?.frame.size.width = 60


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVc = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailVc.memes = memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailVc, animated: true)
    }
    
    
}

/*

extension UITableView {
    /// Reloads a table view without losing track of what was selected.
    func reloadDataSavingSelections() {
        let selectedRows = indexPathsForSelectedRows

        reloadData()

        if let selectedRow = selectedRows {
            for indexPath in selectedRow {
                selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}

 */
