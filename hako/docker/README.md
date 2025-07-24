# Docker関連ファイルの使い方

このフォルダには、Hakoniwa ECU Multiplayプロジェクト用のDockerイメージの構築・管理に関するファイルが含まれています。

## ファイル一覧

### シェルスクリプト (Linux/macOS用)

- **create-image.bash** - Dockerイメージを構築するスクリプト
- **run.bash** - Dockerコンテナを起動するスクリプト
- **pull-image.bash** - Docker Hubからイメージをプルするスクリプト
- **push-image.bash** - Docker Hubにイメージをプッシュするスクリプト
- **attach.bash** - 実行中のコンテナにアタッチするスクリプト

### PowerShellスクリプト (Windows用)

- **create-image.ps1** - Dockerイメージを構築するPowerShellスクリプト
- **push-image.ps1** - Docker HubにイメージをプッシュするPowerShellスクリプト

### 設定ファイル

- **Dockerfile** - Dockerイメージの構築定義ファイル
- **image_name.txt** - Dockerイメージ名の設定ファイル

## 使用方法

### 1. 前準備

プロジェクトのルートディレクトリで実行してください。スクリプトは以下のファイルを参照します：
- `docker/image_name.txt` - イメージ名
- `appendix/latest_version.txt` - バージョンタグ

### 2. Dockerイメージの構築

#### Linux/macOS
```bash
bash docker/create-image.bash
```

#### Windows (PowerShell)
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

```bash
bash docker/attach.bash
```

このスクリプトは実行中のコンテナを検索し、bash shellでアタッチします。

### 5. イメージのプル

Docker Hubから事前構築済みのイメージを取得：

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

**注意**: プッシュするにはDocker Hubへのログインが必要です。

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
