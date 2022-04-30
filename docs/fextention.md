# ゲノム・遺伝子関連の各種ファイルの扱い方

## .fasta (.fas, .fa), fai
fastaファイルはDNAやアミノ酸の配列を扱う際の基本的な形式。サンプル名と配列情報のみからなる。>と改行に挟まれた最短の文字列がサンプル名、サンプル名の後の改行と改行+>で挟まれた最短の文字列が配列になる。サンプル名に記号が使用可能だが、解析に使うソフトとの兼ね合いで英数字と-（ハイフン）と\_（アンダーバー）のみにした方が良い。faiファイルはfastaファイルのインデックスファイルで、配列の名称や長さの情報のみを持つ。特に大きなfastaファイルを扱う際に便利で、ゲノム解析関連のソフトで要求されることがある。<br>
```
>Sample_1_samplename
ATCGMWSYKHBDVN--ATCG
ATCGGCCATCAA
>sample_2_protein
CKNJJATCA-WQR*
```
MEGA等で開けるが、簡単な確認ならテキストエディタで十分。<br>
配列数は対応するソフトで確認するか、>の個数を数えればよい。
## .fastq (.faq, .fq)
シーケンサから出力される、塩基配列情報とその配列の確からしさの情報が付与されたファイル。@から始まる配列名等の情報、塩基配列、その配列のクオリティがセットになっている。クオリティは64段階の指標が1文字であらわされており、現状30(誤差である確率0.1%、?で表される)以上あれば高いとみなして良いと思う。次世代シーケンサからの出力の場合、配列名等の情報にはシーケンサの型番やフローセル情報、アダプター配列情報などが付与されている。
```
@A00920:484:HK352DSXY:1:1101:1398:1000 2:N:0:GTGCAGTA+GACTTCAC
CACATAATAATTCATTATTAATAATAATTAACTATATTAAAA
+
FFFFFFFFFFFFFFFFFFFFFFFFFF+*''))**55CCF>>
@A00920:484:HK352DSXY:1:1101:1543:1000 2:N:0:GTGCAGTA+GACTTCAC
CACATAATAATTCATTATTAATAATAATTAACTATATTAAAA
+
FFFFFFFFFFF:FFFFFFFFF,FFFFFFFFFFFFFFFFFFFF
```
## .nexsus (.nex)
DNAやアミノ酸の配列を扱う際の形式。.fastaより多くの情報を付与できる。ファイル先頭に#NEXUS、beginで始まりendで終わる多数のブロックで構成される。最低でもtaxaとcharactersブロックが必要。BEASTやMrBaiseといった系統解析ソフトで必須のファイル形式。

```
#NEXUS
[ Title ]
begin taxa;
       dimensions ntax=2;
       taxlabels
             Sequence 1
             Sequence 2
;
end;
begin characters;
       dimensions nchar=6;
       format missing=? gap=- matchchar=. datatype=nucleotide;
       matrix

Sequence_1
ATCGAA---ATCTTAATCAT
Sequence_2
CGATTAATCATCTTAATCAT

;
end;
```
MEGA等で開けるが、対応していないブロックがあるのでテキストエディタで編集したほうが便利。
## .tree (.tre, .t), .nwk
系統樹をNewikフォーマットで記述したファイル。ノードの後に:枝長、[]内部にノードの情報（BS、事後確率等）を付加可能。
```
((A:1,B:1.2):0.2[100],C:2.4)
```
MEGA、FigTree等で開けるが、テキストエディタで編集することもできる。対応するソフトで開けば系統樹の形が表示される。<br>

## .ab1
サンガーシーケンサから出力される、蛍光の強度と塩基データを含むファイル。サンガ―シーケンスはこれを見ながら結果の解釈をする。<br>
MEGA、Gene Studio等で開ける。

## .sam, .bam, .bai
基準となる配列に別の配列をマッピングしたファイル。例えば、ゲノム配列に次世代シーケンスの結果をマッピングしたものなど。<br>
samファイルは可読性のあるファイルだが、ファイルサイズが大きい。bamファイルは可読性はない（バイナリファイル）だが、ファイルサイズが小さく、ソフトウェアのアクセス効率が良い。baiファイルはbamファイルへのアクセス効率を高めるためのインデックスファイル。samとbamは同値であり、samtoolsを利用すれば相互に変換可能。基本的にbamファイルの利用頻度のほうが高いので、bamファイルで保存しておき、必要に応じてsamファイルに変換するのが良いだろう。

## .vcf, .bcf
リファレンス配列と注目してる配列の違いのみを記述したファイル。vcfのバイナリ版がbcf。基本的にbcfのほうがファイルサイズが小さいが、可読性が無い。<br>
以下の例のように、ヘッダ部分に##で始まるファイル構造に関する情報が並び、その後タブ区切りにバリアント情報が並ぶ。vcfを出力したソフトによりヘッダ部分の構造は変わる。
```
##fileformat=VCFv4.2
##FILTER=<ID=PASS,...>
.
.
Chr_1  33244  .      A      T      PASS
Chr_1  33254  .      G      A      PASS
Chr_2  3419   .      C      AT     RefCall
Chr_2  67746  .      GA     G      PASS
```
## .bed
ゲノム上の座標情報をタブ区切りで示したファイル。最低でも3行（配列名、開始位置、終了位置）の情報が必要。行を追加することで他の情報も付与可能。例えば、配列そのものを保持することなくある配列がマッピングされたゲノム上の領域を表すのに使えるので、bamを扱うより便利なことがある。Bedtoolsで操作可能。簡単な操作はテキストエディタや、`sed`や`awk`などで扱うと便利。<br>
```
Chr_1 1 14
Chr_2 30  200
...
CHR_NUM START END
```

## 圧縮関連

### .tar
ディレクトリ（フォルダ）を1つのファイルとして「固めた」もの。圧縮はされない。`-v`オプションを付けると圧縮・展開中のファイル名が表示される。`tar -cvf OUT.tar IN`など。
```
tar -cf OUTPUT.tar INPUT_DIR #ディレクトリをファイルに変換
tar -xf INPUT.tar #ファイルをディレクトリに変換
```
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
一般的な（軽い）ファイルは以下のコマンドであつかう。ディレクトリの圧縮には対応していないので、ディレクトリを圧縮したい場合は一度tarファイルに変換してから圧縮する必要がある。
```
#圧縮
gzip INPUT #CPU_NUM個のCPUを使って圧縮、元のファイルは無くなる

#ディレクトリの圧縮
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
タブ区切りの生物学的データフォーマットに対応（特化？）した圧縮形式。あまり使うことはないが、一部のツールで要求される。samtools、tabixなどで圧縮・展開可能。


