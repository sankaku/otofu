# otofu

  By [upLaTeX](https://www.ctan.org/pkg/uplatex)([explanation by Japanese](https://texwiki.texjp.org/?upTeX,upLaTeX)), you can do the same thing much better than this tool does.
  
  This tool is (mainly) intended to use for Japanese TeX documents.

  `otofu` converts every non-ASCII character to `\UTF{...}` in a TeX document ('`...`' is the UNICODE code point of the character).
  You can translate the converted TeX file to dvi or pdf file by `pLaTeX`.
  
  Some characters like `髙`(U+9AD9) or `﨑`(U+FA11), which are invisible in pdf file, will be translated and visible normally by the great help of [OTF package](https://www.ctan.org/pkg/japanese-otf)([explanation by Japanese](https://texwiki.texjp.org/?OTF)).
  
  
## DEMO

## Requirements

+ Ruby

## Usage

  When you convert the file `foo.tex`, please type the command

  ```bash
  ruby otofu.rb foo.tex
  ```

  Then, you can translate the converted file `foo.tex.mod.tex` by `pLaTeX`.

## Features

1. Convert every non-ASCII character to `\UTF{...}`

   All non-ASCII characters are converted not only the ones which can't translate without OTF package, 
   but also the ones which can.

   **Example**

   + `abcDEF0123\.;:!?(){}[]$%&=-+*/` -> `abcDEF0123\\.;:!?(){}[]$%&=-+*/`

   + `ａｂｃＤＥＦ０１２３` -> `\UTF{ff41}\UTF{ff42}\UTF{ff43}\UTF{ff24}\UTF{ff25}\UTF{ff26}\UTF{ff10}\UTF{ff11}\UTF{ff12}\UTF{ff13}`

   + `あいうえお` -> `\UTF{3042}\UTF{3044}\UTF{3046}\UTF{3048}\UTF{304a}`

2. Leave unchanged the characters, `{...}`, such as in `\includegraphics[...]{...}`

   The reason to implement this feature is for the access to the file and the reference to the label.

   This feature is implemented for the commands `\includegraphics`, `\label` and `\ref`.

   **Example**

   + `\includegraphics[width=18cm]{あい/ue/お.eps}` -> `\includegraphics[width=18cm]{あい/ue/お.eps}`

   + `\\includegraphics[width=18cm]{あい/ue/お.eps}` -> `\\includegraphics[width=18cm]{\UTF{3042}\UTF{3044}/ue/\UTF{304a}.eps}`

     Conversion is not performed when the command is escaped.

3. Leave unchanged the file path, `{...}`, such as in `\include{...}` and convert the file recursively

   The reason to leave unchanged is for the access to the file.
   The recursive conversion is for saving the time to type commands for each referenced TeX documents. 
   
   This feature is implemented for the commands `\input` and `\include`.

   The additional extension to the converted file is `.mod.tex`.

   **Example**

   + `\input{あい/ue/お.tex}` -> `\input{あい/ue/お.tex.mod.tex}`
   + `\include{あい/ue/お}` -> `\include{あい/ue/お.tex.mod}`
   
     The recursive conversion is performed to `あい/ue/お.tex`.
   
   + `\\input{あい/ue/お.tex}` -> `\\input{\UTF{3042}\UTF{3044}/ue/\UTF{304a}.tex}`

     Conversion is not performed when the command is escaped.

4. Insert `\usepackage{otf}` if this line is not written in the preamble of the TeX file

	 This line is, however,  not inserted when there's no `\begin{document}` line in the TeX file.
	 The TeX file is regarded as a entirely body file, no preamble.

# Attention

1. cannot deal with the multi-line comment

   Single-line comment and multi-line comment are implemented in TeX.
   
   `otofu` can recognize the single-line comment (by `%`).
   After the conversion, the comment will not be output.

   `otofu` cannot recognize the multi-line comment(by `\begin{comment}` and `\end{comment}` or `\if0` and `\fi`).
   After the conversion, the converted comment will be output as TeX comment.
   If another TeX file is referenced by `\input` or `\include`, the file will be converted recursively.

## License

  [MIT License](http://www.opensource.org/licenses/MIT)
