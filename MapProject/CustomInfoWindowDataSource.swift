//
//  CustomInfoWindowDataSource.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/14.
//

import UIKit
import NMapsMap

class CustomInfoWindowDataSource: NSObject, NMFOverlayImageDataSource {
    var rootView: CustomInfoWindowView!
    
    func view(with overlay: NMFOverlay) -> UIView {
        guard let infoWindow = overlay as? NMFInfoWindow else { return rootView }
        if rootView == nil {
//            rootView = Bundle.main.loadNibNamed("CustomInfoWindowView", owner: nil, options: nil)?.first as? CustomInfoWindowView
            rootView = CustomInfoWindowView()
        }
        
        if infoWindow.marker != nil {
            rootView.iconView.image = UIImage(named: "baseline_room_black_24pt")
            rootView.textLabel.text = infoWindow.marker?.userInfo["title"] as? String
        } else {
            rootView.iconView.image = UIImage(named: "baseline_gps_fixed_black_24pt")
            rootView.textLabel.text = "\(infoWindow.position.lat), \(infoWindow.position.lng)"
        }
        rootView.textLabel.sizeToFit()
        rootView.textLabel.text = "AAAASDASDASDASDASDASDASDASDASDASDASDASDASD"
        let width = rootView.textLabel.frame.size.width + 80
        
        rootView.frame = CGRect(x: 0, y: 0, width: 120, height: 88)
        rootView.layoutIfNeeded()
        rootView.isUserInteractionEnabled = true
        return rootView
    }
}
