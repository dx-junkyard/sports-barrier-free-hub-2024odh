# proxy-sbh-nginx

### 概要説明
[都知事杯オープンデータ・ハッカソン](https://odh-tokyo2024.code4japan.org/)の「スポコミ」チームの作品です。


スポーツ実施率向上の要となるコミュニティ形成を促進します。


### 1. ビルドとサービス起動に必要な各種ファイル生成
```
sh build.sh
```
ここでは、以下を行います。
- ビルド用のdocker image生成
- jarファイル生成
- 生成したjarを使ったサービスのimageの生成
- nginx-proxy、MySQL、前述の各サービスを起動するdocker-compose.yamlの生成

### 2. proxy, 各サービス、DBの起動
```
docker compose up
```


### 3. 動作確認
#### 使用例:ログイン
```
curl -k -XGET -H "Content-Type: application/json" 'https://localhost/community/v1/api/users/login' -d'{"userId":"user-a","password":"pass"}'
```
