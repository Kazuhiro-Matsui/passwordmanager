#!/bin/bash

# パスワードを保存するファイル名
PASSWORD_FILE="mypasswords.txt"

# スクリプト開始時にファイルがなければ作成する
touch "$PASSWORD_FILE"

echo "パスワードマネージャーへようこそ！"

# "Exit"が入力されるまでループを続ける
while true
do
  echo "次の選択肢から入力してください(Add Password/Get Password/Exit)："
  read choice

  # 入力された選択肢によって処理を分岐
  case $choice in
    "Add Password")
      # パスワードを追加する処理
      echo -n "サービス名を入力してください："
      read service
      echo -n "ユーザー名を入力してください："
      read username
      echo -n "パスワードを入力してください："
      read -s password # -s オプションで入力内容を非表示にする
      echo # 入力後に改行

      # ファイルに "サービス名:ユーザー名:パスワード" の形式で追記
      echo "$service:$username:$password" >> "$PASSWORD_FILE"
      echo "パスワードの追加は成功しました。"
      ;;

    "Get Password")
      # パスワードを取得する処理
      echo -n "サービス名を入力してください："
      read search_service

      # grepコマンドで、入力されたサービス名で始まる行を検索する
      # ^ は行の先頭を意味し、部分一致を防ぎます (例: "test" で "mytest" がヒットしないようにする)
      result=$(grep "^${search_service}:" "$PASSWORD_FILE")

      if [ -z "$result" ]; then
        # 検索結果が空だった場合
        echo "そのサービスは登録されていません。"
      else
        # 検索にヒットした場合、最初の1行を取得して表示する
        # head -n 1 は、同じサービス名が複数登録されていた場合に最初のものだけを表示します
        first_result=$(echo "$result" | head -n 1)

        # ":" を区切り文字として、各情報を切り出して変数に格納
        service_name=$(echo "$first_result" | cut -d: -f1)
        user_name=$(echo "$first_result" | cut -d: -f2)
        password_val=$(echo "$first_result" | cut -d: -f3)

        echo "サービス名：$service_name"
        echo "ユーザー名：$user_name"
        echo "パスワード：$password_val"
      fi
      ;;

    "Exit")
      # プログラムを終了する処理
      echo "Thank you!"
      break # whileループを抜ける
      ;;

    *)
      # 上記のいずれでもなかった場合の処理
      echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
      ;;
  esac
  # 各処理の後に改行を入れて見やすくする
  echo
done