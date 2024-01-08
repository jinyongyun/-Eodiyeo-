//
//  AlertListCell.swift
//  Eodiyeo
//
//  Created by jinyong yun on 1/3/24.
//

import UIKit
import UserNotifications

class AlertListCell: UITableViewCell {
    
    let userNotificationCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var shorttermLabel: UILabel!
    
    @IBOutlet weak var alertSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        alertSwitch.onTintColor = .cyan
        alertSwitch.tintColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func alertSwitchValueChanged(_ sender: UISwitch) {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        
        alerts[sender.tag].isOn = sender.isOn
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
        
        if sender.isOn {
            userNotificationCenter.addNotificationRequest(by: alerts[sender.tag])
        } else {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
        }
    }
}
