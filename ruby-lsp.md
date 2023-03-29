# ruby-lsp がでた

Name: Ruby LSP
Id: Shopify.ruby-lsp
Description: VS Code plugin for connecting with the Ruby LSP
Version: 0.2.3
Publisher: Shopify
VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=Shopify.ruby-lsp


競合してるのありそうなので整理しよう．

---

機能は個別にオンオフできるぽくて，それをみると
- 実験的機能
- 13 の機能
    - "codeActions": true,
    - "diagnostics": true,
    - "documentHighlights": true,
    - "documentLink": true,
    - "documentSymbols": true,
    - "foldingRanges": true,
    - "formatting": true,
    - "hover": true,
    - "inlayHint": true,
    - "onTypeFormatting": true,
    - "selectionRanges": true,
    - "semanticHighlighting": true,
    - "completion": true
- ruby バージョンマネージャ
- LSP サーバ
- YJIT

らしい． formatting は Rufo かな

# いままでいれてたやつ．

> Name: Ruby Solargraph
> Id: castwide.solargraph
> Description: A Ruby language server featuring code completion, intellisense, and inline documentation
> Version: 0.24.0
> Publisher: Castwide
> VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=castwide.solargraph

lsp が Language Server Protocol なわけなので， solargraph は競合するはず．
つまり Solargraph もオフにしていいはず(とはいっても lsp server がなんか起動しないんだが…)

> Name: Rufo - Ruby formatter
> Id: jnbt.vscode-rufo
> Description: VS Code plugin for ruby-formatter/rufo
> Version: 0.0.5
> Publisher: jnbt
> VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=jnbt.vscode-rufo

rufo gem ないって怒られて `gem install rufo` したら消えたので， rufo はしてくれそう．
つまり `jnbt.vscode-rufo` は不要なはず

> Name: ruby-rubocop
> Id: misogi.ruby-rubocop
> Description: execute rubocop for current Ruby code.
> Version: 0.8.6
> Publisher: misogi
> VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop

これよくみると vscode-ruby を recommend しているので，ここ自体も被ってるぽいのでオフってよさそう

---

> Name: Ruby
> Id: rebornix.ruby
> Description: Ruby language support and debugging for Visual Studio Code
> Version: 0.28.1
> Publisher: Peng Lv
> VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby

- Automatic Ruby environment detection with support for rvm, rbenv, chruby, and asdf
    - 対応している
- Lint support via RuboCop, Standard, and Reek
    - diagnostics 診断，だろうか?
- Format support via RuboCop, Standard, Rufo, Prettier and RubyFMT
    - formatting
- Semantic code folding support
    - foldingRanges
- Semantic highlighting support
    - semanticHighlighting
- Basic Intellisense support
    - completion かな?補完．


> Name: VSCode Ruby
> Id: wingrunr21.vscode-ruby
> Description: Syntax highlighing, snippet, and language configuration support for Ruby
> Version: 0.28.0
> Publisher: Stafford Brunk
> VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=wingrunr21.vscode-ruby

rebornix.ruby に依存していた．こいつ止めるには `rebornix.ruby` も止めろと．

- Syntax highlighing
    - semanticHighlighting
- snippet
    - これなににつかってたっけ
    - snippets to Ruby and ERB
        - ひとまずなくてもいいな
- language configuration
    - これもなんだ?


---

devcontainer 上で ruby-lsp 起動しないのだけ気になる