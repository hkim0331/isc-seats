# Seats

C-2B/C-2G の着席状況をブラウザ上に表示。

ssh しまくってログインしているユーザ、端末をかき集めるスクリプトを
過去に書いたが、情報センターの利便性よりもセキュリティ？を高める
くだらないポリシーのため、
スクリプトを書いた当時の方法では学生の端末に ssh できなくなった。

4年生青木に開発のようすを見せる目的もかねて、seats する。

## BUG

* sb-ext:save-lisp-and-die で作成したバイナリが動作しない。
  index は表示するが、mongodb と接続しようとしてダメみたい。
  次は imac2 でのログ(適当に改行)。

    127.0.0.1 - [2016-09-20 11:59:17] "POST /check HTTP/1.1" 200 2828 "http://localhost:8080/index" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.8 (KHTML, like Gecko) Version/9.1.3 Safari/601.7.8"

    error occured when sending message : Couldn't write to #<SB-SYS:FD-STREAM for "socket 127.0.0.1:59998, peer: 127.0.0.1:27017" {1004111783}>: Bad file descriptor

    closing connection (type-of MONGO) [name : DEFAULT ]
 {[id : 7E6EF217-A082-4E7A-AE2B-0A750061E91E] [port : 27017] [host : localhost] [db : test]}

* 二つの OS X El Capitan があり、ccl64 で開発を実施しているが、
iMac(21.5-inch, Mid2011) では cl-mongo でエラーになる。
ccl64 をやめ、sbcl に切り替えると動作するようになる。

    * cl-mongo-20131003-git
    * usocket-0.6.4

    usocket が ipv6 の通信しようとして失敗するのか？
    ccl/cl-mongo/usocket は、ipv6 のソケット作ろうとする。
    sbcl/cl-mongo/usocket は ipv4 で通信している模様。

    リモートで起動した mongod の ipv4 ポートを転送し、
    それにつなぐとccl/cl-mongoはエラーにならない。

## Usage

```
CL-USER> (ql:quickload :seats)
CL-USER> (in-package :seats)
SEATS> (start-server)
```

```
$ firefox http://localhost:8080/index
```

## Installation

static/ は sb-ext:save-lisp-and-die では持ち回られない。
サーバにコピーすること。

## Author

hiroshi.kimura.0331@gmail.com

---
2016-09-11.

