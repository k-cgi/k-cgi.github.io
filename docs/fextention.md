# ゲノム関連の各種ファイルの扱い方

## .fasta (.fas, .fa)
## .sam, .bam, .bai
## .fastq (.faq, .fq)
## .vcf, .bcf
## .bed

## 圧縮関連
### .zip
### .gz (gzip)

マルチコアで圧縮する場合は、`pigz`コマンドを利用する。なお、マルチコアでの展開はできないが、マルチコアの分ファイルの読み書きが速くなるらしい。<br>
スパコンではpigzがインストールされていない&できないので、ソースファイルをダウンロードしてインストールせずに使う。
```
#圧縮
pigz -p CPU_NUM INPUT #CPU_NUM個のCPUを使って圧縮、元のファイルは無くなる
pigz -c -p CPU_NUM INPUT > OUTPUT.gz #CPU_NUM個のCPUを使って圧縮、元のファイルは残り、OUTPUT.gzが出力される。

#フォルダの場合・圧縮
tar -c INPUT_DIR | pigz -p CPU_NUM > OUTPUT.tar.gz
```
スパコンで実行する場合、shortに10-15コア程度要求すると速くて便利。ただし、shortは1時間しか実行できないので、必ず圧縮・解凍が中断されていないかを確認する。

### .bgzip
タブ区切りの生物学的データフォーマットに対応（特化？）した圧縮形式。あまり使うことはないが、一部のツールで要求される。samtools、tabixなどで圧縮可能。
