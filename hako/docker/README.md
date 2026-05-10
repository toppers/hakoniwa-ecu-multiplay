# Docker関連ファイルの使い方

このフォルダには、Hakoniwa ECU Multiplayプロジェクト用のDockerイメージの構築・管理に関するファイルが含まれています。

## 2層構成について

Hakoniwa ECU Multiplay は以下の 2 層のイメージに分かれています：

- **Core 層 (`Dockerfile.base`)** — 箱庭コア環境（athrill ツールチェイン、RH850 シミュレータ、hakoniwa-core-cpp-client、cfg、AUTOSAR スキーマ）。変更頻度が低く、安定しています。
  - イメージ名: `ghcr.io/toppers/hakoniwa-ecu-multiplay`

- **Asset 層 (`Dockerfile`)** — サンプルアプリケーション（atk2-sc1、a-comstack、a-rtegen のビルド & proxy_config）。Core 層から `FROM` して構築。
  - イメージ名: `ghcr.io/toppers/hakoniwa-ecu-multiplay-demo`

両層のタグは `docker/.env` の `IMAGE_TAG` で統一管理されます

この分離により、アセットの差し替え時にコア部分の再ビルドが不要になり、ビルド時間が大幅に短縮されます。

## ファイル一覧

### シェルスクリプト (Linux/macOS用)

- **create-image.bash** — イメージをビルド
  - `bash docker/create-image.bash` — base と asset を順番にビルド（デフォルト）
  - `bash docker/create-image.bash base` — base イメージのみ
- **push-image.bash** — イメージを GHCR に push
  - `bash docker/push-image.bash` — base と asset を push（デフォルト）
  - `bash docker/push-image.bash base` — base のみ
- **pull-image.bash** — イメージを GHCR から pull
  - `bash docker/pull-image.bash` — base と asset を pull（デフォルト）
  - `bash docker/pull-image.bash base` — base のみ
- **rmi.bash** — ローカルイメージを削除
  - `bash docker/rmi.bash` — base と asset を削除（デフォルト）
  - `bash docker/rmi.bash base` — base のみ
- **run.bash** — Asset コンテナを起動
- **attach.bash** — 実行中のコンテナにアタッチ

### Dockerfile

- **Dockerfile.base** — Core イメージの定義
- **Dockerfile** — Asset イメージの定義（Dockerfile.base から `FROM`）

## 使用方法

### 1. 前準備

プロジェクトの `hako/` ディレクトリで実行してください。スクリプトは `docker/.env` ファイルを参照します：
- `IMAGE_REGISTRY` — イメージレジストリ（デフォルト: `ghcr.io/toppers/`）
- `IMAGE_NAME` — イメージ名の基本部分（デフォルト: `hakoniwa-ecu-multiplay`）
- `IMAGE_ASSET_SUFFIX` — Asset イメージ名の suffix（デフォルト: `-demo`）
- `IMAGE_TAG` — Core と Asset 両イメージのタグ（デフォルト: `v1.0.0`）

### 2. Dockerイメージの構築

**デフォルト:** git タグを作成すると GitHub Actions が自動的にビルド・プッシュします。以下のローカル実行は開発時のみ必要です。

#### ローカルでのビルド (Linux/macOS)

```bash
cd hako
# デフォルト: base と asset を順番にビルド
bash docker/create-image.bash

# または明示的に指定
bash docker/create-image.bash base    # base のみ
```

このスクリプトは自動的に以下を実行します：
- BuildKit を有効化
- プラットフォームを `linux/amd64` に設定（Intel/Apple Silicon 対応）

Asset ビルドでは Base イメージをローカルから `FROM` します。`asset` 引数でビルド時に Base イメージが存在しない場合、ビルドに失敗します。

**macOS (Apple Silicon) での注意:**
Intel ベースの環境と互換性を保つため、`linux/amd64` プラットフォームでビルドされます。

### 3. Dockerコンテナの起動

Asset コンテナを起動します（Core イメージをベースにします）。

```bash
cd hako
bash docker/run.bash
```

このスクリプトは：
- OS タイプを自動検出
- 必要に応じて Docker サービスを起動
- 適切なマウントオプションでコンテナを起動

### 4. 実行中のコンテナにアタッチ

#### 推奨: devContainer を使用

VSCode で `.devcontainer/devcontainer.json` が自動的に検出されます。以下のいずれかの方法でアタッチできます：

1. VSCode のコマンドパレット（Cmd/Ctrl + Shift + P）から `Dev Containers: Reopen in Container` を実行
2. 左下の `><` アイコンをクリックして `Reopen in Container` を選択

#### 代替方法: スクリプトを使用

```bash
cd hako
bash docker/attach.bash
```

このスクリプトは実行中のコンテナを検索し、bash shell でアタッチします。

### 5. イメージのプル

```bash
cd hako
# デフォルト: base と asset を pull
bash docker/pull-image.bash

# または明示的に指定
bash docker/pull-image.bash base    # base のみ
```

### 6. イメージのプッシュ

```bash
cd hako
# デフォルト: base と asset を push
bash docker/push-image.bash

# または明示的に指定
bash docker/push-image.bash base    # base のみ
```

**注意**: プッシュするには GHCR へのログインが必要です。

```bash
docker login ghcr.io
```

ログイン時には GitHub の Personal Access Token (PAT) を使用してください。
詳細は [GitHub Container Registry ドキュメント](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) を参照してください。

### 7. ローカルイメージの削除

ローカルマシンに保存されているイメージを削除する場合：

```bash
cd hako
# デフォルト: base と asset を削除
bash docker/rmi.bash

# または明示的に指定
bash docker/rmi.bash base    # base のみ
```

このスクリプトは：

- `docker rmi` コマンドでイメージを削除
- イメージが見つからない場合は警告を表示（エラーで終了しない）
- Asset イメージを先に削除してから Base イメージを削除

**注意**: Asset イメージが Base イメージに依存しているため、先に Asset を削除してから Base を削除することが重要です。

### 8. 自動ビルド・プッシュ (GitHub Actions)

**運用方針：**

- 各ブランチへの push では Core と Asset 両方のコンテナイメージをビルド（GitHub Actions）
- git タグ（`v*.*.*`）作成時のみ GHCR にプッシュしてリリース
- PR は `main` 向けの場合のみビルド成功を確認
- `docker/.env` の `BASE_VERSION` と `ASSET_VERSION` が version の source of truth

**リリース手順：**

1. タグを更新

```bash
cd hako
# docker/.env の IMAGE_TAG を更新
vim docker/.env  # IMAGE_TAG を v1.4.0 に変更
git add docker/.env
git commit -m "Bump version to v1.4.0"
git push origin main
```

2. タグを作成・プッシュ（リポジトリメンテナーのみ）

```bash
git tag v1.4.0
git push origin v1.4.0
```

3. GitHub Actions が自動実行

- `ghcr.io/toppers/hakoniwa-ecu-multiplay:v1.4.0` (Core)
- `ghcr.io/toppers/hakoniwa-ecu-multiplay-demo:v1.4.0` (Asset)

が作成・プッシュされます。

**注意：**

- 全ブランチと PR で GitHub Actions によるビルドが自動実行されます
- GHCR へのプッシュは `v*.*.*` タグ作成時のみ

## Dockerイメージについて

- **Base**: `ros:foxy-ros-base-focal`
- **含まれるツール**:
  - ROS2 Foxy
  - CMake 3.31.2
  - athrill-gcc-v850e2m
  - athrill-target-rh850f1x （hakoniwa-core-cpp-client を含む）
  - athrill-device
  - cfg ツール
  - AUTOSAR XML スキーマ
  - 各種開発ツール (git, build-essential, vim等)
  - Java OpenJDK 8

## トラブルシューティング

### Dockerサービスが起動しない場合
```bash
sudo service docker start
```

### コンテナが見つからない場合
```bash
docker ps -a  # 全コンテナを確認
```

### イメージが見つからない場合
```bash
docker images  # ローカルイメージを確認
```

### Asset イメージのビルドが失敗する場合

Core イメージが存在するか確認：

```bash
docker images | grep hakoniwa-ecu-multiplay
```

Core イメージが無い場合は、まず `bash docker/create-image.bash base` を実行してください。

## コンテナ内のフォルダ構成

Dockerイメージを構築すると、以下のようなフォルダ構成が作成されます：

### システムディレクトリ
```
/usr/local/
├── cmake/                    # CMake インストール先
└── athrill-gcc/             # athrill-gcc-v850e2m ツールチェイン

/home/toppers/               # TOPPERS_HOME
├── athrill-target-rh850f1x/ # メインのAthrillターゲット
│   ├── athrill/             # Athrill2本体
│   ├── athrill-device/      # Athrillデバイス
│   │   └── device/hakotime/ # hakotime関連
│   └── hakoniwa-ros2pdu/    # ROS2 PDU関連
│       └── workspace/       # ROS2ワークスペース
└── schema/                  # AUTOSAR XMLスキーマとcfgツール
    └── cfg/                 # cfgツール
```

### ユーザーワークスペース (Asset層で追加)
```
/home/hako/workspace/        # HAKO_HOME/workspace (メインワークスペース)
├── atk2-sc1/               # AUTOSAR Toolkit 2 SC1
│   └── cfg/cfg/            # AUTOSAR XMLスキーマファイル
├── a-comstack/             # COMスタック
│   └── can/target/hsbrh850f1k_gcc/sample/
│       └── proxy_config.json  # CANプロキシ設定
├── a-rtegen/               # RTEジェネレータ
│   ├── bin/schema/         # XMLスキーマ
│   └── sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/
│       ├── ecu1/           # ECU1サンプル
│       │   └── proxy_config_rte_ecu1.json
│       └── ecu2/           # ECU2サンプル
│           └── proxy_config_rte_ecu2.json
└── (各種ビルド成果物)
```

### 環境変数で定義されるワークスペース
```
HAKO_WS_ROS    = /home/toppers/athrill-target-rh850f1x/hakoniwa-ros2pdu/workspace
HAKO_WS_ECU1   = /home/hako/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1
HAKO_WS_ECU2   = /home/hako/workspace/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2
HAKO_WS_CAN    = /home/hako/workspace/a-comstack/can/target/hsbrh850f1k_gcc/sample
```

### 主要なツールのPATH
- `/usr/local/athrill-gcc/bin/` - athrill-gccコンパイラ
- `/home/toppers/athrill-target-rh850f1x/athrill/bin/linux` - Athrillシミュレータ
- 各種hakoniwa関連ツール

## ファイル構成の詳細

- スクリプトは全て実行可能権限が必要です
- Core と Asset のイメージ名とタグは設定ファイルから動的に読み込まれます
- Linux/macOS用とWindows用で異なるスクリプトが用意されています
