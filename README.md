# otofu

  [upLaTeX](https://www.ctan.org/pkg/uplatex)([解説](https://texwiki.texjp.org/?upTeX,upLaTeX))を使えばこのツールでやりたいことと同じことがはるかに便利で完全に使えるので、そちらを使いましょう。

  `otofu`は、TeX文書の非ASCII文字を`\UTF{...}`('`...`'はその文字のUNICODEコードポイント)の形に変換します。
  変換後のTeX文書は[OTFパッケージ](https://www.ctan.org/pkg/japanese-otf)([解説](https://texwiki.texjp.org/?OTF))でdviやpdfにできます。
  これにより、通常はTeXに書いても`pLaTeX`を使ってdviやpdfにすると正常に表示されない`髙`(U+9AD9。はしご高)や`﨑`(U+FA11。たつ崎)なども正常に表示されます。

## デモ

## 必要なもの

+ Ruby

## 使い方

  変換したいtexファイルを`foo.tex`として

  ```bash
  ruby otofu.rb foo.tex
  ```

  このあと、生成された`foo.tex.mod.tex`をTeX文書として`pLaTeX`を使ってdviやpdfにして下さい。

## 機能

1. ASCII文字でないものを`\UTF{...}`の形に変換する

   OTFパッケージを用いなければ正常に表示されない文字も、それ以外の文字も、すべて変換します。

   **例**

   + `abcDEF0123\.;:!?(){}[]$%&=-+*/` -> `abcDEF0123\\.;:!?(){}[]$%&=-+*/`

   + `ａｂｃＤＥＦ０１２３` -> `\UTF{ff41}\UTF{ff42}\UTF{ff43}\UTF{ff24}\UTF{ff25}\UTF{ff26}\UTF{ff10}\UTF{ff11}\UTF{ff12}\UTF{ff13}`

   + `あいうえお` -> `\UTF{3042}\UTF{3044}\UTF{3046}\UTF{3048}\UTF{304a}`

2. `\includegraphics[...]{...}`など`{...}`の中にある文字列は変換しない

   ここを`\UTF{...}`の形にしてしまうと、そのファイルにアクセスができなくなったり、ラベルが参照が正常にできなくなったりするため。

   これが適用されるコマンドは`\includegraphics`、`\label`および`\ref`。

   **例**

   + `\includegraphics[width=18cm]{あい/ue/お.eps}` -> `\includegraphics[width=18cm]{あい/ue/お.eps}`

   + `\\includegraphics[width=18cm]{あい/ue/お.eps}` -> `\\includegraphics[width=18cm]{\UTF{3042}\UTF{3044}/ue/\UTF{304a}.eps}`

     コマンドがエスケープされている場合は変換。

3. `\input{...}`などの中にあるファイル名は変換せずに拡張子を追加し、またそのファイルを再帰的に変換する

   変換しないのは、ここを`\UTF{...}`の形にしてしまうと、そのファイルにアクセスができなくなるため。
   再帰的に変換するのは、参照されているTeX文書を一つ一つこのスクリプトで変換する手間を省くため。

   これが適用されるコマンドは`\input`および`\include`。

   なお、追加される拡張子は`.mod.tex`。

   **例**

   + `\input{あい/ue/お.tex}` -> `\input{あい/ue/お.tex.mod.tex}`
   + `\include{あい/ue/お}` -> `\include{あい/ue/お.tex.mod}`
   
     この場合、さらに`あい/ue/お.tex`というファイルに対しても同様に変換します。

   + `\\input{あい/ue/お.tex}` -> `\\input{\UTF{3042}\UTF{3044}/ue/\UTF{304a}.tex}`

     コマンドがエスケープされている場合は変換。再帰的変換はしません。

4. `\usepackage{otf}`がプリアンブルにないなら追加する

   ただし`\begin{document}`がないファイルは全体が本文とみなし、追加はしません。

## 注意

1. 複数行コメントは認識しない

   TeXではコメントとして1行コメントと複数行コメントがあります。
   
   1行コメントは`%`以降をコメントとする方法です。これは`otofu`でコメントと認識でき、
   変換するとコメント部分は出力されません。

   複数行コメントは`\begin{comment}`から`\end{comment}`をコメントにする方法や、
   `\if0`から`\fi`をコメントにする方法などがあります。
   `otofu`はこれには対応していません。これらの部分も変換します。
   もしこのコメント部分で`\input`や`\include`によってTeX文書が参照されていると、
   その参照ファイルも再帰的に変換します。

## ライセンス

  [MIT License](http://www.opensource.org/licenses/MIT)

