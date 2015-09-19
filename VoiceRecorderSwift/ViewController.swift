//
//  ViewController.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit

let kAudioListCellReuseIdentifier = "AudioListCell"

class ViewController: UIViewController {
    
    @IBOutlet weak var listtable : UITableView!
    var audioList : AudioList!
    
    var deletedIndexPath : NSIndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listtable.rowHeight = 50.0
        
        // create our data model
        self.audioList = AudioList.sharedInstance
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.listtable.reloadData()
        
        
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlayAudioSegue" {
            let playVC = segue.destinationViewController as! AudioPlayerViewController
            let cell = sender as! UITableViewCell
            let indexPath = self.listtable.indexPathForCell(cell)
            
            playVC.currentIndex = indexPath!.row
        }
        
    }

}



extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.listtable.dequeueReusableCellWithIdentifier(kAudioListCellReuseIdentifier, forIndexPath: indexPath) as! RecordTableCell
        
        cell.audioItem = self.audioList.items[indexPath.row]

        
        return cell
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deletedIndexPath = indexPath
            self.audioList.deleteItemAtIndex(indexPath.row)
            self.listtable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        
    }
    
  }






























