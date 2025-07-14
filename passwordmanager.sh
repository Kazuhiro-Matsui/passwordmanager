#!/bin/bash

# 平文のファイル名（一時的に使用）
PASSWORD_FILE="mypasswords.txt"
# 暗号化されたファイル名
ENCRYPTED_FILE="mypasswords.txt.gpg"

echo "パスワードマネージャーへようこそ！"

# このセッションで使うマスターパスワードを入力させる
# -s: 入力を非表示, -p: プロンプト表示
read -sp "マスターパスワードを入力してください: " master_password
echo # 入力後の改行

# "Exit"が入力されるまでループ
while true; do
  echo "次の選択肢から入力してください(Add Password/Get Password/Exit)："
  read choice

  case $choice in
  "Add Password")
    # --- 1. 既存ファイルの復号 ---
    # もし暗号化ファイルが存在すれば、それを復号して平文ファイルを作成する
    if [ -f "$ENCRYPTED_FILE" ]; then
      gpg --quiet --batch --yes --passphrase "$master_password" -o "$PASSWORD_FILE" --decrypt "$ENCRYPTED_FILE"
      # 復号に失敗した場合（パスワード間違いなど）は処理を中断
      if [ $? -ne 0 ]; then
        echo "マスターパスワードが違うか、ファイルの復号に失敗しました。"
        continue
      fi
    fi

    # --- 2. 新しい情報の入力 ---
    echo -n "サービス名を入力してください："
    read service
    echo -n "ユーザー名を入力してください："
    read username
    echo -n "パスワードを入力してください："
    read -s password
    echo

    # --- 3. ファイルへの追記と再暗号化 ---
    # 入力された情報を平文ファイルに追記
    echo "$service:$username:$password" >>"$PASSWORD_FILE"

    # 平文ファイルをGnuPGで暗号化する
    gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "$master_password" -o "$ENCRYPTED_FILE" "$PASSWORD_FILE"

    # セキュリティのため、平文ファイルは削除する
    rm "$PASSWORD_FILE"

    echo "パスワードの追加とファイルの暗号化は成功しました。"
    ;;

  "Get Password")
    # 暗号化ファイルが存在しない場合は、何もないので処理を終了
    if [ ! -f "$ENCRYPTED_FILE" ]; then
      echo "そのサービスは登録されていません。（データがありません）"
      continue
    fi

    echo -n "サービス名を入力してください："
    read search_service

    # --- メモリ上で復号し、内容を検索 ---
    # ファイルに復号せず、コマンドの実行結果（標準出力）として復号内容を取得
    decrypted_content=$(gpg --quiet --batch --yes --passphrase "$master_password" --decrypt "$ENCRYPTED_FILE" 2>/dev/null)

    # 復号に失敗した場合（パスワード間違いなど）は処理を中断
    if [ $? -ne 0 ]; then
      echo "マスターパスワードが違うか、ファイルの復号に失敗しました。"
      continue
    fi

    # 復号した内容の中から、指定されたサービス名を検索
    result=$(echo "$decrypted_content" | grep "^${search_service}:")

    if [ -z "$result" ]; then
      echo "そのサービスは登録されていません。"
    else
      # 検索結果の最初の1行を取得
      first_result=$(echo "$result" | head -n 1)

      # 情報を切り出して表示
      service_name=$(echo "$first_result" | cut -d: -f1)
      user_name=$(echo "$first_result" | cut -d: -f2)
      password_val=$(echo "$first_result" | cut -d: -f3)

      echo "サービス名：$service_name"
      echo "ユーザー名：$user_name"
      echo "パスワード：$password_val"
    fi
    ;;

  "Exit")
    echo "Thank you!"
    # セキュリティのため、変数に格納したパスワードを消去
    unset master_password
    break
    ;;

  *)
    echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
    ;;
  esac
  echo # 各処理の後に改行を入れて見やすくする
done