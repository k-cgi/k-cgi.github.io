# Linuxの基本的な扱い方（遺伝研スパコンの使い方）

## 遺伝研スパコン

### ジョブファイルを書く

遺伝研にログインした状態でスクリプトを書く場合、nanoを使う。ファイルを見るだけなら、lessが便利。
```=
$ nano SCRIPT.sh
```
スクリプトを書いたら、Ctrl+Oで保存。Ctrl+Xで終了。

#### スクリプト例
```=
#$ -S /bin/bash
#$ -cwd
ulimit -s unlimited
echo running on `hostname`
echo starting at
date

echo "ohayougozaimasu"

echo ending at
date

#echo starting at date と echo ending at date は解析の開始と終了の時刻を出力する。
#終了時の時刻が出力されていない場合は、時間切れ、メモリ不足等でジョブが中断されていることを示す。
#開始・終了時刻が出ていてもエラーがないとは限らないので、出力はちゃんと確認する。
```

### ジョブを実行する

シェルスクリプト（SCRIPT.sh）にコマンドを書いてqsubでスパコンに投げる。

```=
$ qsub SCRIPT.sh
Your job 1234567 ("SCRIPT.sh") has been submitted
```
と表示されれば受け付けられている。このジョブが実行されているか調べるときはqstatを使う。
```=
$ qstat
job-ID     prior    name        user     state    submit/start at     queue            jclass      slots ja-task-ID 
-------------------------------------------------------------------------------------------------------------------   
1234567   0.25000  SCRIPT.sh   aaaaaa     r     11/27/2019 02:43:50 epyc.q@****                       1 
```
stateの部分が r になっていれば計算中。qwだと実行待ち。
ジョブを中止するときはqdelを使う。ジョブを投げた時に表示される番号で指定する。
```=
$ qdel 1234567
user has deleted job 1234567
```
ジョブの実行が終わるとSCRIPT.sh.e1234567（エラー出力）とSCRIPT.sh.o1234567（標準出力）のようなファイルも出力される。エラーが出ているときは基本的にe1234567の方にメッセージが出ている。

#### qsubのオプション

qsubでジョブを投げる時には様々なオプションを指定することができる。よく使うのが`-pe`と`-l`<br>
`-pe defslot SLOT_NUM`<br>
複数のスレッド（≈CPU数）を同時に稼働して処理を行うプログラムの時にdef_slotというPE(parallel environment)を指定し、直後にコア数（スロット数）を指定する。
`-l s_vmem=MEMORY -l mem_req=MEMORY`
投入ジョブが指定する仮想メモリの上限値を宣言する。 この値を超えてジョブが動作しようとするとジョブが中止される。単位はK、M、Gが使える。16Gと指定すれば16Gのメモリが指定される。<br>
デフォルトでは8GBになっているので、重い計算を行う時にはメモリを指定すると良い。これらのメモリは同じ値を指定する必要がある。また、-pe def_slotで複数スロットを指定しているときは、スロット数×メモリの値が要求されていることになる。

  - -l d_rtとs_rt
  デフォルトではジョブは3日で終了する。これ以上時間のかかる計算の場合には、時間を指定しなければならない。d_rtとs_rtには同じ時間を指定する。
  
  このほか、どのキューにジョブを投げるか指定することができる。デフォルトでは、epyc.qに入る。時間がかかる大きい計算の時は、medium.qに入れると良い。


**例** 
スロット数4、計算時間5日、メモリ128GB（スロット数が4なので合計で512GB）、mediumに投入
```=
$ qsub -pe def_slot 4 -l d_rt=120:00:00 -l s_rt=120:00:00 -l s_vmem=128G -l mem_req=128G -l medium yourjob.sh
```

### 遺伝研の解析ツール

スパコンに入っている解析ツールは/usr/local/biotools/に配置してあり、その直下にアルファベットのディレクトリとbioconductorのディレクトリがある。Rのパッケージを使いたい場合は、/usr/local/biotools/r/下にある「r-」から始まるコンテナや、/usr/local/biotools/bioconductor下にある「bioconductior-」から始まるコンテナを利用するとよい（ことが多い）。
使いたいソフトやそのバージョンがあるかを確認するときは、lsコマンドとワイルドカード「*」を使うと便利。大文字小文字が違ったり、ファイル名先頭になんかついてたりすることもあるので、Bioconda のホームページ（http://bioconda.github.io）やBioconductor（R関連のコンテナがある；https://bioconductor.org/packages/3.14/bioc） 内で検索をかけるのもよい。
ただし、新しいソフトやそのバージョンはBiocondaのホームページ上にあってもスパコン上にはないことがある。直近3か月くらいの更新はスパコン側に反映されていないと思っていいかも。

**例：スパコン上にあるminimap2のバージョンを調べる**

```=
$ls /usr/local/biotools/m/minimap2* #minimap2から始まるファイルをリストアップ
/usr/local/biotools/m/minimap2:2.0.r191--0
/usr/local/biotools/m/minimap2:2.10--1
/usr/local/biotools/m/minimap2:2.1.1--0
アルファベット順に並ぶので、古い順に並んでいるとは限らない。ver.1→10→11→12→2→...など
```
これらのコンテナは、表題のソフトが動く環境を丸ごとまとめたファイルである。
これらを使う時は、はじめに

`$ module load singularity`

としてmoduleコマンドでSingularity環境をロードする必要がある。singularityを複数回使う場合でも、このコマンドはログイン中またはジョブスクリプト内に1回実行すればよい。このあと、

`$ singularity exec 解析ツールが含まれるファイル名 実行したいコマンドライン`

と実行する。

**例：blast\:2.7.1--boost1.64_1内にあるblastxを使いたい場合**

```=
$ module load singularity
$ singularity exec /usr/local/biotools/b/blast:2.7.1--boost1.64_1 blastx -query sample.fasta -db database.fa -out output.txt
```

**例：blast\:2.7.1--boost1.64_1内にあるファイルを調べたい場合**

```=
#shellコマンドでコンテナ内に入る。
$ singularity shell /usr/local/biotools/b/blast:2.7.1--boost1.64_1    

#以下コンテナ内。自分のファイル+blast関連のファイルが存在する仮想環境になっている。
#普通にlinuxコマンドが使える。

Singularity> $PATH #パスの通った箇所をリストアップ
bash: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin: No such file or directory

Singularity> ls /usr/local/bin/blast* #このコンテナで実行可能なblast関連コマンドを表示
/usr/local/bin/blast_formatter    /usr/local/bin/blastdbcp
/usr/local/bin/blastdb_aliastool  /usr/local/bin/blastn
/usr/local/bin/blastdbcheck       /usr/local/bin/blastp
/usr/local/bin/blastdbcmd         /usr/local/bin/blastx

Singularity> exit #コンテナから抜ける
```
これで、このコンテナ内で実行可能なblast関連コマンド（の一部）が分かる。上手く動かないときはこのようにshellコマンドでコンテナ内部に入って構造を確認するといいかも。
#### スクリプトでSingularityを利用

```=
#$ -S /bin/bash
#$ -cwd
ulimit -s unlimited
echo running on `hostname`
echo starting at
date

export LANG=C　#singularity実行時のエラー回避。無くても動くが、エラーが出て不気味
module load singularity

cd /home/${USER}/test/

singularity exec /usr/local/biotools/t/trinity:2.13.2--ha140323_0 Trinity_gene_splice_modeler.py \
 --trinity_fasta Leaf_trinity.fasta

echo ending at
date
```



### その他
申請なしで利用できるストレージは1TBまで。現在の使用状況を確認するには
```=
$ lfs quota -u username ./
```
とすると、
```=
Disk quotas for usr username (uid ****):
 Filesystem  kbytes   quota   limit   grace   files   quota   limit   grace
   ./    1840       0  1000000000     -      23       0       0      
```
みたいな感じで現在の使用量が分かる。この場合は、1840KB使用中であることが分かる。

## Linux

