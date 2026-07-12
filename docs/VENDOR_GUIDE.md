# AdServerSDK 導入ガイド

## 1. AdServerSDK とは

**AdServerSDK** は、当社の広告配信サーバーから広告コンテンツを取得・表示し、インプレッションおよびクリックを自動的に記録する iOS 向け広告配信 SDK です。

広告の読み込みは **直接描画 API（`AdServerBannerView`）を主経路**としています。AdMob を含む外部 SDK は不要で、当社サーバーから直接バナーを取得・描画・計測します。Google AdMob のメディエーション（カスタムイベント）経由でも利用できますが、これは任意の追加経路です（→ [付録 A](#付録-a-admob-メディエーション経由で利用する場合)）。

Swift Package Manager（SPM）を通じてバイナリ（XCFramework）形式で配布されます。ソースコードは提供されません。

### 主な機能

| 機能 | 説明 |
|------|------|
| 広告取得 | 直接描画 API（または任意で AdMob カスタムイベント経由）で広告コンテンツを自動取得 |
| 広告表示 | 取得した画像をネイティブ UIView としてレンダリング |
| インプレッション計測 | MRC 準拠のビューアビリティ条件（広告面の 50% 以上が連続 1 秒以上可視・画像描画成功が前提）を満たした時点で自動的に記録 |
| クリック計測 | バナータップ時に自動的に記録し、遷移先 URL（http / https のみ）を開く |

### 利用に必要なもの

- 当社との利用契約
- （任意）Google AdMob アカウント — **AdMob メディエーション経由で利用する場合のみ**（Google との直接契約が必要・→ [付録 A](#付録-a-admob-メディエーション経由で利用する場合)）

---

## 2. 動作要件

| 項目 | バージョン |
|------|----------|
| iOS | 16.0 以上 |
| Xcode | **動作確認済み: 16.x**（15.x は配布バイナリの生成コンパイラより古いため動作未確認です。15.x での利用をご希望の場合は当社までご相談ください） |
| Google Mobile Ads SDK | **不要**（直接配信のコア `AdServerSDK` は GoogleMobileAds に依存しません）。AdMob メディエーション経由で利用する場合のみ別途必要（→ [付録 A](#付録-a-admob-メディエーション経由で利用する場合)） |

---

## 3. インストール

> 📌 現在バイナリ配布されているのは**直接配信用のコア(`AdServerSDK`)のみ**です。コアは GoogleMobileAds を取得しません。AdMob メディエーション経路を利用する場合の配布方法は当社までお問い合わせください。

Xcode のメニューから **File > Add Package Dependencies...** を選択し、以下の URL を入力してください。

```
https://github.com/AGIFT-co/adserver-iOS-SDK-dist.git
```

> ⚠️ **Xcode の GUI で追加する場合の注意**: URL を入力したあと、**Dependency Rule** を「Up to Next Major Version」ではなく **「Exact Version」** に変更し、`0.0.3` を入力してください。当社は版ごとに動作確認したバージョンを案内するため、常に完全一致で固定してください。特にプレリリース版（`-rc.N`）は semver 仕様により `from:` /「Up to Next Major」では解決されず「該当バージョンなし」になります。

または `Package.swift` に追加します（同じ理由で `exact` を使います）。

```swift
dependencies: [
    .package(url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist.git", exact: "0.0.3")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "AdServerSDK", package: "adserver-iOS-SDK-dist")
        ]
    )
]
```

---

## 4. 初期設定

アプリ起動時に `AdServer.configure()` を呼び出します。

```swift
import AdServerSDK

@main
struct MyApp: App {
    init() {
        AdServer.configure()
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

> AdMob 経路を利用する場合のみ、別途 `GADApplicationIdentifier` の設定が必要です（→ [付録 A](#付録-a-admob-メディエーション経由で利用する場合)）。直接配信のみの場合は不要です。

---

## 5. バナー広告の表示（直接描画 API）

AdMob を介さず、SDK が当社サーバーから直接バナーを取得・描画・計測する主経路です。AdMob アカウント・`GADApplicationIdentifier`・app-ads.txt はいずれも不要です。

### 基本実装

```swift
import AdServerSDK

let banner = AdServerBannerView(adUnitId: "<AdUnit の UUID>", size: .banner)
banner.delegate = self               // 任意（必要な通知だけ実装すればよい）
banner.fallbackView = myHouseAdView  // 任意（no-fill / エラー時に枠内へ表示）
view.addSubview(banner)
banner.load()
```

> **注意:** `AdServerBannerView` はコードからの生成のみ対応しています（Storyboard / XIB からの生成は不可）。

### 対応バナーサイズ（3 種固定）

| `AdBannerSize` | サイズ（pt） | 用途 |
|---|---|---|
| `.banner` | 320 × 50 | スマートフォン標準 |
| `.largeBanner` | 320 × 100 | スマートフォン大型 |
| `.mediumRectangle` | 300 × 250 | スマートフォン・タブレット |

### 挙動

- 生成した時点で指定サイズの枠を確保し、**no-fill・エラー時は**枠を畳みません（レイアウトのガタつき防止）。`fallbackView` 未指定なら空枠のまま保持されます
- 取得成功後は自動リフレッシュ（既定 60 秒）、失敗時は指数バックオフで自動リトライします
- 画面外・アプリのバックグラウンド中はリフレッシュ / リトライを停止し、復帰時に再開します
- VIEW（インプレッション）・CLICK は自動記録されます（VIEW の記録条件は §1 の機能表を参照）
- 取得結果やイベントは `AdServerBannerViewDelegate`（全メソッド実装任意）で受け取れます
- 障害・ポリシー対応時は、当社サーバーからの指示で配信を一時停止することがあります（→ 次節「サーバー側の配信停止制御（遠隔制御）」。停止モードによっては枠が畳まれます）

### サーバー側の配信停止制御（遠隔制御）

障害対応・ポリシー対応などのため、当社は配信サーバーからの指示で SDK の広告配信を一時停止することがあります（アプリの更新は不要です）。

- 停止には 2 つのモードがあります:
  - **soft**（既定）: 広告の取得・表示を停止しますが、**枠は維持**されます（`fallbackView` があれば表示）
  - **hard**: **枠が畳まれます**（`intrinsicContentSize` がゼロになり `isHidden` になります）。配信再開時に自動で元へ戻ります
- 停止中も SDK は一定間隔で配信可否を再確認し、許可に戻れば自動で配信を再開します
- ⚠️ **hard モードの注意**: 枠が畳まれるのは Auto Layout の intrinsic size 経由でレイアウトしている場合です。**明示の高さ制約（例: `heightAnchor` の固定）で枠サイズを固定している場合、ビューは非表示になりますが空間はそのまま残ります**。枠を完全に畳みたい場合は intrinsic size に任せるレイアウトを推奨します

### クリエイティブ画像の扱い

SDK は画像を **scaleAspectFit**（アスペクト比を維持）で枠内に描画します。配信レスポンスの実寸に応じて次のように扱います。

| クリエイティブと枠の関係 | 表示結果 |
|---|---|
| 枠と一致 | 枠いっぱいに表示（推奨。枠と同じサイズで用意してください） |
| 枠より大きい | アスペクト比を維持して枠内に**縮小**（上下または左右に余白） |
| 枠より小さい | **拡大せず原寸のまま中央表示**（引き伸ばしによる画質劣化を避けるため） |

クリエイティブ画像は、指定するバナーサイズと同じサイズ・アスペクト比で用意することを推奨します。

**画像取得に失敗した場合**、広告レスポンスの `altText` がバナー領域にテキストとして表示されます。altText 表示中は VIEW（インプレッション）は記録されません（ビューアビリティ計測は画像描画成功が前提です）。失敗の詳細は Console.app（subsystem: `AdServerSDK`）で確認できます。

### 初回表示を速くするには

初回バナーは「`GET /delivery`（広告取得）→ 画像ダウンロード」の2回のネットワーク往復が必要で、アプリ起動直後はコールドスタート（DNS/TLS）も加わるため、わずかな表示ラグが出ます（AdMob のバナーも同様で、読み込み中は枠が空になります）。完全には無くせませんが、次で短縮できます。

- **`AdServer.configure()` をアプリ起動時に呼ぶ**：起動時に配信ホストへの接続を事前確立（ウォームアップ）し、初回 `/delivery` の接続コストを省きます（SDK が自動で実施）。
- **バナーを早めに生成して `load()` する**：画面に出す直前まで待たず、可能な範囲で早くロードを開始すると、表示時点で取得が進んでいて速く見えます。
- **（サーバ/運用側への依頼）配信画像に `Cache-Control` を付与**：2回目以降のリフレッシュ・再表示が URLSession のキャッシュから高速化されます。あわせて**画像サイズの最適化・CDN 配信**でダウンロード時間を短縮できます。

> 枠は最初から確保されるためレイアウトのガタつき（CLS）は起きません。読み込み中の空き枠が気になる場合は `fallbackView` の活用も検討してください。

---

## 6. 会員 ID（PPID）と同意

PPID（会員 ID）を使うと、広告配信サーバー側でユーザー属性に応じた広告の出し分けが可能になります。**設定は任意**です。直接配信・AdMob 経路のいずれでも同じ API で扱います。

### 会員 ID（PPID）の設定と送信条件

ログイン・ログアウトのタイミングで設定します。

> **重要:** `setPPID()` を呼んだだけでは送信されません。SDK は **アプリ内同意（`setConsent(true)`）が成立している間のみ**、リクエストに PPID を含めます（SDK 内蔵の送信ゲート・既定は送信しない）。同意が無い間は自動的に非ターゲティング配信になります。

```swift
// ログイン後（設定するだけ。送信はゲート成立中のみ）
AdServer.setPPID(currentUser.memberId)

// ユーザーが同意したとき / 同意を撤回したとき
AdServer.setConsent(true)   // 同意（既定は false）
AdServer.setConsent(false)  // 撤回 → 以降のリクエストから PPID が除外される

// ログアウト後
AdServer.setPPID(nil)
```

> 送信する値は広告配信サーバー側で保持している会員 ID と一致している必要があります。

### ATT（App Tracking Transparency）について — 不要です

> **方針変更（2026-06-22）:** PPID の扱いはクロスアプリの広告ターゲティング（Apple の定義する「トラッキング」）に該当しないとの判断により、**ATT プロンプトの取得は不要**になりました。これに伴い SDK から ATT 関連 API（`requestTrackingAuthorization()` / `trackingAuthorizationStatus`）を撤去し、`NSUserTrackingUsageDescription` の設定も不要です。PPID の送信ゲートは **アプリ内同意（`setConsent`）のみ**で判定します。

PPID を利用する場合に必要なのは、上記の **アプリ内同意の取得**（`setConsent(true)`）だけです。

#### 旧バージョンから移行する場合

以前のバージョンで以下の API を呼んでいた場合は、**呼び出しを削除**してください（同名 API は撤去済みのため、残すとビルドが通りません）。ATT を独自に扱いたい場合は、アプリ側で直接 `AppTrackingTransparency` フレームワークを利用してください（本 SDK の PPID 送信判定には影響しません）。

- `AdServer.requestTrackingAuthorization()` → 削除
- `AdServer.trackingAuthorizationStatus` → 削除
- `AdTrackingAuthorizationStatus`（enum） → 撤去

#### ⚠️ AdMob（GoogleMobileAds）を併用する場合

ATT 不要なのは **本 SDK の PPID 送信に関して**です。**AdMob（GMA）を組み込むアプリでは、GMA 側の要件として ATT プロンプトや `NSUserTrackingUsageDescription` が引き続き必要になる場合があります**（GMA が内部で ATT を参照・表示することがあるため）。AdMob 経路を使う場合は、Google の最新ガイドに従って ATT 対応の要否を判断してください（本 SDK はこれに関与しません）。

---

## 7. 個人情報の取り扱いと責務

SDK は `setPPID()` で渡された会員 ID を、**アプリ内同意（`setConsent(true)`）が成立している間のみ**広告取得 API およびログ API に送信します（SDK 内蔵の送信ゲート・既定は送信しない）。SDK 自体は値の内容を関知せず、加工も行いません。

### アプリ側（パブリッシャー）の責務

PPID を利用する場合、以下はアプリ側で対応が必要です。

| 項目 | 内容 |
|------|------|
| 同意 UI の表示・取得 | 同意モーダル等でユーザーの同意を取得し、結果を `AdServer.setConsent()` で SDK に伝える（撤回時も同様） |
| 利用目的の開示 | 会員 ID を広告配信の最適化に利用することをプライバシーポリシーに明記 |
| App Store 申告 | App Privacy（プライバシー栄養ラベル）を申告。記入指針は [PRIVACY_DISCLOSURE.md](PRIVACY_DISCLOSURE.md) を参照 |

### SDK 提供者（当社）の責務

| 項目 | 内容 |
|------|------|
| PPID 送信ゲート | アプリ内同意の成立時のみ送信（既定 = 送信しない）。同意を欠いた瞬間から自動で除外 |
| 撤回の反映 | `setConsent(false)` を以降の新規リクエストへ即時反映（撤回時点で送信中のリクエストには反映されない場合があります）。端末内の未送信ログに残る PPID も破棄 |
| 安全な送信・保存 | HTTPS による通信の暗号化。未送信ログの永続化ファイルはファイル保護を明示し、バックアップ対象から除外 |
| 利用目的の限定 | 受け取った PPID を広告配信・ログ記録以外の目的で使用しない |

### 同意がない間は PPID を送信しません（SDK 側ゲート）

同意がない間は **SDK が PPID をリクエストに含めません**（送信そのものを止めます）。したがって、同意のない PPID はそもそもサーバーへ送信されません。送信可否の判定は SDK 内の単一ゲートに集約されています。

---

## 8. 導入チェックリスト（直接配信）

### アプリ実装

- [ ] SPM で `AdServerSDK`（コア）を追加していること
- [ ] `AdServer.configure()` がアプリ起動時に呼ばれていること
- [ ] `AdServerBannerView` をコードから生成し（Storyboard 不可）、`load()` を呼んでいること
- [ ] 必要に応じて `fallbackView` を設定していること（no-fill / エラー時の枠内表示）

### クリエイティブ

- [ ] クリエイティブ画像のサイズ・アスペクト比が指定バナーサイズと一致していること
- [ ] `altText` に適切な代替テキストが設定されていること

### PPID を利用する場合（任意）

- [ ] ログイン後に `AdServer.setPPID()` で会員 ID を設定していること
- [ ] 同意取得後に `AdServer.setConsent(true)` を呼んでいること（撤回時は `false`）
- [ ] App Privacy 申告を [PRIVACY_DISCLOSURE.md](PRIVACY_DISCLOSURE.md) に従って記入したこと

> AdMob メディエーション経由で利用する場合の追加チェックリストは [付録 A](#付録-a-admob-メディエーション経由で利用する場合) を参照してください。

---

## 9. よくある質問

**Q. 広告が表示されない**
（直接描画）`AdServer.configure()` の呼び出し、`AdServerBannerView` の `adUnitId`（AdUnit の UUID）と `load()` の呼び出しを確認してください。詳細は Console.app（subsystem: `AdServerSDK`）のログで切り分けられます。

**Q. 画像に余白が出る / 小さく表示される**
クリエイティブのサイズが枠と異なる場合に発生します。枠より大きい画像は縮小、小さい画像は拡大せず原寸で中央表示します（§5「クリエイティブ画像の扱い」参照）。枠と同じサイズで用意すると枠いっぱいに表示されます。

**Q. 自社広告が取れなかった場合、枠はどうなる？**
（直接描画）no-fill・エラー時は枠は畳まれず固定サイズのまま保持され、`fallbackView` を設定していればそれが表示されます。SDK が裏で自動リトライします（§5 参照）。なお、当社サーバーからの配信停止指示（遠隔制御）が **hard モード**で行われた場合に限り、枠が畳まれることがあります（§5「サーバー側の配信停止制御（遠隔制御）」参照）。

**Q. PPID（会員 ID）は必ず設定が必要？**
任意です。設定することで広告配信サーバー側でユーザー属性に応じた広告の出し分けが可能になります。実際に送信されるのは**アプリ内同意（`setConsent(true)`）が成立している間のみ**で、同意が欠けると SDK が自動的に送信を止めます（非ターゲティング配信になります）。

**Q. ATT プロンプトの対応は必要？**
不要です（2026-06-22 方針変更）。PPID の扱いは Apple の定義する「トラッキング」に該当しないとの判断により、ATT プロンプトの取得・`NSUserTrackingUsageDescription` の設定はいずれも不要です。PPID 送信ゲートは**アプリ内同意のみ**で判定します。

---

## 付録 A. AdMob メディエーション経由で利用する場合

> ⚠️ **現在、AdMob 経路のバイナリ（`AdServerSDKAdMob`）は配布していません**（コア `AdServerSDK` のみ配布）。AdMob メディエーション経由での利用をご希望の場合は当社までお問い合わせください。本付録は将来の配布・既存利用者向けの参考情報です。

AdMob のカスタムイベント（メディエーション）機能を経由して当社広告を配信する経路です。AdMob アカウント（Google との直接契約）が別途必要です。

### A-1. AdMob App ID の設定

`Info.plist` に AdMob コンソールで発行した App ID を追加します。

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

> **注意:** この設定がない場合、アプリ起動時にクラッシュします。App ID は AdMob コンソールの「アプリ設定」から確認できます。

### A-2. カスタムイベント設定

| 項目 | 設定値 |
|------|--------|
| クラス名 | `AdServerSDKBannerCustomEventAdapter` |
| パラメーター | AdMob の Ad Unit ID（例: `ca-app-pub-xxxx/yyyy`） |

1. [AdMob 管理画面](https://admob.google.com/) にログイン
2. **メディエーション** を選択
3. メディエーショングループを作成（または既存のグループを選択）
4. ウォーターフォールに **カスタムイベントを追加** を選択
5. 上記の設定値を入力して保存

> パラメーター（Ad Unit ID）が未設定の場合、アダプタは即座に読み込みを失敗させます（no-fill ではなく設定ミスとして扱われます）。
> AdMob の利用規約・ポリシーへの準拠については [ADMOB_POLICY.md](ADMOB_POLICY.md) を参照してください。

### A-3. app-ads.txt の設置

AdMob で広告を配信するには、アプリのデベロッパーウェブサイトに `app-ads.txt` を設置する必要があります。2025年1月以降、新規アプリでは**必須**です。設置しない場合、広告が配信されません。

#### 1. App Store のデベロッパーウェブサイトを設定する

App Store Connect でアプリの情報を開き、「マーケティング URL」または「サポート URL」欄に自社のウェブサイト URL を登録します（このドメインに `app-ads.txt` を設置します）。

**メインドメインに設置が難しい場合はサブドメインでも可:**

```
https://apps.example.com/app-ads.txt        ← サブドメインでも有効
https://developer.example.com/app-ads.txt   ← 同上
```

App Store Connect の「マーケティング URL」に登録する URL をサブドメインにすれば、メインドメインへの変更は不要です。

#### 2. app-ads.txt ファイルを作成する

`pub-XXXXXXXXXXXXXXXX` をご自身の AdMob パブリッシャー ID に置き換えてください。

```
google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
```

**パブリッシャー ID の確認方法:** AdMob コンソール → アカウント → アカウント情報 → パブリッシャー ID

#### 3. ウェブサーバーに配置する

登録したドメインの直下に配置します（サブディレクトリは無効）。

```
https://apps.example.com/app-ads.txt        ← 正しい
https://apps.example.com/ads/app-ads.txt     ← NG
```

ブラウザで `https://登録したドメイン/app-ads.txt` にアクセスし、内容が表示されることを確認してください。

> **よくある失敗:** `www.example.com` と `example.com` でアクセス結果が異なる場合があります。どちらでもアクセスできるよう設定してください。

#### 4. AdMob コンソールで確認する

AdMob コンソール → アプリ → 該当アプリ → 「app-ads.txt」タブで認証状態を確認します。反映には最大 24 時間かかります。

#### 最終手段：GitHub Pages を使う方法

自社ドメインへの設置がどうしても困難な場合、GitHub Pages で `app-ads.txt` を公開する方法があります。

1. GitHub で新規パブリックリポジトリを作成（例: `your-org.github.io`）
2. リポジトリのルートに `app-ads.txt` を追加
3. Settings → Pages → Source を `main` ブランチに設定
4. 発行された URL（例: `https://your-org.github.io/app-ads.txt`）を App Store Connect のマーケティング URL として登録

> ⚠️ リポジトリの削除・非公開化や GitHub Pages の無効化・障害で `app-ads.txt` が読み取れなくなると**広告配信が停止する可能性があります**。自社ドメインでの運用が可能になった時点で速やかに移行してください。

### A-4. バナーサイズ（AdMob 経路）

AdMob 経路ではバナーサイズを AdMob 管理画面では設定しません。アプリのコードで `GADBannerView` を実装する際に指定した値が SDK に渡され、その値に合わせてビューが生成されます。

```swift
bannerView.adSize = GADAdSizeBanner  // ← ここで指定したサイズが SDK に渡される
```

| 定数名 | サイズ（pt） | 用途 |
|--------|------------|------|
| `GADAdSizeBanner` | 320 × 50 | スマートフォン標準 |
| `GADAdSizeLargeBanner` | 320 × 100 | スマートフォン大型 |
| `GADAdSizeMediumRectangle` | 300 × 250 | スマートフォン・タブレット |
| `GADAdSizeLeaderboard` | 728 × 90 | タブレット横向き |

クリエイティブ画像の扱い（縮小・原寸センタリング・取得失敗時の altText）は §5「クリエイティブ画像の扱い」と共通です。

### A-5. AdMob 設定チェックリスト

- [ ] AdMob アカウントを自社で作成・管理していること（Google との直接契約が必要）
- [ ] アプリを AdMob に登録し、App ID を取得していること
- [ ] `Info.plist` に `GADApplicationIdentifier` を追加していること
- [ ] バナー広告ユニットを作成し、Ad Unit ID を取得していること
- [ ] メディエーショングループのウォーターフォールにカスタムイベント（クラス名 `AdServerSDKBannerCustomEventAdapter`）を追加していること
- [ ] `app-ads.txt` をデベロッパーウェブサイトのドメイン直下に設置し、AdMob コンソールで認証が完了したこと

### A-6. AdMob 経路の FAQ

**Q. 広告が表示されない**
AdMob 管理画面でカスタムイベントの「クラス名」が正確に入力されているか確認してください（`AdServerSDKBannerCustomEventAdapter`）。

**Q. 自社広告が取れなかった場合、枠はどうなる？**
AdMob 管理画面で設定したウォーターフォールに従い、次の広告ソースに自動フォールバックします。何も設定しない場合は枠が空白になります。

---

## 参考

- [PRIVACY_DISCLOSURE.md](PRIVACY_DISCLOSURE.md) — App Privacy（栄養ラベル）記入指針
- [ADMOB_POLICY.md](ADMOB_POLICY.md) — AdMob 利用規約・採用メリット（AdMob 経路のみ）
- [AdMob カスタムイベント設定方法](https://support.google.com/admob/answer/3019581)
- [AdMob バナーサイズ一覧](https://developers.google.com/admob/ios/banner#banner_sizes)
