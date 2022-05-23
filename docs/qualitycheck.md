# クオリティーチェック
インプットのDNAやRNAの質は下流の解析結果に大きな影響を与える。データ量を増やすより質の悪いデータを除去したほうがコスパがいい場合もある。<br>
ここでは次世代シーケンスの結果のクオリティーチェックの仕方と、クオリティの低い配列の除去方法を紹介する。基本的にFastQCで生データ確認→Trimmomaticで質の悪いリードの除去→FastQCで除去後の確認という流れでクオリティーのチェックと処理を行う。

- [FastQC](#fastqc)
- [Trimmomatic](#trimmomatic)

## FastQC
fastqファイルを入力し、そのファイルに含まれるリードのクオリティや関連する情報の分析・図示を行ってくれるソフト。
ファイルをダウンロード・展開すればそのまま使える。[Fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

### インストール
```
$ wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip
$ unzip fastqc_v0.11.8.zip
```
遺伝研スパコンの場合singularityイメージが用意されているのでそれを使う。

### 実行
インプットはfastqのみでOK。圧縮されていても認識する。
```
$ fastqc --nogroup -o OUTPUT_DIR INPUT.fq.gz
```
複数ファイルある場合はfor文などでまとめて処理すればOK。

### 出力
クオリティなどの結果が載ったhtmlファイルと、その描画に必要なzipファイルが出力される。GUI環境ではhtmlとzipを同じフォルダに入れておけば、htmlファイルを開いたときに画像が表示される。<br>
多数の基準からインプットのクオリティを調べ、問題なければチェックマークが、問題があれば注意マークやバツマークが表示される。Per base sequence contentや、Per sequence GC contentに注意やバツマークが出ることがある。前者はライブラリ調整に使う試薬の関係、後者はゲノムの構造などにより仕方ない場合もある。

## Trimmomatic
fastqファイルを入力し、指定した条件を基準にリードを取捨選択するソフト。ペアエンドリードを入力した場合、ペアの関係を維持したまま出力してくれる。

### インストール
```
$ wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
$ unzip Trimmomatic-0.39.zip
```
遺伝研スパコンの場合singularityイメージが用意されているのでそれを使う。

### 実行
インプットはfastqのみでOK。圧縮されていても認識する。
```
$ java -Xms512m -Xmx512m -jar trimmomatic-0.39.jar PE\
-threads CPU_NUM\ #複数のCPUを使う場合
-phred33\ 
INPUT_1.fq.gz INPUT_2.fq.gz\ #ペアエンドの場合
OUTPUT_1_paired.fq.gz\ 　#トリムされた1のリードの名前
OUTPUT_1_unpaierd.fq.gz\　#トリムの結果ペアエンドじゃなくなった配列1
OUTPUT_2_paired.fq.gz\　 #トリムされた2のリード
OUTPUT_1_unpaierd.fq.gz\　#トリムの結果ペアエンドじゃなくなった配列2
ILLUMINACLIP:adapters.fa:2:30:10 \　#除去したいアダプター配列を指定
SLIDINGWINDOW:4:30 LEADING:30 TRAILING:30 MINLEN:100 #除去したい配列のクオリティを指定
```
SLIDINGWINDOW:4:30 先頭から4bpずつの平均クオリティを計算し、30未満となった以降の配列を捨てる<br>
LEADING:30 TRAILING:30 リードの先頭または後ろからクオリティが30未満の塩基を捨てる。<br>
MINLEN:100 100bp未満の配列を捨てる。<br>
複数ファイルある場合はfor文などでまとめて処理すればOK。初めにファイル名を変数にしておけばいちいちファイル名を書かなくて良くなる。

### 出力
OUTPUT_1_paired.fq.gz、OUTPUT_1_unpaierd.fq.gz、OUTPUT_2_paired.fq.gz、OUTPUT_1_unpaierd.fq.gzの4ファイルが出力される。このうちOUTPUT_1_paired.fq.gzとOUTPUT_2_paired.fq.gzがペアを維持したままで低いクオリティのリードが除去された配列である。下流の解析には基本的にこれを利用する。
