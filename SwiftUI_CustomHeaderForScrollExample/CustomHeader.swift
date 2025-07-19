//
//  CustomHeader.swift
//  SwiftUI_CustomHeaderForScrollExample
//
//  Created by cano on 2025/07/19.
//

import SwiftUI

struct CustomHeader: View {
    // スクロール位置（現在位置）
    @State private var naturalScrollOffset: CGFloat = 0
    // ヘッダーの表示/非表示切り替えのために記録する直前の位置
    @State private var lastNaturalOffset: CGFloat = 0
    // ヘッダーの現在のオフセット（非表示アニメーション用）
    @State private var headerOffset: CGFloat = 0
    // 上方向スクロールかどうか
    @State private var isScrollingUp: Bool = false

    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let headerHeight = 60 + safeArea.top // ヘッダーの高さ（ステータスバー分込み）

            ScrollView(.vertical) {
                LazyVStack(spacing: 15) {
                    ForEach(1...20, id: \.self) { _ in
                        DummyView() // ダミーカード（プレースホルダー）
                    }
                }
                .padding(15)
            }
            // ヘッダーをScrollViewの上部に重ねる（安全領域を考慮）
            .safeAreaInset(edge: .top, spacing: 0) {
                HeaderView()
                    .padding(.bottom, 15)
                    .frame(height: headerHeight, alignment: .bottom)
                    .background(.background)
                    .offset(y: -headerOffset) // ヘッダーを上にずらすことで非表示アニメーション
            }
            // スクロール位置の変化を監視（独自の onScrollGeometryChange 使用）
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                // スクロール可能な最大位置を計算
                let maxHeight = proxy.contentSize.height - proxy.containerSize.height
                // オフセットを制限付きで返す
                return max(min(proxy.contentOffset.y + headerHeight, maxHeight), 0)
            } action: { oldValue, newValue in
                // スクロール方向判定
                let isScrollingUp = oldValue < newValue
                self.isScrollingUp = isScrollingUp

                // ヘッダーのオフセット更新（上下にずらす量）
                headerOffset = min(max(newValue - lastNaturalOffset, 0), headerHeight)

                // 現在のオフセットを記録
                naturalScrollOffset = newValue
            }
            // スクロールのフェーズが変わったときの処理（停止時のヘッダーアニメーション）
            .onScrollPhaseChange({ oldPhase, newPhase, context in
                // スクロール終了時かつヘッダーが中途半端な位置にある場合に調整
                if !newPhase.isScrolling && (headerOffset != 0 || headerOffset != headerHeight) {
                    withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                        if headerOffset > (headerHeight * 0.5) && naturalScrollOffset > headerHeight {
                            // 一定量以上スクロールされていればヘッダーを完全に隠す
                            headerOffset = headerHeight
                        } else {
                            // それ以外はヘッダーを全表示に戻す
                            headerOffset = 0
                        }

                        // 新たな基準点として offset を保存
                        lastNaturalOffset = naturalScrollOffset - headerOffset
                    }
                }
            })
            // 上方向スクロールの変化に反応して offset の基準を更新
            .onChange(of: isScrollingUp, { oldValue, newValue in
                lastNaturalOffset = naturalScrollOffset - headerOffset
            })
            .ignoresSafeArea(.container, edges: .top)
        }
    }

    // MARK: - ヘッダービュー
    @ViewBuilder
    func HeaderView() -> some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)

            Spacer(minLength: 0)

            // ボタン類（機能は未実装）
            Button("", systemImage: "airplayvideo") { }
            Button("", systemImage: "bell") { }
            Button("", systemImage: "magnifyingglass") { }
        }
        .font(.title3)
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 15)
    }

    // MARK: - ダミーカード（プレースホルダー表示用）
    @ViewBuilder
    func DummyView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .frame(height: 200)

            HStack(spacing: 10) {
                Circle()
                    .frame(width: 45, height: 45)

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .frame(height: 10)

                    HStack(spacing: 10) {
                        Rectangle().frame(width: 100)
                        Rectangle().frame(width: 80)
                        Rectangle().frame(width: 60)
                    }
                    .frame(height: 10)
                }
            }
        }
        .foregroundStyle(.tertiary) // グレー系のプレースホルダー表示
        //Spacer(minLength: 2)
    }
}

#Preview {
    ContentView()
}
