//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    weak var owner: SelectionViewController!
    var image: String!
    var animTimer: Timer!
    
    var imageView: UIImageView!
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = UIColor.black
        
        // create an image view that fills the screen
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        
        view.addSubview(imageView)
        
        // make the image view fill the screen
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // schedule an animation that does something vaguely interesting
        animTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            // do something exciting with our image
            self.imageView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 1) {
                self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            UIView.animate(withDuration: 1, delay: 1, options: .curveLinear, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = image.replacingOccurrences(of: "-Large.jpg", with: "")
        let path = Bundle.main.path(forResource: image, ofType: nil)!
        let original = UIImage(contentsOfFile: path)!
        
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: renderRect.size))
            ctx.cgContext.closePath()
            
            //            original.draw(at: CGPoint.zero)
            original.draw(in: renderRect)
        }
        
        imageView.image = rounded
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView.alpha = 0
        
        UIView.animate(withDuration: 1) { [unowned self] in
            self.imageView.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animTimer!.invalidate()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let defaults = UserDefaults.standard
        var currentVal = defaults.integer(forKey: image)
        currentVal += 1
        
        defaults.set(currentVal, forKey:image)
        
        // tell the parent view controller that it should refresh its table counters when we go back
        owner.dirty = true
    }
}
