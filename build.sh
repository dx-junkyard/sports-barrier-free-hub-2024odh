

clean_up()
{
TARGET=${1}
if [ -e ./${TARGET}.jar ]; then
rm ./${TARGET}
fi

if [ -d ./${TARGET} ]; then
rm -rf ./${TARGET}
fi
}

#
# step 1. gitからDB構築スクリプトを取得する
#
echo "step1"
TARGET=sports-barrier-free-mysql
clean_up ${TARGET}
git clone https://github.com/dx-junkyard/${TARGET}.git

#
# step 2. Dockerファイルの生成
#  - Docker-build.xxx : jarファイル生成用のbuild環境
#  - Docker-run.xxx : docker-composeで起動される各サービスimage生成用のDockerfile
#
echo "step2: create dockerfile"
cat service_list.txt | while read TARGET
do
echo "TARGET=${TARGET}"
sed "s/GIT-REPOSITORY-NAME-XXX/${TARGET}/g" ./templates/Dockerfile-build.template > Docker-build.${TARGET}
sed "s/GIT-REPOSITORY-NAME-XXX/${TARGET}/g" ./templates/Dockerfile-run.template > Docker-run.${TARGET}
done

#
# step 3. 2で生成したDocker-build.xxxによりコンテナを起動してjarファイル生成
#
echo "step3: create build-docker-image"
cat service_list.txt | while read TARGET
do
docker build --no-cache -t ${TARGET}-build -f Docker-build.${TARGET} .
done

#
# step 4. imageを起動してjarファイルを取り出す
#
echo "step4: build"
cat service_list.txt | while read TARGET
do
echo "---------- ${TARGET} ----------"
docker run --rm -v $(pwd):/output -p 8080:8080 ${TARGET}-build
done

#
# step 5. 各サービスのコンテナimageを生成
#
echo "step5: create run-docker-image"
cat service_list.txt | while read TARGET
do
echo "---------- ${TARGET} ----------"
docker build --no-cache -t ${TARGET} -f Docker-run.${TARGET} .
done

#
# step 6. nginx設定ファイル、docker-compose.yaml生成、各サービスのimage生成
#
echo "step6: create docker-compose.yaml"
N=80
NGINX_CONFIG_DIR=./nginx.config
NEW_NGINX_CONFIG=${NGINX_CONFIG_DIR}/default.conf
if [ -d ${NGINX_CONFIG_DIR} ]; then
  rm -rf ${NGINX_CONFIG_DIR}
fi
mkdir ${NGINX_CONFIG_DIR}

cp templates/DockerComposeBaseTemplate.yaml ./docker-compose.yaml
cp templates/nginx.base.template ${NEW_NGINX_CONFIG}

cat service_list.txt | while read TARGET
do
PORT_NO=$((8000+N))
APP_NAME=`echo "${TARGET}" | sed 's/-spring/-app/g'`
VIRTUAL_PATH=`echo "${TARGET}" | sed 's/-spring//g' | sed 's/api-//g'`
sed "s/GIT-REPOSITORY-NAME-XXX/${TARGET}/g" ./templates/DockerComposeServiceTemplate.yaml | sed "s/GIT-REPOSITORY-NAME-APP/${APP_NAME}/g" | sed "s/PORT-NO-XXX/${PORT_NO}/g" >> ./docker-compose.yaml
sed "s/GIT-REPOSITORY-NAME-APP/${APP_NAME}/g" ./templates/nginx.services.template | sed "s/VIRTUAL-PATH-XXX/${VIRTUAL_PATH}/g" >> ${NEW_NGINX_CONFIG}
echo "---------- ${TARGET} ----------"
docker build --no-cache -t ${TARGET} -f Docker-run.${TARGET} .
N=$((N+1))
done
# 設定ファイルの最後のカッコを追記
echo "}" >> ${NEW_NGINX_CONFIG}

#
# step 7. テスト用に自己署名のSSL証明書を生成
#    本番環境では、L103,L104のdockerコマンドをコメントアウトし、
#    build.shを実行後作成される./certs下にそれぞれ以下のファイル名で証明書と秘密鍵を置く
#       証明書：cert.pem
#       秘密鍵：key.pem
#
cp ./templates/Dockerfile-localhost-ssl  .
clean_up certs
mkdir ./certs
docker build --no-cache -t localhost-ssl -f Dockerfile-localhost-ssl  .
docker run --rm -v $(pwd)/certs:/certs localhost-ssl

