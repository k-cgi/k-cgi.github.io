# クオリティーチェック
インプットのDNAやRNAの質は下流の解析結果に大きな影響を与える。データ量を増やすより質の悪いデータを除去したほうがコスパがいい場合もある。<br>
ここではクオリティーのチェックの仕方と、クオリティの低い配列の除去方法を紹介する。

- [FastQC](#fastqc)
- [Trimmomatic](#trimmomatic)

## FastQC
fastqファイルを入力し、そのファイルに含まれるリードのクオリティや関連する情報の分析・図示を行ってくれるソフト。

## Trimmomatic
fastqcファイルを入力し、指定した条件を基準にリードを取捨選択するソフト。ペアエンドリードを入力した場合、ペアの関係を維持したまま出力してくれる。