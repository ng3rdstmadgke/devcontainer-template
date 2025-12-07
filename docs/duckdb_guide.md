
- [DuckDB Docs | DuckDB](https://duckdb.org/docs/stable/)

# PostgreSQL との接続

- [PostgreSQL Extension | DuckDB](https://duckdb.org/docs/stable/core_extensions/postgres)


```bash
duckdb
```


```sql
-- postgres 拡張機能のインストールとロード
INSTALL postgres;
LOAD postgres;


-- PostgreSQL への接続情報をシークレットとして作成
CREATE SECRET (
    TYPE postgres,
    HOST 'devcontainer-template-sample-postgresql',
    PORT 5432,
    DATABASE sample,
    USER 'app',
    PASSWORD 'root1234'
);

-- シークレットを使って(一部設定を上書きして)PostgreSQL データベースを読み込み専用でアタッチ
ATTACH 'dbname= sample' AS postgres_db (TYPE postgres, READ_ONLY);


-- PostgreSQL データベース内のテーブル一覧を確認
SHOW ALL TABLES;
```
