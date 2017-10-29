# goMMD
<ul>
<li>goMMD</li>
    <ul>
    <li>GLKit APIはiOS 5.0及び以降のバージョンでサポート</li>
    <li>OpenGLES 2.xはGLSLシェーダーをサポート</li>
    <li>ハコスコサポート</li>
    </ul>
</ul>

<p>
このプロジェクトは以下の人が対象です。<br>
<ol>
<li>Mac OS Xを使っている方</li>
<li>アップルデベロッパーメンバー</li>
<li>iPhone又はiPadを持っている方</li>
<li>Xcodeを使ってiPhone又はiPadへアプリをインストールした事が有る方</li>
</ol>
<p>
goMMD<br>
<ol>
<li>右側の［Download ZIP]をクリックしてzipファイルをダウンロードする。</li>
<li>goMMD-master.zipを展開する。</li>
<li>以下のフォルダーの[goMMD.xcodeproj]をダブルクリックする。</li>
<pre>
   goMMD-master
　   +— goMMD
         +— goMMD.xcodeproj
</pre>
<li>左側のプロジェクトブラウザーのファイルが全て黒色なのを確認する。</li>
<li>Xcodeが立ち上がったら、ターゲットデバイスを指定する。</li>
<pre>
    Simulatorを設定
    iPhone 5 / iPhone5s など
    Simuilator iPadやiPhone6は画面が大きいので扱い辛い。
</pre>
<li>Build/Runボタンをおす。</li>
<li>ビルドでエラーが無ければ、シムレーターが立ち上がり、iOSアプリの画面が表示されます。</li>
<li>Xcodeの[All Output]フレームから以下の文字列をメモする</li>
<pre>
   Application/<b>HexID-String-A</b>/Documents/__gommd-model.xml]
   <b>HexID-String-A</b> = Hex8-Hex4-Hex4-Hex4-Hex12
</pre>

Finderウインドウ左側ナビゲーターにて、
<pre>
    User Home> > ライブラリ
       > Developer
          > CoreSimulator
             > Devices
                > HexID-String-B
                    > data
                       > Containers
                           > Data
                               > Application
                                  > <b>HexID-String-A</b> (from Xcode All Output)
                                     > Documents
                                         __gommd-model.xml
                                         __gommd-motion.xml
                                         __gommd-modelgroup.xml
</pre>
<p>
MikuMikuDanceのモデル、ステージ、モーションのzipファイルを上記のフォルダーへコピーする。
<pre>
  > <b>HexID-String-A</b> (from Xcode All Output)
　　   > Documents
  注意: 現在サポート出来ているのは.pmd,.vmdのみで、.xや.pmxはサポートされていません。
</pre>

<p>
<pre>
実機へアプリをインストールした場合、iTuneを使ってモデルやモーションの.zipファイルを
アプリ内へコピーして下さい。
iTune
  実機をセレクト
　　　概要
　　　ミュージック
　　　ムービー
　　　テレビ番組
　　　Podcast
　　　ブック
　　　写真
　　　情報
　　　ファイル共有   <-- セレクト
　　　　　　App         <App>の書類
　　　　　　goMMD       goMMDの書類
　　　　　　　　　　　　　このフレームに、.pmdや.vmdの入ったフォルダーの.zipをコピーする
</pre>
<p>
iOS開発の詳細は以下のサイトを見て下さい
<pre>
   https://developer.apple.com/programs
   https://developer.apple.com/ios
</pre>

<p>
MMDモデルデータのロード及び描画はMMDAgentのコードを使わせていただきました。<br>
<b>What is MMDAgent?</b><br>
MMDAgent is a toolkit for building voice interaction systems.
This toolkit is released for contributing to the popularization of speech technology.
We expect all users to use the toolkit in the manner not offensive to public order and morals. 
<pre>
   http://www.mmdagent.jp/
</pre>


Twitter: @papipo111

