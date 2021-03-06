# ゲノムアセンブラいろいろ

使用経験のあるアセンブラについて使い方などをまとめておく。主に遺伝研スパコン（以下スパコン）上で動作を確認しているが、動かなかったものも含む。また、インプットデータはゲノムサイズ3Gbp程度の植物から得られたnanoporeロングリードと、NocaSeq6000のペアエンド（PE）のショートリードである。それぞれのソフトの詳細は各開発元のホームページを参照のこと。

- [一般論](#一般論)
- [ロングリード用](#ロングリード用)
  - [Flye](#flye)
  - [Canu](#canu)
  - [NECAT](#necat)
  - [NextDenovo](#nextdenovo)
- [ショートリード用](#ショートリード用)
  - [Abyss2](#abyss2)
  - [SPAdes](#spades)
- [ロング・ショート混合用](#ロングショート混合用)
  - [Platanus2](#platanus2) 
  - [HASLR](#haslr)
- [オルガネラ用](#オルガネラ用)
  - [GetOrganelle](#getorganelle) 

## 一般論
- インプットデータは多い方が良いが、質の悪いデータは捨てたほうが良い。（例：naoporeからの3000Kbp以下のリード、Q score 30以下のショートリードなど）
- アセンブラのパラメータはいろいろ工夫してみる。（例：K-merを増やす、必要カバレッジを下げる、圧縮された入力ファイルを展開してみる）
- 1つのアセンブラでうまくいかなくても、新しいバージョンや他のアセンブラを試す。

## ロングリード用
主にNanoporeやPacBioからのデータをもとにアセンブルをするアセンブラ。大きなゲノムサイズや高いエラー率に対応したものが多い。<br>
なるべくエラー率が低く、長い配列を入れるとうまくいきやすい。

### Flye
正確性がやや劣るが、使用メモリが少なく、中間ファイルも少ないためスパコン上で動かすのに最適。5つの計算過程がある。標準出力に各過程での消費メモリが出力されるので、途中でメモリが不足する時などは参考にする。

```
singularity exec /usr/local/biotools/f/flye-BUILD_NUM flye --nano-raw INPUT.fq.gz --out-dir OUT_DIR --threads NUM_THREADS
```
再開する場合は、入出ディレクトリ、中間ファイルを変更せずに`--resume`を付けて再実行すればいい。
```
flye --nano-raw INPUT.fq.gz --out-dir OUT_DIR --threads NUM_THREADS --resume
```
3000Kbp以上のNanoporeリード65Gbpを入力として利用した場合、次の設定で4日弱かかった。
```
flye --nano-raw INPUT.fq.gz --out-dir OUT_DIR --threads 30 
#qsub -pe def_slot 30 -l medium -l s_vmem=390G -l d_rt=192:00:00 -l s_rt=192:00:00 JOBNAME
```
なお、350Gbp分のNanoporeリードを入力として利用した場合、第一段階の計算に20日かかったうえ、エラーがでてアセンブルできなかった。
```
flye --nano-raw INPUT.fa.gz --genome-size 3.5g --out-dir OUT_DIR --threads 40
#qsub -pe def_slot 40 -l medium -l s_vmem=640G -l d_rt=1440:00:00 -l s_rt=1440:00:00 JOBNAME
```

#### 出力ファイル

`--out_dir`で指定したディレクトリに5つのディレクトリと6つのファイルが出力される。アセンブル結果はOUT_DIRにassembly.fastaとして出力される。それ以外はログ、統計データや、コンティグ間のつながりを示すグラフなど。<br>うまくアセンブル結果が出力されない場合はflye.logを見てエラーの原因を探る。数字から始まるフォルダは下流の解析では使わないので、お試しでアセンブルした場合、再解析する場合以外はこれらのフォルダは消してしまっても良い。asemmbly_graphは下流の解析で使う場合があるので、とっておいたほうがいい。.gfaと.gvの2種があるが、内容は同値なので、軽い方だけ残してもいいかもしれない。


### Canu
正確性が高いとされる。スパコンで動かすことはできたが、中間ファイルが数TBにのぼるため、遺伝研スパコン上でアセンブルを完了することはできなかった。

### NECAT
スパコンで動かすことはできたが、メモリ不足(メモリ200G指定)でアセンブルは完了できなかった。

### NextDenovo
コンフィグファイル（config.cfg）にインプットファイルや各種パラメーターなど必要な情報を書き込み、次のコマンドで実行
```
nextDenovo config.cfg
```
Singularityなしで実行。動きはするが途中でエラーがでて止まる。マルチスレッド用のライブラリが上手く認識されていないかも。Singularity経由なら動く可能性がある。

## ショートリード用
大きなゲノムに対応しているアセンブラは少ない。また、重複が多いとアセンブル結果が極端に悪くなる。

### Abyss2

インプットにはQuality check前で90Gbp含まれる150bp PEのリードを使用。解析は2日程度で完了した。ゲノムに重複の多い種のため、BUSCOは40-50%程度であった。<br>
k-merやHの値に検討の余地がある。スパコンでの実行例は以下の通り。

```
singularity exec  /usr/local/biotools/a/abyss:2.3.3--hd403d74_1 abyss-pe name=SAMPLE_NAME k=64 \
    in="ILUMINA_PE1.fq.gz ILUMINA_PE2.fq.gz" B=60G H=3 kc=3 v=-v

#qsub -l medium -l s_vmem=120G -l mem_req=120G JOBNAME
```
再開する場合は、入出ディレクトリ、中間ファイルを変更せずに同じコマンドを再実行すればいい。

#### 出力ファイル
カレントディレクトリに50ファイル程度出力される。ファイル名の先頭にSAMPLE_NAME-statsか、SAMPLE_NAME-8がついているファイルが結果のファイル。8がついているファイルはシンボリックリンクなので、ダウンロードしたい場合はリンク先をダウンロードする。

### SPAdes
スパコン上で動作はするものの、数Gbpを超えるゲノムはアセンブルできない。

## ロング・ショート混合用
### Platanus2
公式サイトからダウンロードしてきた後、`chmod 755`で実行権を付与して使う。インプットデータにはロングリードとショートリードを同時に指定できる。その場合、まずショートのアセンブルがされた後、ロングでアセンブルされるようである。<br>
スパコン上で動作はするものの、エラーが出て実行完了できず。同様のエラーが出ている人がいたが、バグに由来するものらしい。最近更新されていないので、対処できない可能性がある。

### HASLR
スパコン上で動作はするものの、マルチコアの制御が上手くいかないらしく途中で止まる。シングルコアで動かせば動かしきれるかもしれないが、未検証。

## オルガネラ用
ショートリードを入力して、オルガネラゲノムのみを再現するためのアセンブラ。

### GetOrganelle
分類群を指定して、葉緑体やミトコンドリアのゲノムを再現することができる。インプットにはショートリードが必要。葉から抽出したDNAに由来するサンプルから10Gbp程度入力したところ、葉緑体ゲノムが上手く再現された。ただし、アノテーションは正確性が低いらしいので、アノテーションは手動でやった方がいいらしい。<br>
まず、get_organelle_config.pyでデータベースを採ってきてから、それを基準にget_organelle_from_reads.pyでゲノムを再現する。以下のコマンドで植物の葉緑体ゲノムを再現することが可能。
```
python3 get_organelle_config.py -a embplant_pt 
python3 get_organelle_from_reads.py -t NUM_THREAD -1 ILUMINA_PE1.fq.gz -2 ILUMINA_PE2.fq.gz -o OUT_DIR -R 15 -k 21,55,85,115 -F embplant_pt
```
植物ミトコンドリア以外をアセンブルする場合、get_organelle_config.pyの`-a`と、get_organelle_from_reads.pyの`-F`を変更する。
スパコン上で植物のデータから葉緑体ゲノムを再現した場合、次のオプションで2時間強で計算が完了した。
```
qsub -pe def_slot 4 -l medium -l s_vmem=60G　getorganelle_nagi
```

#### 出力ファイル
葉緑体の場合、うまく解析されれば、OUT_DIRにLSCの裏表が異なる2つfastaファイルが出力される。うまく環状のデータが再現できない場合、3つ以上のfastaファイルが出力される。その場合はk-merの値を大きくするなどして再計算する。
