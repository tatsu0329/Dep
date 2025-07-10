import SwiftUI
import AVFoundation
import AudioToolbox

struct ContentView: View {
    @State private var assetName: String = ""
    @State private var assetPrice: String = ""
    @State private var usefulLife: String = ""
    @State private var result: String = ""
    @State private var animateBackground = false
    @State private var shimmerOffset: CGFloat = -100
    
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
                    
                    // タイトル＆キャラクター
                    Text("ShakiShaki 償却")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.72, green: 0.60, blue: 0.36)) // gold
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    Image("shakimaru")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    // 入力フォーム
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
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.5))
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    )
                    
                    // 計算ボタン
                    Button(action: calculate) {
                        Text("しゃきっと計算！")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.85, green: 0.70, blue: 0.40))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    
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
                            
                            // 自己肯定メッセージ
                            Text("これは1日あたりの自己投資額です✨")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    // しゅわしゅわ円グラフ（リッチなラグジュアリー感）
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color(red: 0.75, green: 0.60, blue: 0.35), Color(red: 0.93, green: 0.87, blue: 0.72)]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: Color(red: 0.75, green: 0.60, blue: 0.35).opacity(0.3), radius: 8, x: 0, y: 4)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .offset(x: shimmerOffset, y: shimmerOffset)
                            .blur(radius: 2)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: shimmerOffset)
                        
                        VStack(spacing: 4) {
                            Text("償却率")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("70%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.35))
                        }
                    }
                    .padding(.top, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(radius: 5)
                    )
                    .padding()
                    
                    // シェアボタン
                    Button(action: {
                        // シェア画像生成機能（後で追加）
                    }) {
                        Text("SNSでシェアする")
                            .padding()
                            .background(Color(red: 0.85, green: 0.70, blue: 0.40))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    
                    // 広告 or プレミアム誘導
                    VStack {
                        Divider()
                        Text("🚀 プレミアムで透かしなし保存！")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 0.99, green: 0.98, blue: 0.95))
                        .shadow(color: .gray.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .padding()
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
        
        // Hapticとサウンド（仮）
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1007) // チャリン音（仮）
    }
}
