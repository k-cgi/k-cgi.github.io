# Linuxでデータ整形
## 文字列
### perl
### grep
### sed
#### 最短一致
#### タブ文字の検索
#### 正規表現
## データ
### awk
### sort
### uniq
### grep
### comm

## 例
以下のように、タブ区切りで遺伝子名、GOターム、発現量の情報がこの順で含まれている2つのファイルがあるとする。
```
$ cat File1
AT1G308911  GO:12345678 24
AT1G301231  GO:13455654 54
AT1G312531  GO:00183941 8221
~~~略~~~

$ cat File2
AT1G308911  GO:12345678 73
AT1G301231  GO:13455654 1023
AT1G312531  GO:00183941 3816
~~~略~~~

```
**例：2番目のファイルのみに含まれる遺伝子の一覧を取得**
```
comm -13 <(awk '{print $1}' File1 | sort) <(awk '{print $1}' File2 | sort) | uniq > OUT.txt
```
File2にのみ含まれる遺伝子名が重複を除いた状態でOUT.txtに出力される。<br>
**例：発現量が100以上の遺伝子のうち、両方のファイルに含まれる遺伝子の一覧を取得**
```
comm -12 <(awk '(if $3>100){print $1}' File1 | sort) <(awk '{print $1}' File2 | sort) | uniq > OUT.txt
```
<br>
**例：ファイル1のうち、GOタームのリスト（GO_list.txt）に含まれるGOをもつ遺伝子の一覧を取得**

```
comm -13 <(awk '(if){print $1}' File1 | sort) <(awk '{print $1}' File2 | sort) | uniq > OUT.txt
```
<br>
