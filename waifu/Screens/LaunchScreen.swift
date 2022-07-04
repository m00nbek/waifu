//
//  LaunchScreen.swift
//  girlfriend
//
//  Created by Oybek Melikulov on 6/12/22.
//

import AVFoundation
import AVKit
import UIKit

class LaunchScreen: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		playVideo()
	}
	
	let playerController = AVPlayerViewController()
	private func playVideo() {
		guard let path = Bundle.main.path(forResource: "ohayo", ofType:"mp4") else {
			debugPrint("ohayo.mp4 not found")
			return
		}
		let player = AVPlayer(url: URL(fileURLWithPath: path))
		playerController.showsPlaybackControls = false
		playerController.player = player
		playerController.videoGravity = .resizeAspectFill
		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
		present(playerController, animated: true) {
			player.play()
		}
	}
	@objc func playerDidFinishPlaying(note: NSNotification) {
		UIView.animate(withDuration: 0.3) {
			self.playerController.view.alpha = 0
		} completion: { done in
			self.playerController.dismiss(animated: true) {
				self.view.window?.rootViewController = UINavigationController(rootViewController: MainViewController())
				self.view.window?.makeKeyAndVisible()
			}
		}
	}
}
