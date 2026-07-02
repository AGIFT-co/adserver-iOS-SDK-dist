# AdServerSDK（iOS）

当社の広告配信サーバーからバナー広告を取得・表示し、インプレッション / クリックを自動計測する iOS SDK です。Swift Package Manager でバイナリ（XCFramework）として配布されます。ソースコードは含まれません。

---

## クイックスタート

### 1. パッケージを追加

Xcode で **File > Add Package Dependencies...** を開き、次の URL を入力します。

```
https://github.com/AGIFT-co/adserver-iOS-SDK-dist.git
```

> ⚠️ **Dependency Rule は必ず「Exact Version」を選び、当社が案内するバージョン（本リリースは `0.0.2-rc.4`）を指定してください。** 当社は版ごとに動作確認したバージョンを案内するため、意図しない版への自動更新を避けます。特にプレリリース版（`-rc.N`）は semver 仕様により、既定の「Up to Next Major Version」では解決されず「該当バージョンなし」になります。

`Package.swift` で追加する場合:

```swift
dependencies: [
    .package(url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist.git", exact: "0.0.2-rc.4")
]
```

### 2. 初期化（アプリ起動時）

```swift
import AdServerSDK

AdServer.configure()
```

### 3. バナーを表示

```swift
import AdServerSDK

let banner = AdServerBannerView(adUnitId: "<当社から共有する AdUnit の UUID>", size: .banner)
banner.delegate = self        // 任意（取得成功 / 失敗・VIEW / CLICK の通知）
banner.fallbackView = myView  // 任意（no-fill 時に枠内へ表示）
view.addSubview(banner)       // この時点でサイズ分の枠を確保（レイアウトのガタつき防止）
banner.load()
```

対応サイズ: `.banner`(320×50) / `.largeBanner`(320×100) / `.mediumRectangle`(300×250)

---

## 動かす前に必要なもの

- **`adUnitId`（AdUnit の UUID）**: 当社から個別に共有します。
- **配信サーバー側にクリエイティブ（広告）が登録されていること**: 対象 AdUnit に広告が無い場合、SDK は no-fill として扱い、枠は空のまま（または `fallbackView`）になります。**「真っ白で何も出ない」場合はまずこれを確認してください**（導入ミスではなく在庫なしのことが多いです）。

---

## 動作要件

| 項目 | バージョン |
|------|----------|
| iOS | 16.0 以上 |
| Xcode | 15.0 以上 |

---

## 詳しい使い方

導入の詳細（PPID / 同意、AdMob メディエーション経路、App Privacy 申告など）は同梱ドキュメントを参照してください。

- [docs/VENDOR_GUIDE.md](docs/VENDOR_GUIDE.md) — 導入ガイド（必読）
- [docs/PRIVACY_DISCLOSURE.md](docs/PRIVACY_DISCLOSURE.md) — App Privacy（栄養ラベル）記入指針
- [docs/ADMOB_POLICY.md](docs/ADMOB_POLICY.md) — AdMob 利用規約（AdMob 経路を使う場合のみ）

---

## ライセンス

Copyright © 2026 株式会社agift. All rights reserved. 詳細は [LICENSE](LICENSE) を参照してください。
