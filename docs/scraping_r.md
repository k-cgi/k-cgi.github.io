# RパッケージRvestを利用したwebスクレイピング
Rでwebスクレイポングをするならrvestというライブラリ（パッケージ）が便利。htmlファイルから特定の属性を持つ要素を抽出したりできる。これを利用して、データベースに登録されているサンプルの情報や遺伝子の配列などをまとめて取ってくることができる。なお、webスクレイピングをする際は、アクセス先のサーバーに負荷をかけないように注意。<br>
tidyverse、stringrなどのライブラリも併用すると便利（ここでは扱わない）。なお、rvestのみだとjavascriptや読み込みにスクロールが必要なサイトをスクレイピングするのは難しい。その場合はselenium等を利用する（RSeleniumを併用する）。
## rvestのインストール
他のライブラリと同様に`install.packages("rvest")`でインストール可能。
## 基本の関数
### read_html
### html_text
### html_nodes
### html_attr
### html_table
