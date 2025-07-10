import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox

struct ContentView: View {
    @State private var assetName: String = ""
    @State private var assetPrice: String = ""
    @State private var usefulLife: String = ""
    @State private var result: String = ""
    @State private var animateBackground = false
    @State private var shimmerOffset: CGFloat = -100
    @State private var shareMessage: String = ""
    @State private var isSharePresented = false
    @State private var capturedImage: UIImage?
    @State private var shareItems: [Any] = []
    
    var body: some View {
        ZStack {
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
                    
                    // SNSシェアボタン
                    VStack(spacing: 8) {
                        Text("このアプリが役立ったら、ぜひ友達にもシェアしてください！")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Xシェア処理
                            }) {
                                Image("icon_x") // Add custom asset named icon_x
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                            
                            Button(action: {
                                // LINEシェア処理
                            }) {
                                Image("icon_line") // Add custom asset named icon_line
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                            
                            Button(action: {
                                // Facebookシェア処理
                            }) {
                                Image("icon_facebook") // Add custom asset named icon_facebook
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                            
                            Button(action: {
                                // Instagramシェア処理
                            }) {
                                Image("icon_instagram") // Add custom asset named icon_instagram
                                    .resizable()
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    // タイトル＆キャラクター
                    Text("ひわりん")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.72, green: 0.60, blue: 0.36)) // gold
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    Image("shakimaru")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    // 入力フォーム
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("資産名（例：MacBook）", text: $assetName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.purple)
                            
                            TextField("価格（円）", text: $assetPrice)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.purple)
                            
                            TextField("耐用年数（年）", text: $usefulLife)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.purple)
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
                    
                    // 計算ボタン
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
                    
                    // 結果表示
                    if !result.isEmpty {
                        VStack(spacing: 12) {
                            Text("結果：")
                                .font(.headline)
                            Text(result)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(red: 0.98, green: 0.96, blue: 0.92))
                                .cornerRadius(10)
                            
                            
                        }
                    }
                    
                    if !shareMessage.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SNS投稿テンプレ")
                                .font(.headline)
                            Text(shareMessage)
                                .font(.system(size: 14, design: .monospaced))
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // シェアボタン
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
        .navigationTitle("減価償却メーカー")
        .onAppear {
            animateBackground = true
            shimmerOffset = 100
        }
    }
    
    // 計算ロジック
    func calculate() {
        guard let price = Double(assetPrice),
              let years = Double(usefulLife),
              years > 0 else {
            result = "入力を確認してください。"
            return
        }
        let totalDays = years * 365
        let dailyCost = price / totalDays
        result = "1日あたり約¥\(Int(dailyCost))です！"
        
        shareMessage = """
        🧮 この買い物、日割りにしたらまさかの “¥\(Int(dailyCost))/日” ✨
        
        📦 \(assetName)（¥\(Int(price))) / 耐用年数：\(Int(years))年
        👉 つまり、毎日コーヒー1杯より安く、創作力バフ中。
        
        #ひわりん #日割り計算 #自己投資は正義 #浪費じゃなくて未来投資
        """
        
        captureScreen()
        
        // Hapticとサウンド（仮）
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1007) // チャリン音（仮）
    }
}

extension ContentView {
    func captureScreen() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(bounds: window?.bounds ?? .zero)
        let image = renderer.image { ctx in
            window?.layer.render(in: ctx.cgContext)
        }
        capturedImage = image
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
