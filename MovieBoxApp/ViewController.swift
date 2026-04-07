import UIKit
import WebKit
import AVKit
import UniformTypeIdentifiers

class ViewController: UIViewController, WKNavigationDelegate, UIDocumentPickerDelegate {
    
    var webView: WKWebView!
    let nativePlayer = AVPlayerViewController()
    var currentSubtitleURL: URL?
    
    let uploadSubButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("رفع ترجمة 📝", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupUploadButton()
        loadWebsite()
    }
    
    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let jsStyle = """
        document.documentElement.style.webkitUserSelect='none';
        document.documentElement.style.webkitTouchCallout='none';
        """
        let script = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.backgroundColor = .black
        view.addSubview(webView)
    }
    
    func setupUploadButton() {
        uploadSubButton.addTarget(self, action: #selector(didTapUploadSubtitle), for: .touchUpInside)
        
        view.addSubview(uploadSubButton)
        NSLayoutConstraint.activate([
            uploadSubButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            uploadSubButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            uploadSubButton.widthAnchor.constraint(equalToConstant: 130),
            uploadSubButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func loadWebsite() {
        let url = URL(string: "https://moviebox.ph/")!
        webView.load(URLRequest(url: url))
    }
    
    @objc func didTapUploadSubtitle() {
        let types: [UTType] = [UTType(filenameExtension: "vtt")!, UTType(filenameExtension: "srt")!]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        var finalSubtitleURL: URL?
        
        if selectedFileURL.pathExtension.lowercased() == "srt" {
            do {
                let srtContent = try String(contentsOf: selectedFileURL, encoding: .utf8)
                let vttContent = convertSRTtoVTT(srtContent: srtContent)
                let tempDir = FileManager.default.temporaryDirectory
                let vttURL = tempDir.appendingPathComponent(selectedFileURL.deletingPathExtension().lastPathComponent + ".vtt")
                try vttContent.write(to: vttURL, atomically: true, encoding: .utf8)
                finalSubtitleURL = vttURL
            } catch { return }
        } else {
            finalSubtitleURL = selectedFileURL
        }
        
        currentSubtitleURL = finalSubtitleURL
        
        uploadSubButton.setTitle("تم الرفع ✅", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.uploadSubButton.setTitle("رفع ترجمة 📝", for: .normal) }
    }
    
    private func convertSRTtoVTT(srtContent: String) -> String {
        var vttContent = "WEBVTT\n\n"
        let convertedContent = srtContent.replacingOccurrences(of: ",", with: ".")
        vttContent += convertedContent
        return vttContent
    }
    
    func playVideoNative(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        nativePlayer.player = player
        nativePlayer.showsPlaybackControls = true
        uploadSubButton.isHidden = false
        present(nativePlayer, animated: true) { player.play() }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.contains(".m3u8") {
            // playVideoNative(urlString: url.absoluteString)
            // decisionHandler(.cancel)
            // return
        }
        decisionHandler(.allow)
    }
}
