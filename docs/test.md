# バリアントコール

- [Deep Variant](#deep_variant)
-  [入力ファイル](#入力ファイル)
-  [実行](#実行)
-  [出力結果](#出力結果)
- [GATK](#gatk)
## Deep Variant
### 入力ファイル
- ゲノムデータ(.fasta)
- ゲノムのインデックスファイル(.fai)
- ゲノムにマッピングした(.bam)
- 上記bamファイルのインデックス(.bai)

faiファイルは<br>
`samtools faidx INPUT_GENOME.fasta`<br>
で作成される。<br>
baiファイルを作るにはまずbamファイルをソートする必要がある。<br>
```
samtools sort INPUT.bam INPUT.sorted #ソート
samtools index INPUT.sorted #baiファイル出力
```
でbaiファイルが出力される。<br>

### 実行

### 出力結果


## GATK
入力ファイルの下処理が非常に煩雑であるため、特に理由が無ければDeep Variantを使った方が良い。<br>
前処理→重複除去→クオリティ補正→バリアントコール→結果のフィルタリング
