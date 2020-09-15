import AVKit
import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class FeedCellViewController: UIViewController {

    private(set) var channel: Channel?
    private(set) var page: Int?

    private let disposeBag = DisposeBag()
    private var viewModel = FeedCellViewModel()

    @IBOutlet private weak var playerContainerView: UIView!

    private let playerViewController: AVPlayerViewController = {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.isUserInteractionEnabled = false
        playerVC.view.backgroundColor = .darkGray
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        return playerVC
    }()

    private let playerOverLayView = UIView()

    ///コメント表示用のテーブルビュー
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.hex(string: "000000", alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommentsCell.self, forCellReuseIdentifier: "CommentsCell")
        self.view.addSubview(tableView)

        playerOverLayView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        playerContainerView.addSubview(playerViewController.view)
        playerViewController.contentOverlayView?.addSubview(playerOverLayView)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
        ])

        if let overLayview = playerViewController.contentOverlayView {
            NSLayoutConstraint.activate([
                playerOverLayView.topAnchor.constraint(equalTo: overLayview.topAnchor),
                playerOverLayView.leadingAnchor.constraint(equalTo: overLayview.leadingAnchor),
                playerOverLayView.trailingAnchor.constraint(equalTo: overLayview.trailingAnchor),
                playerOverLayView.bottomAnchor.constraint(equalTo: overLayview.bottomAnchor),
            ])
        }

        tableView.topAnchor.constraint(equalTo: self.playerContainerView.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        //        // Tap Gesture
        //        self.playerViewController.contentOverlayView?.rx
        //            .tapGesture { gesture, _ in
        //                gesture.numberOfTouchesRequired = 2
        //        }
        //        .when(.began)
        //        .subscribe(onNext: { _ in
        //            print("Double Tap Recognized!!:-----------------")
        //        }).disposed(by: disposeBag)

        //        self.playerViewController

        self.playerOverLayView.rx
            .tapGesture { gesture, _ in
                gesture.numberOfTouchesRequired = 2
        }
        .when(.recognized)
        .subscribe(onNext: { _ in
            print("Double Tap Recognized!!:-----------------")
        }).disposed(by: disposeBag)

        //tableView
        viewModel.comments.bind(to: tableView.rx.items(cellIdentifier: "CommentsCell", cellType: CommentsCell.self)) { _, element, cell in
            cell.commentLabel.text = element.message
            cell.userIdLabel.text = element.userId
        }.disposed(by: disposeBag)

        //viewModel.viewDidLoad()

        //timer
        //だいぶ無理やり
        var cnt = 0
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { _ in
            if cnt >= 50 {
                cnt = 0
            }
            cnt += 1
            self.viewModel.viewDidLoad(cnt)
        })

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
