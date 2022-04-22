# ゲノム関連の各種ファイルの扱い方

## .fasta (.fas, .fa), fai
## .sam, .bam, .bai
## .fastq (.faq, .fq)
## .vcf, .bcf
## .bed
ゲノム上の座標情報をタブ区切りで示したファイル。最低で3行の情報が必要。<br>
```
Chr_1 1 14
Chr_2 30  200
...
CHR_NUM START END
```

## 圧縮関連
### .zip
普通にパソコンを使っていると一番よく見る圧縮形式だと思うが、バイオインフォ系だとあまり見ない。
```
#圧縮
zip OUTPUT.zip INPUT

#フォルダの圧縮
zip -r OUTPUT.zip INPUT_DIR

#展開
unzip INPUT.zip
```
### .gz (gzip)
普通にパソコンを使っているとあまり見ない圧縮形式だが、シーケンスのデータや、バイオインフォ系のツールはよくこの形式で圧縮されている。<br>
一般的な（軽い）ファイルは以下のコマンドであつかう。
```
#圧縮
gzip INPUT #CPU_NUM個のCPUを使って圧縮、元のファイルは無くなる

#フォルダの圧縮
gzip -r INPUT_DIR

#展開・どっちでもOK
gzip -d INPUT.gz
gunzip INPUT.gz
```
大きなファイル（次世代シーケンスの結果など）は、gzipで圧縮すると非常に時間がかかる。その場合はマルチコアで圧縮すると良い。マルチコアで圧縮する場合は、`pigz`コマンドを利用する。なお、マルチコアでの展開はできないが、マルチコアの分ファイルの読み書きが速くなるらしい。<br>
スパコンではpigzがインストールされていない&できないので、ソースファイルをダウンロードしてインストールせずに使う。
```
#圧縮
pigz -p CPU_NUM INPUT #CPU_NUM個のCPUを使って圧縮、元のファイルは無くなる
pigz -c -p CPU_NUM INPUT > OUTPUT.gz #CPU_NUM個のCPUを使って圧縮、元のファイルは残り、OUTPUT.gzが出力される。

#展開
unpigz -p CPU_NUM INPUT.gz

#フォルダの場合・圧縮
tar -c INPUT_DIR | pigz -p CPU_NUM > OUTPUT.tar.gz

#フォルダの場合・解凍
tar -zxf INPUT.tar.gz
```
スパコンで実行する場合、shortに10-15コア程度要求すると速くて便利。ただし、shortは1時間しか実行できないので、必ず圧縮・解凍が中断されていないかを確認する。

### .bgzip
タブ区切りの生物学的データフォーマットに対応（特化？）した圧縮形式。あまり使うことはないが、一部のツールで要求される。samtools、tabixなどで圧縮可能。

### .tar
フォルダを1つのファイルとして「固めた」もの。`-v`オプションを付けると圧縮・展開中のファイル名が表示される。
```
tar -cf OUTPUT.tar INPUT_DIR
tar -xf INPUT.tar
```