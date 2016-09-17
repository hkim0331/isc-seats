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

ccl から cl-mongo/usocket で接続した時、ipv6 のソケット作ろうとして失敗する模様。
sbcl から cl-mongo は ipv6 ではなく ipv4 のソケットをクリエートする？

## Usage

static/ は sb-ext:save-lisp-and-die では持ち運びされない。
サーバにコピーすること。

## Installation

## Author

hiroshi.kimura.0331@gmail.com

---
2016-09-11.

