//
//  MainViewController.swift
//  girlfriend
//
//  Created by Oybek Melikulov on 6/12/22.
//

import UIKit
import AVFoundation
import AVKit
import AudioToolbox

class MainViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	// MARK: - Properties
	let videos = ["ohayo", "longDance", "dance", "hearteater"]
	let BGs = ["smile", "cute", "curious", "evil"]
	let actualBGs = ["mobile_looking", "mobile_lookingStraight", "mobile_lookingBack", "mobile_stretching", "mobile_wallpaper", "mobile", "sketch_redHorns"]
	let audios = ["dahlingOhayo"]
	let modes = ["safe - Which's gonna change icon, bg", "darling -- back to normal"]
	// kiss of death
	// maybe music
	
	let bg: UIImageView = {
		let iv = UIImageView(image: UIImage(named: "mobile_lookingStraight"))
		iv.contentMode = .scaleAspectFill
		iv.isUserInteractionEnabled = true
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	// Fucking device orientation
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscapeRight }
	
	// MARK: - Funcs
	
	// if u can find the word from the videos array then just fucking play it
	// if u can't then that means it is a fucking command
	
	private func doWhatTheBoyfriendSaid(_ desire: String) {
		if videos.contains(desire) {
			playVideo(desire)
		} else if BGs.contains(desire) {
			changeBG(desire)
			present(alert, animated: true, completion: nil)
		} else if audios.contains(desire) {
			playAudio(desire)
			present(alert, animated: true, completion: nil)
		} else if desire == "randomBG" {
			changeBG(actualBGs.randomElement()!)
			present(alert, animated: true, completion: nil)
		} else if desire == "kissMe" {
			kissMe()
		} else {
			changeBG("wtf")
			present(alert, animated: true, completion: nil)
		}
	}
	
	private func changeBG(_ bgName: String) {
		bg.image = UIImage(named: bgName)
		view.layoutSubviews()
	}
	private func kissMe() {
		// damn how is she supposed to do this? fuck
		// i'll figure it out
		AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
	}
	// MARK: - Fucking UI constraints
	private func setupUI() {
		// BG
		view.addSubview(bg)
		NSLayoutConstraint.activate([
			bg.topAnchor.constraint(equalTo: view.topAnchor),
			bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bg.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		// tap guesture
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.showTheAlert))
		bg.addGestureRecognizer(tap)
	}
	
	// MARK: - Fucking alert shit
	@objc func showTheAlert() {
		present(alert, animated: true, completion: nil)
	}
	private lazy var alert: UIAlertController = {
		var alert = UIAlertController(title: "What you want, dahling?", message: "", preferredStyle: .alert)
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
				self?.doWhatTheBoyfriendSaid(text)
				alertTextField.text = nil
			}
		}
		action.isEnabled = false
		alert.addAction(action)
		alert.addAction(UIAlertAction(title: "nvm", style: .cancel, handler: nil))
		return alert
	}()
	// MARK: - Fucking audio player
	private func playAudio(_ audioName: String) {
		var audioPlayer: AVAudioPlayer?
		
		func playSound() {
			guard let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
			
			do {
				try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
				try AVAudioSession.sharedInstance().setActive(true)
				
				/* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
				audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
				
				/* iOS 10 and earlier require the following line:
				 player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
				
				guard let player = audioPlayer else { return }
				
				player.play()
				
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
	// MARK: - Fucking vid player
	let vidPlayerController = AVPlayerViewController()
	
	private func playVideo(_ vidName: String) {
		guard let path = Bundle.main.path(forResource: vidName, ofType:"mp4") else {
			debugPrint("\(vidName).mp4 not found")
			return
		}
		let player = AVPlayer(url: URL(fileURLWithPath: path))
		vidPlayerController.showsPlaybackControls = false
		vidPlayerController.player = player
		vidPlayerController.videoGravity = .resizeAspectFill
		
		if vidName == "hearteater" {
			vidPlayerController.videoGravity = .resize
			
			UIView.setAnimationsEnabled(false)
			UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
			UIView.setAnimationsEnabled(true)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(vidPlayerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: vidPlayerController.player?.currentItem)
		
		self.addChild(vidPlayerController)
		self.view.addSubview(vidPlayerController.view)
		vidPlayerController.view.frame = self.view.frame
		
		player.play()
		
	}
	@objc func vidPlayerDidFinishPlaying(note: NSNotification) {
		UIView.animate(withDuration: 0.3) {
			self.vidPlayerController.view.alpha = 0
		} completion: { done in
			self.vidPlayerController.dismiss(animated: true) {
				print("Vid playing finished")
				
				UIView.setAnimationsEnabled(false)
				UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
				UIView.setAnimationsEnabled(true)
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
