#!/bin/bash

# 保存するファイル名
PASSWORD_FILE="passwords.txt"

# 開始メッセージ
echo "パスワードマネージャーへようこそ！"

# 各情報の入力
echo -n "サービス名を入力してください："
read service_name

echo -n "ユーザー名を入力してください："
read user_name

# パスワードを画面に表示せずに入力させる
echo -n "パスワードを入力してください："
read -s password
echo # 入力後の改行

# ファイルへの追記
# "サービス名:ユーザー名:パスワード" の形式でファイルに保存します。
echo "$service_name:$user_name:$password" >> "$PASSWORD_FILE"

# 完了メッセージ
echo "Thank you!"
echo "情報が $PASSWORD_FILE に保存されました。"