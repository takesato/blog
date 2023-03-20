+++
date = "2016-02-13T20:50:30+09:00"
description = "hugo と circle ci を使って github.io に自動で blog を更新する，その1"
slug = "hugo_circleci_github"
tags = [
  "hugo",
  "circleci",
  "github"
]
title = "hugo と circle ci を使って github.io に自動で blog を更新する，その1"
draft = false

+++

いい加減 blog 等書いて output しないとなーと思っていたので github.io を使う事にした．

<!--more-->
# 前置き

##  hugo

github.io は静的なファイルしか hosting はできないけど，事前に build したファイルをアップすれば wordpress とか用意しなくて良いのでそういう用途のツールが色々ある．
有名どころだとこの辺

- [Jekyll • Simple, blog-aware, static sites](https://jekyllrb.com/) 約 239,000 件/ruby
- [Octopress](http://octopress.org/) 約 242,000 件/ruby
- [hexojs/hexo: A fast, simple & powerful blog framework, powered by Node.js.](https://github.com/hexojs/hexo) 約 84,400 件/nodejs
- [Middleman: Hand-crafted frontend development](https://middlemanapp.com/) 約 122,000 件/ruby


リンクの横のは `github.io` とペアで検索した結果の件数と，使用言語．

件数だけみると Jekyll か Octopress が人気なようで．普段使ってる言語も ruby なのでそのどっちかの方が楽なんだろうけど，今回はたまたま目についたのと go に興味があるので hugo を使ってみる事にした．

- [Hugo - Hosting on GitHub Pages](https://gohugo.io/tutorials/github-pages-blog/)  約 99,800 件/go

## github.io

github.io は github の repository に gh-pages という branch を作ると，その branch の中身を `http://ユーザー名.github.io/リポジトリ名` として公開してくれるサービス．
例えばこの blog であれば https://github.com/takesato/blog という repository があって，それが http://takesato.github.io/blog/ になる．
唯一例外で https://github.com/takesato/takesato.github.io みたいに自分の github.io のhost 名の repository を作ると http://takesato.github.io/ に公開される(らしい，まだ試していない)

## circle ci

とりあえず `github.io` と hugo 等を使う事で，簡単に blog を構築する事ができるんだけど，どうせなので [CircleCI](https://circleci.com/)` と組み合わせる事にした． deploy script を書いてそれ実行するだけでも更新，というのはできるんだけどそれだと mac の前にいないといけないのが CI に任せれば github 上のみで blog を更新できるようになるので．( github は web 上から更新する事ができるので github が blog editor になる)実際にそういう運用するかはまだわからないけど．

# 本題

という訳で，あちこち参考にしてできたのが現在の構成．
細かい設定とかは [takesato/blog](https://github.com/takesato/blog) の中みてもらうとして，自分のメモとして必要そうな手順をまとめてみる．

## hugo の install

「mac なら brew で入る」 みたいなサイトが多いんだけど `go get` した
```shell
go get -v github.com/spf13/hugo
```

理由としては， circle ci 上で hugo 使うには同じく `go get` しないといけないんだけど，brew だとバージョンが一致していない為．(とはいえこれは brew upgrade したりすれば揃うのかもだけど)

あとは単純に気分の問題．

## hugo の初期化

基本的には [Hugo - Hugo Quickstart Guide](https://gohugo.io/overview/quickstart/) にある通り．

```shell
hugo new site blog
```

だけど自分の場合は ghq で管理してるので `ghq get -p takesato/blog` したディレクトリに `new --force` で必要なファイルを生成した．その後 theme を [ここ](http://themes.gohugo.io/) から適当に選んで submodule に追加．
まとめるとこんな感じ．

```shell
ghq get -p takesato/blog
cd github.com/takesato/
hugo new site blog --force
git submodule add -f git@github.com:dim0627/hugo_theme_beg.git themes/hugo_theme_beg
git submodule sync
git submodule update --init --recursive
```

theme は github ぽいので [Hugo Theme: Beg](http://themes.gohugo.io/beg/) を選択．あとで独自の作るつもり．

## hugo の設定

hugo 自体の設定は `config.toml` で行なう．
とりあえず今回の設定．

```
baseurl = "https://takesato.github.io/blog"
languageCode = "ja-JP"
title = "takesato's blog"

theme = "hugo_theme_beg"
MetaDataFormat = "toml"
canonifyurls = true
paginate = 3

[author]
  name = "takehito sato"

[permalinks]
  post = "/:slug/"

[indexes]
  category = "categories"

[params]
  toc = true
  highlight = "sunburst"

  twitter = "https://twitter.com/takesato"
  github = "https://github.com/takesato"
```

hugo 自体の設定と， theme 独自の設定があるっぽい…けどまだ詳しくは追っていない．
最低限必要そうなのだけ調整した．

## circle ci の設定

わりとここが本題．
今回やりたかった事は，

- 記事を書く際に branch を作成し，記事を書く．
- それを push したのち PR として出す．自己レビュー(推敲とかする為)したのち master にマージ．
- master にマージされたら circle ci が動く
  - cicrle ci が hugo を実行，public 以下のファイルを生成する
  - public 以下のファイルを commit したのち， gh-pages branch に push する

という流れ．
`gh-pages` は所謂 document root 的なファイルだけあればいいので，hugo が生成する public ディレクトリ以下のファイル以外は不要．
最初，こういう branch を管理するのに **gh-pages 用の repository を用意して subtree で push する(つまり公開用の repository と編集用の repository をわける)** という方法を書いてる所があったんだけど結論から言えば subtree は不要だった．
今回は repository を分けるつもりがなかったんだけどgh-pages branch を subtree 管理すればいけるだろーって思ったら上手く動かず無駄にはまってしまった．

最終的に上手くいったのはこんな感じ．

```shell
general:
  branches:
    ignore:
      - gh-pages
    only:
      - master

checkout:
  post:
    - git submodule sync
    - git submodule update --init --recursive

machine:
  timezone: Asia/Tokyo

dependencies:
  pre:
    - go get -v github.com/spf13/hugo
    - git config --global user.name "CircleCI"
    - git config --global user.email "circleci@example.com"

test:
  override:
    - hugo check

deployment:
  master:
    branch: master
    commands:
      - git clone -b gh-pages git@github.com:takesato/blog.git public
      - hugo
      - cd public && git add . && git commit -m "publish on `TZ=JST-9 date '+%Y/%m/%d %H:%M:%S'`" && git push origin gh-pages
```

## orphan な gh-pages branch

上記の circle ci の設定を使う前提だと，まず `gh-pages` branch が存在している必要がある．
なので orphan な branch を作って事前に push しておく．
空だと push できない( `--allow-empty` な commit すれば push できるけど)のと， `gh-pages` branch を circle ci で動かない( skip する)ように， gh-pages 用の `circle.yml` だけ追加して push した

```shell
git chekcout --orphan gh-pages
git rm -rf .
cat << EOS > circle.yml
general:
  branches:
    ignore:
      - gh-pages
EOS
git add circle.yml
git commit -m 'initial commit'
git push origin gh-pages
```

基本的な事しか書けてないけど長くなったので一旦これが自動生成されるか投稿してみる．
