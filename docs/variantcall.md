# バリアントコール

- [Deep Variant](#deep-variant)
    - [入力ファイル](#入力ファイル)
    - [実行](#実行)
   - [出力結果](#出力結果)
- [GATK](#gatk)
## Deep Variant
機械学習を利用したバリアントコーラー。簡単に使えて、計算も速い。開発者によればGATKと同等の結果が出るらしく、GATKが煩雑なことを考えればこちらで十分かもしれない。細かいことは[開発者のページ](https://github.com/google/deepvariant)を参照。[ブログ記事](https://google.github.io/deepvariant/)も参考になる。以下、遺伝研スパコンでDeep Variantを動かす方法について解説する。
### インストール
Singularityを使って動かすと便利だが、Deep Variantの最新版のイメージがスパコン上にないため、dockerからpullしてくる。
```
BIN_VERSION="1.3.0" #ほしいバージョンに適宜変更する。
singularity pull docker://google/deepvariant:"${BIN_VERSION}"
```
実行すると、カレントディレクトリにdeepvariant:1.3.0.sifのようなファイルができる。実行する際はこれをrunすれば良い。
### 入力ファイル
- ゲノムデータ(.fasta)
- ゲノムのインデックスファイル(.fai)
- ゲノムにマッピングしたショートリード等(.bam)
- 上記bamファイルのインデックス(.bai)
これらをすべて同じディレクトリ（INPUT_DIR）に入れておく。
faiファイルは<br>
```
samtools faidx INPUT_GENOME.fasta
```
で作成される。<br>
baiファイルを作るにはまずbamファイルをソートする必要がある。<br>
```
samtools sort INPUT.bam INPUT.sorted #ソート
samtools index INPUT.sorted #baiファイル出力
```
でbaiファイルが出力される。<br>

### 実行
```
#入力などの設定
BIN_VERSION="1.3.0"
TYPE="WGS" #[WGS,WES,PACBIO,HYBRID_PACBIO_ILLUMINA]のいずれかを指定
INPUT_DIR="INPUT_DIR"
INOUT_FASTA="INPUT_GENOME.fasta" 
INPUT_BAM="INPUT.bam"
OUTPUT_DIR="OUTPUT_DIR"
OUTPUT_NAME="OUTPUT"
CPU_NUM="CPU_NUM"　#使うコア数を指定。多ければいいというものではないっぽい

#以下で実行。他のオプションもあり。
singularity run -B /usr/lib/locale/:/usr/lib/locale/ \
  docker://google/deepvariant:"${BIN_VERSION}" \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type="${TYPE}" \ 
  --ref="${INPUT_DIR}"/"${INPUT_GENOME}"  \
  --reads="${INPUT_DIR}"/"${INPUT_BAM}" \
  --output_vcf="${OUTPUT_DIR}"/"${OUTPUT_NAME}".vcf.gz \
  --output_gvcf="${OUTPUT_DIR}"/"${OUTPUT_NAME}".g.vcf.gz \
  --intermediate_results_dir "${OUTPUT_DIR}/intermediate_results_dir" \ **Optional.
  --num_shards="${CPU_NUM}" \
```

### 出力結果
2.5Gbp程度のゲノムと80Gbp程度のショートリードを入力したところ、3日間かかった。コア数は8と16を試したが、ほぼ同じ時間かかった。計算そのものは16コアのほうが速かったが、なぜかファイルの書き込みは16コアのほうが遅かったため、結局どちらも3日かかった。<br>
OUTPUT_DIRに指定したディレクトリに.vcf.gzと.g.vcf.gzファイル、ログファイルが出力されている。vcfファイルにはバリアントの一覧とその評価（PASS、RefCall）が載っているので、評価がPASSになっているもののみを下流の解析に使うと良い（`zgrep PASS`などで抽出できる）。RefCallはバリアントか疑わしいもの。ゲノムファイルとvcfファイルをvcftoolsに入力すればコール結果を適用したゲノム配列が得られる。また、bedtoolsを利用すれば、特定の領域にあるバリアントのみを抜き出してくることも可能。

## GATK
入力ファイルの下処理が非常に煩雑であるため、特に理由が無ければDeep Variantを使った方が良い。自分は使ったことがないので要確認。<br>
前処理→重複除去→クオリティ補正→バリアントコール→結果のフィルタリング<br>
