//
//  RecordTableCell.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit

class RecordTableCell: UITableViewCell {
    
    @IBOutlet weak var audioTitleLabel : UILabel!
    @IBOutlet weak var audioLength : UILabel!
    
    var audioItem : AudioItem! {
        didSet {
            self.audioTitleLabel.text = audioItem.title
            self.audioLength.text = audioItem.length
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.audioTitleLabel.text = nil
        self.audioLength.text = nil
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
