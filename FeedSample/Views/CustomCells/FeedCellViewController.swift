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
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.hex(string: "000000", alpha: 1)

        //titleLabel
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.hex(string: "E6E6E6", alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "コメント"
        //titleLabel.frame.size.height = 44

        //tableView
        tableView.rowHeight = 44
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hex(string: "000000", alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommentsCell.self, forCellReuseIdentifier: "CommentsCell")

        //avplayer
        playerOverLayView.translatesAutoresizingMaskIntoConstraints = false
        playerContainerView.addSubview(playerViewController.view)
        playerViewController.contentOverlayView?.addSubview(playerOverLayView)

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
