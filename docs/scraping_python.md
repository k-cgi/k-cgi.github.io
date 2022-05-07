# Pythonでwebスクレイピングピング
Pythonにもともと含まれているurllibというパッケージを使えば、簡単なwebスクレイピングができる。
## 使いかた
インストール等は不要。`import urllib`で使用可能になる。
## 主な関数
###urllib.request.urlopen('URL')
URLに含まれるコード等の情報を取得する。`.read()`でソースコードを取得。日本語のページの場合、`.read().decode()`で日本語に対応した状態でソースコードを取得できる。
