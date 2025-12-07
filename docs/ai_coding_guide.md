# ■ GitHub CLI の ログイン

```bash
gh auth login
# ? Where do you use GitHub? GitHub.com
# ? What is your preferred protocol for Git operations on this host? HTTPS
# ? Authenticate Git with your GitHub credentials? Yes
# ? How would you like to authenticate GitHub CLI? Login with a web browser
# 
# ! First copy your one-time code: XXXX-XXXX
# Press Enter to open https://github.com/login/device in your browser... 
# ✓ Authentication complete.
# - gh config set -h github.com git_protocol https
# ✓ Configured git protocol
# ! Authentication credentials saved in plain text
# ✓ Logged in as xxxxxxxxxxxxx
```

---


# ■ MCPサーバー
## GitHub MCP

※ github cli (gh コマンド) がインストールされているのであまり必要ないが、参考までに

### パーソナルアクセストークンを作成
[Fine-grained personal access tokens | GitHub ](https://github.com/settings/personal-access-tokens) でトークンを作成する


### MCPサーバーの登録

https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md

```bash
GITHUB_PAT=github_pat_xxxxxxxxxxxxxxxxxxxxxx
claude mcp add \
  --transport http \
  github \
  --scope user \
  https://api.githubcopilot.com/mcp/ \
  -H "Authorization: Bearer $GITHUB_PAT"
```

## Context7 (ライブラリドキュメント検索)

- [upstash/context7 | GitHub](https://github.com/upstash/context7)

Context7 MCPは、最新のバージョン別ドキュメントやコードサンプルを直接ソースから取得し、プロンプトに直接組み込む機能を提供します。

### APIキーの取得

https://context7.com/dashboard でアカウント登録し、APIキーを取得する


```bash
CONTEXT7_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
claude mcp add \
  --transport http \
  --scope user \
  context7 \
  https://mcp.context7.com/mcp \
  --header "CONTEXT7_API_KEY: $CONTEXT7_API_KEY"
```

## Serena (シンボルベース編集)

- [oraios/serena | GitHub](https://github.com/oraios/serena)

Serenaは、LLM/コーディングエージェントにIDEのような機能を提供するツールと考えることができます。 このツールを使用することで、エージェントはコード全体を読み込んだり、grepのような検索を行ったり、基本的な文字列置換を実行したりする必要がなくなり、適切なコード部分の特定や編集が可能になります。


```bash
claude mcp add \
  --scope project \
  --transport stdio \
  serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "."
```

## Kiri (コードベース検索)

- [CAPHTECK/kiri | GitHub](https://github.com/CAPHTECH/kiri)

Gitリポジトリからインテリジェントなコードコンテキストを抽出するMCPサーバーです。コードベースをDuckDBにインデックス化し、LLM向けの意味的検索ツールを提供します。

```bash
claude mcp add \
  --scope project \
  --transport stdio \
  kiri -- npx -y kiri-mcp-server@latest --repo . --db .kiri/index.duckdb --watch
```

## next-devtools-mcp (Next.jsの開発支援)

- [vercel/next-devtools-mcp | GitHub](https://github.com/vercel/next-devtools-mcp)


- Next.jsの公式ドキュメントおよびナレッジベースを検索・取得
- Playwrightブラウザ自動化ツールを使用して、Webアプリケーションのテストを自動化
- すべての実行中のNext.js開発サーバーを発見し、ログやエラー情報にアクセス

```bash
claude mcp add \
  --transport stdio \
  --scope project \
  next-devtools -- npx -y next-devtools-mcp@latest
```

## chrome-devtools-mcp (Chromeの操作支援)

- [ChromeDevTools/chrome-devtools-mcp | GitHub](https://github.com/ChromeDevTools/chrome-devtools-mcp)

chrome-devtools-mcp を使用すると、Gemini、Claude、Cursor、Copilot などのコーディングエージェントが ライブ状態の Chrome ブラウザを制御・検査できるようになります。  

mcpサーバーの起動時に指定できるオプションはこちらを参照: https://github.com/ChromeDevTools/chrome-devtools-mcp?tab=readme-ov-file#configuration


```bash
# --no-sandbox: コンテナではnamespace, setuidなどが制限されているため、サンドボックス機能を無効化
# --disable-gpu: Dockerコンテナ内ではGPUが利用できない場合が多いため、GPUアクセラレーションを無効化
# --disable-dev-shm-usage: Docker の /dev/shm は デフォルトで 64MBであるため、共有メモリ(/dev/shm)の使用を無効化して、メモリ不足によるクラッシュを防止
claude mcp add \
  --transport stdio \
  --scope project \
  chrome-devtools-tmp -- \
    npx -y chrome-devtools-mcp@latest \
      --headless=true \
      --chromeArg=--no-sandbox \
      --chromeArg=--disable-gpu \
      --chromeArg=--disable-dev-shm-usage
```

## Playwrite (ブラウザ操作支援)

Playwrightを使用してブラウザ操作を可能にするModel Context Protocol（MCP）サーバーです。  

- [microsoft/playwright-mcp | GitHub](https://github.com/microsoft/playwright-mcp)

```bash
claude mcp add \
  --transport stdio \
  --scope project \
  playwright -- \
    npx @playwright/mcp@latest  \
      --browser=chrome \
      --headless \
      --isolated \
      --no-sandbox
```

## DuckDuckGo

https://hub.docker.com/r/mcp/duckduckgo

```bash
claude mcp add \
  --transport stdio \
  --scope project \
  duckduckgo -- docker run -i --rm mcp/duckduckgo 
```


## AWS Documentation

https://hub.docker.com/r/mcp/aws-documentation

```bash
claude mcp add \
  --transport stdio \
  --scope project \
  aws-documentation -- docker run -i --rm mcp/aws-documentation
```

## AWS Terraform

https://hub.docker.com/r/mcp/aws-terraform

```bash
claude mcp add \
  --transport stdio \
  --scope project \
  aws-terraform -- docker run -i --rm mcp/aws-terraform
```

---


# ■ Claude Code GitHub Actions

- https://code.claude.com/docs/en/github-actions
- https://github.com/anthropics/claude-code-action

GitHub ActionsでClaude CodeがPRレビューや開発を行ってくれる機能

コマンドラインで claude codeを開き `/install-github-app` を実行

GitHub の Applications に Claude が追加されます。

https://github.com/settings/installations


### 使い方

IssueまたはPRのコメント内で：

```
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
```