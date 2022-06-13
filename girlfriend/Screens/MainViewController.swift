//
//  MainViewController.swift
//  girlfriend
//
//  Created by Oybek Melikulov on 6/12/22.
//

import UIKit
import AVFoundation
import AVKit

class MainViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .lightGray
	}
	
	override func viewDidAppear(_ animated: Bool) {
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: - Properties
	
	// MARK: - Funcs
	
	// MARK: - Fucking alert shit
	private lazy var alert: UIAlertController = {
		var alert = UIAlertController(title: "What you want, darling?", message: "", preferredStyle: .alert)
		var alertTextField = UITextField()
		alert.addTextField { textField in
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.placeholder = "u know the words!"
			alertTextField = textField
			alertTextField.delegate = self
		}
		let action = UIAlertAction(title: "c'mon", style: .default) { [weak self] _ in
			guard let text = alertTextField.text else {return}
			if !text.replacingOccurrences(of: " ", with: "").isEmpty {
				self?.playVideo(text)
				alertTextField.text = nil
			}
		}
		action.isEnabled = false
		alert.addAction(action)
		alert.addAction(UIAlertAction(title: "nvm", style: .cancel, handler: nil))
		return alert
	}()
	// MARK: - Fucking vid player
	let playerController = AVPlayerViewController()
	
	private func playVideo(_ vidName: String) {
		guard let path = Bundle.main.path(forResource: vidName, ofType:"mp4") else {
			debugPrint("\(vidName).mp4 not found")
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
				print("Vid playing finished")
			}
		}
	}
}

// MARK: - Fucking UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
	func textFieldDidChangeSelection(_ textField: UITextField) {
		guard let text = textField.text else {return}
		if !text.replacingOccurrences(of: " ", with: "").isEmpty {
			alert.actions[0].isEnabled = true
		} else {
			alert.actions[0].isEnabled = false
		}
	}
}
