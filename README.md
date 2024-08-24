# proxy-sbh-nginx

### 概要説明
Tokyo OSS Party!!の作品、[Sports Barrier-free Hub](https://protopedia.net/prototype/3746)のバックエンド。


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
docker-compose up
```


### 3. 動作確認
#### イベント登録
```
curl -XPOST -H "Content-Type: application/json"  http://localhost/sportsevent/v1/api/event -d'{"title":"ボッチャ体験会Part2","timeFrom":"2023-05-21 12:00","timeTo":"2023-05-21 15:00","ownerId":"xxxxx_owner_xxxx_id", "comment":"どなたでも参加いただけます","eventType":1, "sportEventIdList":[1,2]}'
```
#### イベント情報取得のリクエスト
```
curl -XGET http://localhost/sportsevent/v1/api/event?eventId=2
```

#### 備品予約
```
curl -XPOST -H "Content-Type: application/json"  http://localhost/equipment-rental/v1/api/equipment-reserve -d'{"equipmentList":[{"equipmentId":1,"equipmentN":3}],"eventId":1,"renterId":"UPxxxxxxxxxxxxxx01","startDate":"2023-03-25 00:00:00","endDate":"2023-03-26 00:00:00","usageDate":"2023-03-26 00:00:00","comment":"何かコメント"}'
```

#### DBへの記録状態の確認
以下でIMAGE名からmysqlに該当するものを探し、対象のCONTAINER IDを取得する

```
docker ps
```
mysqlのコンテナに接続し、テーブル一覧を取得する
```
docker exec -it mysqlのCONTAINER_ID /bin/bash
mysql -h db -P 3306 -u root -p
use spohubdb;
show tables;
```
イベントの登録状態を確認する
```
select * from Events;
```

