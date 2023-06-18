import Cocoa

class TransparentWindow: NSWindow {
    // ウィンドウのカスタム実装
    override var canBecomeKey: Bool {

        // ウィンドウをキーボードフォーカスを持てるようにする
        return true
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // ウィンドウをフルスクリーンに設定
        self.setFrame(NSScreen.main!.frame, display: true)

        // ウィンドウを透明に設定
        self.backgroundColor = NSColor.clear

        // ウィンドウをクリックイベントの対象外に設定
        self.ignoresMouseEvents = true
    }
}

class ScrollingTextField: NSTextField {
    private var animationTimer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 枠線のスタイルを設定
        self.isBordered = false
        self.backgroundColor = NSColor.clear

        // テキストフィールドの位置を右上端に設定
        if let superview = self.superview {
            let superviewWidth = superview.frame.size.width
            print(superviewWidth)
            let superviewHeight = superview.frame.size.height
            print(superviewHeight)
            let textFieldWidth = self.frame.size.width
            print(textFieldWidth)
            let textFieldHeight = self.frame.size.height
            self.frame.origin.x = NSMaxX(superview.bounds) - textFieldWidth
            self.frame.origin.y = NSMaxY(superview.bounds) - textFieldHeight
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        // テキストを自動スクロールするためのタイマーを開始
        startScrollingAnimation()
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)

        // タイマーを停止して解放
        stopScrollingAnimation()
    }

    private func startScrollingAnimation() {
        guard animationTimer == nil else { return }

        // 0.05秒ごとにテキストをスクロール
        animationTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(scrollText), userInfo: nil, repeats: true)
    }

    private func stopScrollingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    @objc private func scrollText() {
        // テキストフィールドの位置を更新
        var frame = self.frame
        frame.origin.x -= 10
        self.frame = frame

    }
}



class AppDelegate: NSObject, NSApplicationDelegate {
    var window: TransparentWindow!
    var statusItem: NSStatusItem!
    var textField: NSTextField!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // ウィンドウを作成
        window = TransparentWindow(contentRect: NSScreen.main!.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces

        // ウィンドウをフルスクリーンに設定
        window.setFrame(NSScreen.main!.frame, display: true)

        // ウィンドウの背景を透明に設定
        window.backgroundColor = NSColor.clear

        // ウィンドウを表示
        window.makeKeyAndOrderFront(nil)

        // メニューバーにアイコンを表示
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "CommentScreen"

        // Quitメニュー項目を作成し、アクションを設定
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
        let appMenu = NSMenu(title: "Menu")
        appMenu.addItem(quitMenuItem)
        statusItem.menu = appMenu

        // 複数のコメントを出力
        let comments = ["Comment 1", "Comment 2", "Comment 3"]
        outputComments(comments)

        // 3秒後にコメントを追加
        let delay_comments = ["Comment 1", "Comment 2", "Comment 3"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            outputComments(delay_comments)
        }

        func outputComments(_ comments: [String]) {
            guard let contentView = window.contentView else {
                return
            }
            let textFieldHeight: CGFloat = 60
            var yOffset: CGFloat = contentView.bounds.maxY - textFieldHeight

            for comment in comments {

                // ScrollingTextFieldを作成
                let scrollingTextField = ScrollingTextField(frame: NSRect(x: 0, y: 0, width: 400, height: 60))
                scrollingTextField.stringValue = comment
                scrollingTextField.isEditable = false
                scrollingTextField.backgroundColor = NSColor.clear

                // テキストフィールドのフォントとテキストカラーを設定
                let font = NSFont.systemFont(ofSize: 36)
                let textColor = NSColor.white
                scrollingTextField.font = font
                scrollingTextField.textColor = textColor

                // テキストフィールドの位置を右上端に設定
                if let contentView = window.contentView {
                    let textFieldWidth = scrollingTextField.frame.size.width
                    let textFieldHeight = scrollingTextField.frame.size.height
                    let x = contentView.bounds.maxX - textFieldWidth
                    scrollingTextField.frame = NSRect(x: x, y: yOffset, width: textFieldWidth, height: textFieldHeight)
                    yOffset -= textFieldHeight
                }

                // ウィンドウにテキストフィールドを追加
                window.contentView?.addSubview(scrollingTextField)
            }
        }



    }

    @objc func quitClicked() {
        // Quitメニューが選択された時の処理
        NSApp.terminate(nil)
    }
}

// アプリケーションを起動
let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
