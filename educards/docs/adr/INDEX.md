# Architecture Decision Records

系列接頭辞: EDU（tf-mobile-env の見本アプリ EduCards）

| # | タイトル | ステータス | 作成日 | 作成者 | 影響範囲 | 備考 |
|---|---------|-----------|--------|--------|---------|------|
| 001 | BLoC パターンの採用 | 承認済 | 2026-03-15 | Claude AI | Presentation 層全体 | tf-mobile-env state-management skill |
| 002 | Hive によるオフラインファースト設計 | 承認済 | 2026-03-15 | Claude AI | Data 層全体 | tf-mobile-env offline-first rule |
| 003 | SM-2 アルゴリズムの選定 | 承認済 | 2026-03-15 | Claude AI | Study ドメイン | コアビジネスロジック |
| 005 | カード作りの AI を 3 社から選べるようにし、API キーを安全な保管場所に置く | 提案中 | 2026-11-17 | ino5043 / Claude AI | AI でのカード作り・設定・キーの保存 | Claude・ChatGPT・Gemini。flutter_secure_storage |
| 006 | Android 版を GitHub の Releases で配り、案内を GitHub Pages に置く | 提案中 | 2026-11-17 | ino5043 / Claude AI | Android のビルドと署名・CI・案内のページ | 署名の鍵は GitHub の秘密の値。指紋・証明書・出どころの証明を付ける |
