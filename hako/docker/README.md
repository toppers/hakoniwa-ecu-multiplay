# Docker関連ファイルの使い方

このフォルダには、Hakoniwa ECU Multiplayプロジェクト用のDockerイメージの構築・管理に関するファイルが含まれています。

## ファイル一覧

### シェルスクリプト (Linux/macOS用)

- **create-image.bash** - Dockerイメージを構築するスクリプト
- **run.bash** - Dockerコンテナを起動するスクリプト
- **pull-image.bash** - GitHub Container Registry (GHCR) からイメージをプルするスクリプト
- **push-image.bash** - GHCR にイメージをプッシュするスクリプト
- **attach.bash** - 実行中のコンテナにアタッチするスクリプト

### PowerShellスクリプト (Windows用)

- **create-image.ps1** - Dockerイメージを構築するPowerShellスクリプト
- **push-image.ps1** - DockerイメージをプッシュするPowerShellスクリプト（現在の実装は Linux/macOS 用スクリプトと異なり、GHCR 向けログインや `appendix/latest_version.txt` を使ったバージョンタグ付けを前提としていません）

### 設定ファイル

- **Dockerfile** - Dockerイメージの構築定義ファイル

## 使用方法

### 1. 前準備

プロジェクトのルートディレクトリで実行してください。スクリプトは以下のファイルを参照します：
- `appendix/image_name.txt` - イメージ名
- `appendix/latest_version.txt` - バージョンタグ

### 2. Dockerイメージの構築

**デフォルト:** git タグを作成すると GitHub Actions が自動的にビルド・プッシュします。以下のローカル実行は開発時のみ必要です。

#### ローカルでのビルド (Linux/macOS)

```bash
bash docker/create-image.bash
```

このスクリプトは自動的に以下を実行します：

- BuildKit を有効化（高速かつ効率的なビルド）
- プラットフォームを `linux/amd64` に設定（Intel/Apple Silicon 対応）

**macOS (Apple Silicon) での注意:**
Intel ベースの環境と互換性を保つため、`linux/amd64` プラットフォームでビルドされます。

#### ローカルでのビルド (Windows PowerShell)

```powershell
.\docker\create-image.ps1
```

### 3. Dockerコンテナの起動

```bash
bash docker/run.bash
```

このスクリプトは：
- OSタイプを自動検出
- 必要に応じてDockerサービスを起動
- 適切なマウントオプションでコンテナを起動

### 4. 実行中のコンテナにアタッチ

#### 推奨: devContainer を使用

VSCode で `.devcontainer/devcontainer.json` が自動的に検出されます。以下のいずれかの方法でアタッチできます：

1. VSCode のコマンドパレット（Cmd/Ctrl + Shift + P）から `Dev Containers: Reopen in Container` を実行
2. 左下の `><` アイコンをクリックして `Reopen in Container` を選択

#### 代替方法: スクリプトを使用

```bash
bash docker/attach.bash
```

このスクリプトは実行中のコンテナを検索し、bash shell でアタッチします。

### 5. イメージのプル

GitHub Container Registry (GHCR) から事前構築済みのイメージを取得：

```bash
bash docker/pull-image.bash
```

### 6. イメージのプッシュ

#### Linux/macOS
```bash
bash docker/push-image.bash
```

#### Windows (PowerShell)
```powershell
.\docker\push-image.ps1
```

**注意**: プッシュするには GHCR へのログインが必要です。

```bash
docker login ghcr.io
```

ログイン時には GitHub の Personal Access Token (PAT) を使用してください。
詳細は [GitHub Container Registry ドキュメント](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) を参照してください。

### 7. 自動ビルド・プッシュ (GitHub Actions)

**運用方針：**

- 各ブランチへの push ではコンテナイメージをビルド（GitHub Actions）
- git タグ（`v*.*.*`）作成時のみ GHCR にプッシュしてリリース
- PR は `main` 向けの場合のみビルド成功を確認
- `hako/appendix/latest_version.txt` が version の source of truth

**リリース手順：**

1. バージョンを更新

```bash
cd hako
echo "v1.3.0" > appendix/latest_version.txt
git add appendix/latest_version.txt
git commit -m "Bump version to v1.3.0"
git push origin main
```

1. タグを作成・プッシュ（リポジトリメンテナーのみ）

```bash
git tag v1.3.0
git push origin v1.3.0
```

1. GitHub Actions が自動実行

`ghcr.io/toppers/hakoniwa-ecu-multiplay:v1.3.0` が作成・プッシュされます

**注意：**

- 全ブランチと PR で GitHub Actions によるビルドが自動実行されます
- GHCR へのプッシュは `v*.*.*` タグ作成時のみ
- タグ作成前に `latest_version.txt` と一致していることを確認してください

## Dockerイメージについて

- **ベースイメージ**: `ros:foxy`
- **含まれるツール**:
  - ROS2 Foxy
  - CMake 3.17.0
  - athrill-gcc-v850e2m
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

## コンテナ内のフォルダ構成

Dockerイメージを構築すると、以下のようなフォルダ構成が作成されます：

### システムディレクトリ
```
/usr/local/
├── cmake/                    # CMake 3.17.0インストール先
└── athrill-gcc/             # athrill-gcc-v850e2mツールチェイン

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

### ユーザーワークスペース
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
- イメージ名とタグは設定ファイルから動的に読み込まれます
- Linux/macOS用とWindows用で異なるスクリプトが用意されています
