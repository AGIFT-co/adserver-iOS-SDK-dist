# Google AdMob 利用規約・採用ガイド

AdServerSDK は Google AdMob のカスタムイベント機能を利用して広告を配信します。このドキュメントでは、AdMob を採用する理由・メリットと、パブリッシャー（アプリ開発者）として遵守が必要な規約・ポリシーをまとめています。

> **注意:** このドキュメントは 2026年4月 時点の情報をもとに作成しています。Google のポリシーは変更される場合があるため、定期的に[公式ドキュメント](#参考リンク)を確認してください。

---

## 1. AdMob カスタムイベントを採用するメリット

### WebView 埋め込みとの比較

AdMob カスタムイベントを利用した広告表示は、WebView による広告埋め込みと比較して以下の優位性があります。

| 項目 | WebView 埋め込み | AdMob カスタムイベント |
|------|----------------|----------------------|
| 表示 | Web レンダリング（フォント・レイアウト差異あり） | ネイティブ UIView（iOS 標準UIとの統一感） |
| 広告フォールバック | なし（自社広告が取れなければ枠が空白） | ウォーターフォールによる自動フォールバック（後述） |
| ATT 対応 | 不要（PPID はトラッキング非該当の判断・2026-06-22） | AdMob SDK が管理 |

### ウォーターフォール（メディエーション）によるフォールバック

AdMob のメディエーション機能を使うと、自社広告が取れなかった場合に次の広告ソースへ自動的に切り替わります。

```
自社広告サーバー（カスタムイベント）
    ↓ 広告なし
次の広告ソース（例: Google 広告、その他ネットワーク）
    ↓ 広告なし
さらに次の広告ソース...
```

フォールバック先は **AdMob 管理画面のメディエーショングループで自由に設定できます**。Google 広告を設定することも、他のネットワークのみを設定することも可能です。何も設定しなければ枠は空白になります。

---

## 2. カスタムイベントの利用

### ✅ 許可されている利用

AdMob のカスタムイベント機能は、AdMob メディエーションが公式にサポートしていない広告ネットワークや独自広告サーバーに接続するために公式に提供されている機能です。

AdServerSDK が行っている以下の利用は、この公式機能の想定された用途に該当します。

- AdMob カスタムイベント経由で独自広告サーバー（GET）にリクエストを送信すること
- 取得した広告クリエイティブを表示すること
- インプレッション・クリックを独自ログ API（POST）に記録すること

### ❌ 禁止されている利用

カスタムイベントは、以下の目的での使用は認められていません。（出典: [Custom event - Google AdMob Help](https://support.google.com/admob/answer/3019581)）

- エクスチェンジ、メディエーター、オプティマイザーからの需要（demand）を流すこと
- リアルタイムの価格情報に基づいて動的に広告リクエストを振り分けること

---

## 3. SDK の配布・共有

### ✅ 許可されている配布形式

| 配布形式 | 可否 | 理由 |
|---------|------|------|
| バイナリ（XCFramework）配布 | ✅ 可 | Google SDK のソースコードを含まないため |
| Google Mobile Ads SDK を利用者が個別に追加する構成 | ✅ 可 | Google SDK コードの第三者共有に該当しない |

### ❌ 禁止されている配布形式

以下は明示的に禁止されています。

> "Publishers may not share either source Google SDK code or uncompiled Google SDK code with any third party"
> — [Google Mobile Ads SDK Terms of Service](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/terms)

- Google Mobile Ads SDK のソースコードを第三者と共有すること
- Google Mobile Ads SDK のコンパイル前コードを第三者に配布すること

AdServerSDK は XCFramework（バイナリ）のみを配布し、Google Mobile Ads SDK は利用者が Swift Package Manager で直接追加する構成を採用しているため、この制限に準拠しています。

---

## 4. パブリッシャー（利用者）の要件

### Google との直接契約が必要

> "Publishers may not enter into sub-syndication relationships — Google should have a direct relationship with the publisher, rather than through an intermediate party"
> — [AdMob Terms of Service](https://developers.google.com/admob/terms)

AdServerSDK を組み込むアプリの開発者（パブリッシャー）は、以下の要件を満たす必要があります。

- **それぞれ自身の AdMob アカウントを持っていること**
- **Google と直接契約していること**
- SDK 提供者（当社）を通じた間接的な契約関係は認められません

### 利用者への周知事項

AdServerSDK を利用するパブリッシャーに対して、以下を必ず案内してください。

1. AdMob アカウントを自身で作成・管理すること
2. Google AdMob の利用規約およびポリシーに直接同意すること
3. COPPA（児童オンラインプライバシー保護法）等、適用される法令に準拠すること

---

## 5. アダプターのバージョン報告義務

AdMob のカスタムイベントアダプターは、以下のバージョン情報を Google Mobile Ads SDK に報告する義務があります。

- アダプター自身のバージョン（`adapterVersion`）
- 連携する SDK のバージョン（`adSDKVersion`）

AdServerSDK の `BannerCustomEventAdapter` は `MediationAdapter` プロトコルに準拠しており、これらのメソッドを実装することで要件を満たします。

```swift
static func adapterVersion() -> VersionInfo {
    return VersionInfo(majorVersion: 0, minorVersion: 0, patchVersion: 2)
}

static func adSDKVersion() -> VersionInfo {
    return VersionInfo(majorVersion: 0, minorVersion: 0, patchVersion: 2)
}
```

> リリース時にはバージョン番号を実際の SDK バージョンと一致させてください。

---

## 6. チェックリスト

AdServerSDK を導入・利用するにあたり、以下を確認してください。

- [ ] 自身の AdMob アカウントを作成・管理していること（Google との直接契約）
- [ ] Google AdMob の利用規約およびポリシーに直接同意していること
- [ ] カスタムイベントをエクスチェンジ・オプティマイザー用途に使用していないこと
- [ ] COPPA 等、適用される法令に準拠していること

---

## 参考リンク

| ドキュメント | 関連セクション |
|------------|-------------|
| [AdMob Terms of Service](https://developers.google.com/admob/terms) | 4. パブリッシャーの要件 |
| [AdMob Behavioral Policies](https://support.google.com/admob/answer/2753860) | 全般 |
| [AdMob Policies and Restrictions](https://support.google.com/admob/answer/6128543) | 全般 |
| [Custom event (AdMob Help)](https://support.google.com/admob/answer/3019581) | 2. カスタムイベントの利用 |
| [Set up custom events \| Google for Developers](https://developers.google.com/admob/ios/custom-events/setup) | 2. カスタムイベントの利用、5. バージョン報告義務 |
| [Set up AdMob Mediation \| iOS](https://developers.google.com/admob/ios/mediate) | 1. ウォーターフォールによるフォールバック |
| [Google Mobile Ads SDK Terms of Service](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/terms) | 3. SDK の配布・共有 |
