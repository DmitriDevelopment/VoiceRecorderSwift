//
//  ViewController.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit

let kAudioListCellReuseIdentifier = "AudioListCell"

class ViewController: UIViewController, AudioListDelegate {
    
    @IBOutlet weak var listtable : UITableView!
    var audioList : AudioList!
    
    var deletedIndexPath : NSIndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listtable.rowHeight = 50.0
        
        // create our data model
        self.audioList = AudioList.sharedInstance
        self.audioList.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.listtable.reloadData()
        
    }
    
    // MARK: - AudioListDelegate

    func deleteFile(name: String, success: Bool) {
        if success {
            let alert = UIAlertController(title: "Deleted!", message: "Audio deleted successfully" , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if let indexPath = self.deletedIndexPath {
            self.deletedIndexPath = nil
            if !(self.listtable.indexPathsForVisibleRows() as! [NSIndexPath]).filter({ $0.row == indexPath.row }).isEmpty {
                self.listtable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
    }


}



extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.listtable.dequeueReusableCellWithIdentifier(kAudioListCellReuseIdentifier, forIndexPath: indexPath) as! RecordTableCell
        
        if let audioItem = self.audioList.items[indexPath.row] as? AudioItem {
            cell.audioItem = audioItem
        }
        
        return cell
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deletedIndexPath = indexPath
            self.audioList.deleteItemAtIndex(indexPath.row)

        }
        
        
    }
}






























