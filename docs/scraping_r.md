# RパッケージRvestを利用したwebスクレイピング
Rでwebスクレイポングをするならrvestというライブラリ（パッケージ）が便利。htmlファイルから特定の属性を持つ要素を抽出したりできる。これを利用して、データベースに登録されているサンプルの情報や遺伝子の配列などをまとめて取ってくることができる。なお、webスクレイピングをする際は、アクセス先のサーバーに負荷をかけないように注意。ループ処理をする場合はsys.sleepで2秒程度休ませる。<br>
tidyverse、stringrなどのライブラリも併用すると便利（ここでは扱わない）。なお、rvestのみだとjavascriptや読み込みにスクロールが必要なサイトをスクレイピングするのは難しい。その場合はselenium等を利用する（RSeleniumを併用する）。<br>
今回は例として、ラン科の交配情報のデータベース（ https://apps.rhs.org.uk/horticulturaldatabase/orchidregister/orchidregister.asp ）にアクセスして、Cymbidium属同士の交配種の一覧を取得する。
## スクレイピングの基本
まずはデータを抽出したいサイトの構造を調べる。ブラウザの開発者ツール（chromeならF12キーで出てくる）等を用いると、欲しいデータがどこに置いてあるかが分かりやすくて良い。また、抽出したい情報が複数ページにまたがっていたり、検索語句によって表示されるページの構造が変わる場合があるので、いろいろな条件で実験してページの構造がどのように変化するのかを見てみる。
## rvestのインストール
他のライブラリと同様に`install.packages("rvest")`でインストール可能。
## 基本の関数
### read_html
`read_html("URL")`の形で使用。指定したURLからhtmlファイルを取得するコマンド。
### html_table
`html_table("HTML")`の形で使用。指定したhtmlファイルから表を抜き出す。複数ある場合は、すべての表を含んだリストが返ってくる。
### html_nodes
`html_nodes("TAG")`の形で使用。指定したタグの付いたノードを取得する。例えば`html_nodes("h2")`でh2をとってくる。
### html_text
主に`html_text("NODE")`等の形で使用。指定したノード等からテキストを取得するコマンド。例えば`html_nodes("h2") %>% html_text()`でh2ノードに含まれるテキストを抽出する。
### html_attr
`html_attr("NODE")`等の形で使用。指定したノード等からテキストを取得するコマンド。例えば`html_nodes("a") %>% html_attr("href")`でaに含まれるhrefを取り出せる。

## 例
[ラン科の交配情報のデータベース](https://apps.rhs.org.uk/horticulturaldatabase/orchidregister/orchidregister.asp)にアクセスして、Cymbidium属同士の交配種の一覧を取得する。<br>
[参考コード](https://github.com/k-cgi/k-cgi.github.io/blob/main/codes/rvest_test.R)
