# CLAUDE.md — tf-mobile-env

## Project Overview

モバイルアプリ開発向けの Claude Code 標準環境パッケージ。
tf-standard-env（共通コア）の上に、モバイル固有のエージェント・ルール・スキル・コマンドを追加する。

## Prerequisites

- tf-standard-env >= 2.0.0 がインストール済みであること

## Install

```bash
# 共通コアが未インストールの場合
cd ../10_tf-standard-env && npm run install:env

# モバイルパッケージをインストール（agents / commands / skills を ~/.claude/ に配置）
npm run install:env

# プロジェクトに CLAUDE.md を初期化し、ルールを <project>/.claude/rules/ に配置
npm run install:env -- --project /path/to/mobile-project
```

> **ルールはプロジェクト単位で配布します**（TFSE-009）。
> `npm run install:env` だけでは領域ルールは読み込まれません。対象プロジェクトごとに `--project` を実行してください。
> 旧方式で `~/.claude/rules/` に入った領域ルールは、`npm run install:env` 実行時に自動で削除されます。

## Components

| カテゴリ | 数 | 内容 |
|---------|---|------|
| Agents | 5 | mobile-architect, ui-ux-reviewer, platform-bridge, release-manager, mobile-tdd-guide |
| Rules | 8 | mobile-architecture, responsive-design, offline-first, mobile-security, accessibility, battery-performance, mobile-testing, store-guidelines |
| Skills | 6 | store-submission, deeplink-setup, push-notification, state-management, ci-mobile, app-scaffold |
| Commands | 4 | /mobile-review, /store-check, /device-matrix, /mobile-tdd |

## Key Principles

1. **Clean Architecture**: Presentation → Domain → Data のレイヤー分離
2. **Flutter First**: クロスプラットフォーム開発を最優先
3. **アクセシビリティ**: VoiceOver/TalkBack 対応を標準化
4. **オフラインファースト**: ネットワーク不達時でも基本機能が動作

## Architecture

共通コア（tf-standard-env）から継承:
- SOLID, OOP, DDD 基本概念
- git-workflow, ADR, tradeoffs
- error-handling, security, observability

モバイル固有で追加:
- MVVM / Clean Architecture / BLoC パターン
- レスポンシブ UI 設計
- モバイルセキュリティ（Keychain, Keystore）
- ストアガイドライン準拠
