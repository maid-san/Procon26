## What is this?
- [第 26 回高専プロコン](http://www.procon.gr.jp) にて私の所属したチームで用いたサーバ。
- サーバを1台用意することで、開発作業の効率的分散化、解答の高速化を狙った。
- 機能
    - 競技が行われたサーバとの問題のやり取り
    - 各クライアントから送られてきた解答のうち最良のものについての得点、使用石数の記録

## Usage
    $ coffee Server.coffee (option)

- option
    - -p, --port: 解放するポート番号を指定する。指定しない場合、40000 番ポートが解放される。
    - -s, --stable: サーバへのPOSTを安定的なものにする
    - -S, --special: latency を常に0にする。
    - -v, --version: このプログラムのバージョンを表示する。
    - -h, --help: Usage 情報を表示する。

## API
- POST /answer
    - パラメタ
        - answer: 競技サーバに送信する回答データ
        - score: 回答データのスコア
        - stone: 回答データで使用した石の数
        - token: 回答者の名前(チームトークンではありません)
    - レスポンス
        - isBestscore: 送信したデータが、現状の最良得点であるかの真偽値
        - isLowerStone: 送信したデータで使用した石が、現状の最良回答のそれよりも少ないかどうかの真偽値
        - latency: 送信したデータが、実際に競技サーバに送信されるまでの待ち時間
    - curl での例
            
            $ curl 'http://IP_Address:40000/answer' -F 'answer=@ans.txt' \
            -F 'score=180' -F 'stone=1' -F 'token=homomaid'
- GET /bestanswer
    - パラメタ
        - なし
    - レスポンス
        - score: 本サーバが記録している最良回答の得点
        - stone: 本サーバが記録している最良回答が使用した石の数
    - curl での例
            
            $ curl 'http://IP_Address:40000/bestanswer'
- GET /quest
    - パラメタ
        - num: 問題番号 e.x.) quest1.txt を受信したいならば、num=1
    - レスポンス
        - 問題のデータ
    - curl での例
            
            $ curl 'http://IP_Address:40000/quest?num=1'
        
## ToDo
- 使用した石の個数も利用しよう
- POST条件
    - 現状最良スコアよりも良いスコア
    - 現状最良スコアと同点 かつ 使用した石の数が少ない

## 仕様書 from @jprekz
- 問題の受信は, 競技サーバーから直接DLする
    - かのんサーバーは関係ない
    - (後に関係しました)

- 回答の送信は, かのんサーバーを通じて行う
    - 1秒のインターバルが必要なため
    - rekz&とまマシンから, 回答データとそのスコアがかのんサーバーにPOSTされる。
    - かのんサーバーは, その回答を採用するか(ハイスコアであるか)どうかと残りの待ち時間を即座に返答する。
    - かのんサーバー内では, その時点でのハイスコアとなる回答を保持する。前回の提出から一秒過ぎ次第提出する。
    - (rekz&とまマシンが自己申告したスコアと, 競技サーバーから返ってきたスコアとが食い違っていた場合は警告を表示するといいかも。
        そんなことはないと思うが)

- かのんサーバー内では, その時点でのハイスコアも保持する。rekz&とまマシンから常にGETできる(探索に有効活用)

- かの鯖APIまとめ
    - POST /answer (回答データ, スコア)
        - return (ハイスコアかどうか, 残り待ち時間)
    - GET /hiscore ()
        - return (ハイスコア)
