import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox

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
        ZStack {
            // MARK: - 背景
            ZStack {
                Image("notebook_background")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.15)
                    .ignoresSafeArea()
                
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
                    
                    // MARK: - タイトル＆キャラクター
                    Text("ひわりん")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.72, green: 0.60, blue: 0.36)) // gold
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    Image("shakimaru")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    // MARK: - 入力フォーム
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("資産名（例：MacBook）", text: $assetName)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                            
                            TextField("価格（円）", text: $assetPrice)
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
                            Text(result)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                                .foregroundColor(.white)
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
                    Button(action: {
                        captureScreen()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let image = capturedImage {
                                isSharePresented = true
                                shareItems = [shareMessage, image]
                            }
                        }
                    }) {
                        Text("SNSでシェアする")
                            .padding()
                            .background(Color(red: 0.85, green: 0.70, blue: 0.40))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
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
            }
        }
        .overlay(
            Group {
                if showPopup {
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                            .onTapGesture {
                                showPopup = false
                            }
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                if !assetName.isEmpty {
                                    Text(assetName)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .bold()
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                }
                                Text(result)
                                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        result = "1日あたり約\(Int(dailyCost))円！"
        
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
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        
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
                                Text(result)
                                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
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
