//
//  MainViewController.swift
//  GPS Uniguard
//
//  Created by Uniguard ID on 22/11/24.
//

import UIKit
import WebKit

class MainViewController: UIViewController, WKUIDelegate {
    
    static let eventLogin = Notification.Name("eventLogin")
    static let eventToken = Notification.Name("eventToken")
    static let eventEvent = Notification.Name("eventEvent")
    static let keyToken = "keyToken"
    static let keyEventId = "keyEventId"
    
    var webView: WKWebView!
    var initialized = false
    var pendingEventId: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard

        let statusFrame = UIApplication.shared.statusBarFrame
        var viewFrame = view.frame
        viewFrame.origin.y = statusFrame.size.height
        viewFrame.size.height -= statusFrame.size.height

        let userContentController = WKUserContentController()
        userContentController.add(self, name: "appInterface")

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController

        var processPool: WKProcessPool
        if let encodedPool = userDefaults.value(forKey: "pool") as? Data,
           let decodedPool = try? NSKeyedUnarchiver.unarchivedObject(ofClass: WKProcessPool.self, from: encodedPool) {
            processPool = decodedPool
        } else {
            processPool = WKProcessPool()
            let encodedPool = try? NSKeyedArchiver.archivedData(withRootObject: processPool, requiringSecureCoding: true)
            userDefaults.set(encodedPool, forKey: "pool")
        }
        webConfiguration.processPool = processPool

        let group = DispatchGroup()
        if let encodedCookies = userDefaults.value(forKey: "cookies") as? Data,
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: encodedCookies) as? [HTTPCookie] {
            if #available(iOS 11.0, *) {
                cookies.forEach { cookie in
                    group.enter()
                    webConfiguration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                        group.leave()
                    }
                }
            }
        }
        
        self.webView = WKWebView(frame: viewFrame, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(self.webView)
        
        group.notify(queue: DispatchQueue.main) {
            self.initialized = true
            self.loadPage()
        }
        
        
        
    
    }
    
    private func loadPage() {
        if let urlString = UserDefaults.standard.object(forKey: "url") as? String {
            var urlComponents = URLComponents(string: urlString)
            if let eventId = pendingEventId {
                urlComponents?.queryItems = [URLQueryItem(name: "eventId", value: eventId)]
                pendingEventId = nil
            }
            if let url = urlComponents?.url {
                self.webView.load(URLRequest(url: url))
            }
        }
    }


    

}

extension MainViewController : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? String {
            if body.starts(with: "login") {
                if body.count > 6 {
                    let token = String(body[body.index(body.startIndex, offsetBy: 6)...])
                    SecurityManager.shared.saveToken(token)
                }
                NotificationCenter.default.post(name: MainViewController.eventLogin, object: nil)
            } else if body.starts(with: "authentication") {
                if let token = SecurityManager.shared.readToken() {
                    let code = "handleLoginToken && handleLoginToken('\(token)')"
                    webView.evaluateJavaScript(code, completionHandler: nil)
                }
            } else if body.starts(with: "logout") {
                SecurityManager.shared.deleteToken()
            } else if body.starts(with: "server") {
                let urlString = String(body[body.index(body.startIndex, offsetBy: 7)...])
                UserDefaults.standard.set(urlString, forKey: "url")
                if let url = URL(string: urlString) {
                    self.webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
}
