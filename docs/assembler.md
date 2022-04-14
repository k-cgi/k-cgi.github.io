# ゲノムアセンブラについて

以下、使用経験のあるアセンブラについて使い方などをまとめておく。主に遺伝研スパコン（以下スパコン）上で動作を確認しているが、動かなかったものも含む。また、インプットデータはゲノムサイズ3Gbp程度の植物から得られたnanoporeロングリードと、NocaSeq6000から得られたペアエンド（PE）のショートリードである。

## 一般論
- インプットデータは多い方が良いが、質の悪いデータは捨てたほうが良い。（例：naoporeからの3000Kbp以下のリード、Q score 30以下のショートリードなど）
- アセンブラのパラメータはいろいろ工夫してみる。（例：K-merを増やす、必要カバレッジを下げる、圧縮された入力ファイルを展開してみる）
- 1つのアセンブラでうまくいかなくても、新しいバージョンや他のアセンブラを試す。

## ロングリード用
主にNanoporeやPacBioからのデータをもとにアセンブルをするアセンブラ。大きなゲノムサイズや高いエラー率に対応したものが多い。<br>
なるべくエラー率が低く、長い配列を入れるとうまくいきやすい。

## Flye
正確性がやや劣るが、使用メモリが少なく、中間ファイルも少ないためスパコン上で動かすのに最適。4つの計算過程がある。標準出力に各過程での消費メモリが出力されるので、途中でメモリが不足する時などは参考にする。

```
singularity exec /usr/local/biotools/f/flye-BUILD_NUM flye --nano-raw INPUT.fq.gz --out-dir OUT_DIR --threads NUM_THREADS
```
再開する場合は、入出ディレクトリ、中間ファイルを変更せずに`--resume`を付けて再実行すればいい。
```
singularity exec /usr/local/biotools/f/flye-BUILD_NUM flye --nano-raw INPUT.fq.gz --out-dir OUT_DIR --threads NUM_THREADS --resume
```

-pe def_slot 20 -l medium -l s_vmem=600G -l mem_req=30G

なお、350Gbp分のNanoporeリードを入力として利用した場合、第一段階の計算に20日かかったうえ、エラーがでてアセンブルできなかった。
```
flye --nano-raw INPUT.fa.gz --genome-size 3.5g --out-dir OUT_DIR --threads 40
#qsub -pe def_slot 40 -l medium -l s_vmem=640G -l d_rt=1440:00:00 -l s_rt=1440:00:00
```



## Canu
正確性が高いとされる。スパコンで動かすことはできたが、中間ファイルが数TBにのぼるため、遺伝研スパコン上でアセンブルを完了することはできなかった。

## NECAT
スパコンで動かすことはできたが、メモリ不足(メモリ200G指定)でアセンブルは完了できなかった。

## ショートリード用
### Abyss2

インプットにはQuality check前で90Gbp含まれる150bp PEのリードを使用。解析は2日程度で完了した。ゲノムに重複の多い種のため、BUSCOは40-50%程度であった。<br>
k-merやHの値に検討の余地がある。スパコンでの実行例は以下の通り。

```
singularity exec  /usr/local/biotools/a/abyss:2.3.3--hd403d74_1 abyss-pe name=SAMPLE_NAME k=64 \
    in="ILUMINA_PE1.fq.gz ILUMINA_PE2.fq.gz" B=60G H=3 kc=3 v=-v

#qsub -l medium -l s_vmem=120G -l mem_req=120G JOBNAMEで実行

```
再開する場合は、入出ディレクトリ、中間ファイルを変更せずに同じコマンドを再実行すればいい。

### SPADes
スパコン上で動作はするものの、数Gbpを超えるゲノムはアセンブルできない。

## ロング・ショート混合用
### Platanus2
