//
//  Misc.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import Foundation

let everydayObjects = [
    "ペン", "紙", "本", "ノート", "カレンダー",
    "時計", "置き時計", "ランプ", "鍵", "財布", "電話",
    "自転車", "車", "バス", "電車", "傘", "サングラス",
    "靴", "ズボン", "シャツ", "ジャケット", "帽子", "手袋",
    "スカーフ", "財布", "財布", "バッグ", "リュックサック",
    "ノートパソコン", "タブレット", "モニター", "キーボード", "マウス",
    "ヘッドホン", "マイク", "カメラ", "レンズ", "三脚",
    "ボトル", "グラス", "カップ", "皿", "ボウル", "フォーク",
    "ナイフ", "スプーン", "箸", "タオル", "ブラシ", "歯ブラシ",
    "歯磨き粉", "シャンプー", "コンディショナー", "石鹸", "タオル",
    "くし", "かみそり", "鏡", "シェーバー", "ドライヤー", "体重計",
    "掃除機", "ほうき", "モップ", "ちりとり", "ゴミ箱",
    "ランドリーバスケット", "アイロン", "アイロン台", "掃除機",
    "工具", "ネジ", "ボルト", "ナット", "ワッシャー", "釘", "ドリル",
    "ハンマー", "プライヤー", "レンチ", "のこぎり", "メジャー",
    "レベル", "やすり", "ノミ", "ペイントブラシ", "ローラー", "こて",
    "はしご", "懐中電灯", "ランタン", "電池", "延長コード",
    "コンセント", "スイッチ", "ソケット", "プラグ", "アダプター",
    "ルーター", "モデム", "プリンター", "スキャナー", "コピー機",
    "クリップ", "ホチキス", "ステープル", "バインダー", "ノート",
    "封筒", "フォルダー", "ポストイットノート", "ラベル",
    "タグ", "定規", "分度器", "コンパス", "電卓",
    "ハイライター", "マーカー", "ペン", "鉛筆", "消しゴム"
]

enum PlayerAuthState: String {
    case authenticating = "ゲームセンターにログインしています..."
    case unauthenticated = "ゲームセンターにサインインしてください。"
    case authenticated = ""
    
    case error = "ゲームセンターへのログイン中にエラーが発生しました。"
    case restricted = "マルチプレイヤーゲームをプレイすることができません！"
}

struct PastGuess: Identifiable {
    let id = UUID()
    var message: String
    var correct: Bool
}

let maxTimeRemaining = 100

enum CommunicationSignature: String, Codable {
    case begin = "begin"
    case timer = "timer"
    case guess = "guess"
    case correct = "correct"
    case incorrect = "incorrect"
    case gameOver = "gameOver"
    case drawing = "drawing"
}

struct CommunicationStructure: Codable {
    let signaature: CommunicationSignature
    // .begin
    let UUIDKey: String?
    // .timer
    let time: Int?
    // .guess/.correct/.incorrect
    let guess: String?
    // .drawing
    let drawing: Data?
}
