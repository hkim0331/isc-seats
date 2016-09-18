# Seats

C-2B/C-2G の着席状況をブラウザ上に表示。

ssh しまくってログインしているユーザ、端末をかき集めるスクリプトを
過去に書いたが、情報センターの利便性よりもセキュリティ？を高める
くだらないポリシーのため、
スクリプトを書いた当時の方法では学生の端末に ssh できなくなった。

4年生青木に開発のようすを見せる目的もかねて、seats する。

## BUG

二つの OS X El Capitan があり、ccl64 で開発を実施しているが、
iMac(21.5-inch, Mid2011) では cl-mongo でエラーになる。
ccl64 をやめ、sbcl に切り替えると動作するようになる。

* cl-mongo-20131003-git
* usocket-0.6.4

usocket が ipv6 の通信しようとして失敗するのか？
ccl/cl-mongo/usocket は、ipv6 のソケット作ろうとする。
sbcl/cl-mongo/usocket は ipv4 で通信している模様。

リモートで起動した mongod の ipv4 ポートを転送して、ccl/cl-mongoはエラーにならない。

## Usage

## Installation

static/ は sb-ext:save-lisp-and-die では持ち回られない。
サーバにコピーすること。

## Author

hiroshi.kimura.0331@gmail.com

---
2016-09-11.

