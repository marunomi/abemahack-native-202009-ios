import AVKit
import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class FeedCellViewController: UIViewController, UIGestureRecognizerDelegate {

    private(set) var channel: Channel?
    private(set) var page: Int?

    private let disposeBag = DisposeBag()
    private var viewModel = FeedCellViewModel()

    @IBOutlet private weak var playerContainerView: UIView!

    private let playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.isUserInteractionEnabled = true
        playerVC.view.backgroundColor = .darkGray
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        return playerVC
    }()

    private let playerOverLayView = UIView()

    ///コメント表示用のテーブルビュー
    private let tableView = UITableView()
    private let titleLabel = UILabel()

    //タップで変更したいデバイスの向きの値
    private var deviceOriantation = UIInterfaceOrientation.landscapeRight.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.hex(string: "000000", alpha: 1)

        //titleLabel
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.hex(string: "E6E6E6", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "コメント"

        //tableView
        tableView.rowHeight = 44
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hex(string: "000000", alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommentsCell.self, forCellReuseIdentifier: "CommentsCell")
        tableView.allowsSelection = false

        //avplayer
        playerOverLayView.translatesAutoresizingMaskIntoConstraints = false
        playerContainerView.addSubview(playerViewController.view)
        playerViewController.contentOverlayView?.addSubview(playerOverLayView)
        playerOverLayView.isUserInteractionEnabled = true

        self.view.addSubview(titleLabel)
        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.playerContainerView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: -6),
            tableView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])

        if let overLayview = playerViewController.contentOverlayView {
            NSLayoutConstraint.activate([
                playerOverLayView.topAnchor.constraint(equalTo: overLayview.topAnchor),
                playerOverLayView.leadingAnchor.constraint(equalTo: overLayview.leadingAnchor),
                playerOverLayView.trailingAnchor.constraint(equalTo: overLayview.trailingAnchor),
                playerOverLayView.bottomAnchor.constraint(equalTo: overLayview.bottomAnchor),
            ])
        }

        /*
         self.playerOverLayView.rx
         .tapGesture { gesture, delegate in

         gesture.numberOfTouchesRequired = 2
         }
         .when(.ended)
         .subscribe(onNext: { _ in
         print("ダブルタップされた")
         }).disposed(by: disposeBag)
         */

        //tableView
        viewModel.comments.bind(to: tableView.rx.items(cellIdentifier: "CommentsCell", cellType: CommentsCell.self)) { _, element, cell in
            cell.commentLabel.text = element.message
            cell.userIdLabel.text = element.userId
        }.disposed(by: disposeBag)

        //デバイスの向き検出
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { _ in
                let orientation = UIDevice.current.orientation
                switch orientation {
                case .portrait, .portraitUpsideDown:
                    self.titleLabel.isHidden = false
                    self.deviceOriantation = UIInterfaceOrientation.landscapeRight.rawValue
                case .landscapeRight, .landscapeLeft:
                    self.titleLabel.isHidden = true
                    self.deviceOriantation = UIInterfaceOrientation.portrait.rawValue
                case .unknown:
                    break
                case .faceUp:
                    break
                case .faceDown:
                    break
                @unknown default:
                    break
                }
            }).disposed(by: disposeBag)

        //timer
        //だいぶ無理やり
        var commentIndex = 0
        //ランダムな間隔でコメント送りたい
        var timeInterval: TimeInterval = 2.0
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { _ in
            if commentIndex >= 50 {
                commentIndex = 0
            }
            commentIndex += 1
            self.viewModel.viewDidLoad(commentIndex)
        })

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(FeedCellViewController.toFullScreen(_:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        playerOverLayView.addGestureRecognizer(doubleTap)

    }

    @objc private func toFullScreen(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            UIDevice.current.setValue(self.deviceOriantation, forKey: #keyPath(UIDevice.orientation))
        }
    }

    func play(with player: AVPlayer) {
        guard let channel = channel else {
            assertionFailure("should not reach here")
            return
        }

        guard let url = URL(string: channel.url) else {
            assertionFailure("invalid URL")
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        playerViewController.player = player
        player.play()
    }

    func stop() {
        playerViewController.player = nil
    }
}

extension FeedCellViewController {
    static func make(channel: Channel, page: Int) -> Self {
        let viewController = self.init(nibName: String(describing: self), bundle: nil)
        viewController.channel = channel
        viewController.page = page
        return viewController
    }
}
