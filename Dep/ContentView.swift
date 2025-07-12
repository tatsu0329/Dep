import AppTrackingTransparency
import FirebaseCore
import FirebaseAnalytics
import GoogleMobileAds
import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox
import Lottie
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("✅ Tracking authorized")
                case .denied:
                    print("❌ Tracking denied")
                case .notDetermined:
                    print("⏳ Tracking not determined")
                case .restricted:
                    print("⚠️ Tracking restricted")
                @unknown default:
                    break
                }
            }
        }
        // AdMob 初期化
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> BannerView {
        // Use the recommended initializer for banner size
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        // Recommended approach for rootViewController assignment
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        banner.load(Request())
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}

struct ContentView: View {
    // MARK: - 入力関連の状態
    @State private var assetName: String = ""
    @State private var assetPrice: String = ""
    @State private var usefulLife: String = ""
    
    // MARK: - 計算結果関連の状態
    @State private var result: String = ""
    
    // MARK: - アニメーション関連の状態
    @State private var animateBackground = false
    @State private var shimmerOffset: CGFloat = -100
    
    // MARK: - シェア関連の状態
    @State private var shareMessage: String = ""
    @State private var isSharePresented = false
    @State private var capturedImage: UIImage?
    @State private var shareItems: [Any] = []
    
    @State private var showPopup = false
    
    var body: some View {
        mainContent
            .overlay(
                Group {
                    if showPopup {
                        Button(action: { showPopup = false }) {
                            ZStack {
                                // 背景ぼかし＆暗色 (より強いブラー+不透明度)
                                Color.white
                                    .blur(radius: 20)
                                    .opacity(1.0)
                                    .ignoresSafeArea()
                                    .zIndex(0)
                                
                                // AutoCrew2 アニメーション
                                LottieView(animationName: "AutoCrew2")
                                    .ignoresSafeArea()
                                    .zIndex(0)
                                
                                // ポップアップ本体
                                VStack(spacing: 16) {
                                    VStack(spacing: 8) {
                                        if !assetName.isEmpty {
                                            Text(assetName)
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .bold()
                                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                        }
                                        VStack {
                                            Text("1日あたり")
                                            Text(result.replacingOccurrences(of: "1日あたり", with: ""))
                                        }
                                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 20)
                                    }
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(red: 0.95, green: 0.8, blue: 0.5), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                                            .frame(minHeight: 240)
                                    )
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { }
                                .zIndex(1)
                                
                                // キラキラアニメーション（最前面に）
                                VStack {
                                    LottieLabeledStaticView(animationName: "SparkleBurst")
                                        .frame(width: 300, height: 300)
                                }
                                .zIndex(2)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color.clear)
                        .transition(.scale)
                    }
                }
            )
            .navigationTitle("減価償却メーカー")
            .onAppear {
                animateBackground = true
                shimmerOffset = 100
            }
    }
    
    var mainContent: some View {
        ZStack {
            // 背景
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.95, green: 0.93, blue: 0.88), Color.white]),
                    startPoint: animateBackground ? .topLeading : .bottomTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .topLeading
                )
                .animation(.linear(duration: 14).repeatForever(autoreverses: true), value: animateBackground)
                .ignoresSafeArea()
            }
            ScrollView {
                VStack(spacing: 20) {
                    // 以下、元のVStack内容をまるごと移動（タイトル〜広告まで）
                    // MARK: - タイトル＆キャラクター
                    Text("ひわりん")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.72, green: 0.60, blue: 0.36)) // gold
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    
                    // MARK: - 入力フォーム
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("資産名（例：MacBook）", text: $assetName)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                            
                            TextField("価格（円）", text: Binding(
                                get: {
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .decimal
                                    if let number = Double(assetPrice.replacingOccurrences(of: ",", with: "")) {
                                        return formatter.string(from: NSNumber(value: number)) ?? assetPrice
                                    }
                                    return assetPrice
                                },
                                set: { newValue in
                                    assetPrice = newValue.replacingOccurrences(of: ",", with: "")
                                }
                            ))
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                            
                            TextField("耐用年数（年）", text: $usefulLife)
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: 300)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.5))
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - 計算ボタン
                    HStack {
                        Button(action: calculate) {
                            Text("ひわりんで日割り！")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.85, green: 0.70, blue: 0.40))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.horizontal, 24)
                    
                    // MARK: - 結果表示
                    if !result.isEmpty {
                        VStack(spacing: 12) {
                            Text("結果：")
                                .font(.headline)
                            VStack {
                                VStack {
                                    Text(result)
                                }
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.8, blue: 0.9), Color(red: 0.2, green: 0.6, blue: 0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    // MARK: - シェアボタン
                    HStack(spacing: 16) {
                        Button(action: {
                            FirebaseAnalytics.Analytics.logEvent("share_button_pressed", parameters: [
                                "shared_result": result
                            ])
                            captureScreen()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if let image = capturedImage {
                                    isSharePresented = true
                                    shareItems = [shareMessage, image]
                                }
                            }
                        }) {
                            Text("SNSでシェアする")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.85, green: 0.70, blue: 0.40))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        }
                        Button(action: {
                            FirebaseAnalytics.Analytics.logEvent("review_button_pressed", parameters: nil)
                            if let writeReviewURL = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                                UIApplication.shared.open(writeReviewURL)
                            }
                        }) {
                            Text("レビューを書く")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.6, green: 0.7, blue: 0.4))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .sheet(isPresented: $isSharePresented) {
                        ShareSheet(activityItems: shareItems)
                    }
                    
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 0.99, green: 0.98, blue: 0.95))
                        .shadow(color: .gray.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .padding(.vertical, 16)
                
                // MARK: - バナー広告
                BannerAdView(adUnitID: "ca-app-pub-6569958937383358/9462287935")
                    .frame(width: 320, height: 50)
                    .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - 計算ロジック
    func calculate() {
        guard let price = Double(assetPrice),
              let years = Double(usefulLife),
              years > 0 else {
            result = "入力を確認してください。"
            return
        }
        let totalDays = years * 365
        let dailyCost = price / totalDays
        result = "1日あたり"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedCost = numberFormatter.string(from: NSNumber(value: Int(dailyCost))) ?? "\(Int(dailyCost))"
        result += "約\(formattedCost)円！"
        
        Analytics.logEvent("calculate_button_pressed", parameters: [
            "asset_name": assetName,
            "price": assetPrice,
            "useful_life": usefulLife
        ])
        
        requestReviewIfAppropriate()
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        showPopup = true
        
        updateShareMessage(price: price, years: years, dailyCost: dailyCost)
        captureScreen()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1007) // チャリン音（仮）
    }
    
    func updateShareMessage(price: Double, years: Double, dailyCost: Double) {
        shareMessage = """
        🧮 この買い物、日割りにしたらまさかの “¥\(Int(dailyCost))/日” ✨
        
        📦 \(assetName)（¥\(Int(price))) / 耐用年数：\(Int(years))年
        👉 つまり、毎日コーヒー1杯より安く、創作力バフ中。
        
        #ひわりん #日割り計算 #自己投資は正義 #浪費じゃなくて未来投資
        """
    }
}



extension ContentView {
    func captureScreen() {
        let windowScene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let window = windowScene?.windows.first { $0.isKeyWindow }
        if let rootView = window?.rootViewController?.view {
            let popupView = UIHostingController(
                rootView:
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                if !assetName.isEmpty {
                                    Text(assetName)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .bold()
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                }
                                VStack {
                                    Text("1日あたり")
                                    Text(result.replacingOccurrences(of: "1日あたり", with: ""))
                                }
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 20)
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.8, blue: 0.5), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                                    .frame(minHeight: 240)
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        // Add static Lottie animation frame
                        VStack {
                            LottieLabeledStaticView(animationName: "SparkleBurst")
                                .frame(width: 300, height: 300)
                        }
                        .zIndex(2)
                    }
            ).view
            let targetSize = rootView.bounds.size
            popupView?.bounds = CGRect(origin: .zero, size: targetSize)
            popupView?.backgroundColor = .clear
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let image = renderer.image { context in
                popupView?.drawHierarchy(in: popupView!.bounds, afterScreenUpdates: true)
            }
            capturedImage = image
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct LottieView: UIViewRepresentable {
    var animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        if animationView.animation == nil {
            print("⚠️ アニメーション '\(animationName)' が読み込めませんでした")
        }
        // Confirm loop mode and content mode settings are explicitly set
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        print("▶️ Lottie animation will start playing")
        animationView.play()
        print("✅ Lottie animation is playing")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        // Add content compression resistance priorities
        animationView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct LottieLabeledStaticView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFill
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

@MainActor func requestReviewIfAppropriate() {
    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}


