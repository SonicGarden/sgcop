---
paths:
  - "spec/**/*_spec.rb"
---

# RSpec `let` を効果的に使うルール

出典: [RSpec: 5 Rules for Using `let` Effectively](https://toppa.com/2026/rspec-5-rules-for-using-let-effectively/)

`let` の効果的な使い方には5つのルールがある。このうち **R2 / R3 は RuboCop Cop が自動チェック
する**ため、ここでは静的解析にそぐわない **R1 / R4 / R5** を spec 作成・レビュー時の判断基準として扱う。

| # | ルール | チェック手段 |
|---|--------|------------|
| R1 | まずインラインで書き、3回以上重複してから `let` に抽出する | 本ルール（人間/Claude の判断） |
| R2 | 1コンテキストの `let` は最大5個まで | Cop `RSpec/MultipleMemoizedHelpers` |
| R3 | 子コンテキストで親の `let` をオーバーライドしない | Cop `Sgcop/Rspec/NoLetOverride` |
| R4 | `let` はそのコンテキストの全テストが使う場所にだけ置く | 本ルール |
| R5 | `let` に副作用（アクション）を書かない | 本ルール |

以下、spec を書く/レビューするときは R1・R4・R5 に従うこと。

---

## R1: インライン優先 — 3回重複してから `let` に抽出する

セットアップは**まずテストブロック（`it` / `example`）の中にインラインで書く**。同一のセットアップが
**3回以上**出現して初めて `let` に抽出する。1〜2回の重複で先回りして `let` 化しない。

可読性・自己完結性（DAMP: Descriptive And Meaningful Phrases）を、早すぎる DRY 化より優先する。
テストは「そのブロックだけ読めば何をしているか分かる」状態が望ましく、`let` への早すぎる抽出は
セットアップを離れた場所へ追いやって読みにくくする。

```ruby
# 避ける: 1か所でしか使わないのに let に抽出している（インラインで十分）
describe '#full_name' do
  let(:user) { User.new(first_name: 'Taro', last_name: 'Yamada') }

  it 'joins first and last name' do
    expect(user.full_name).to eq 'Taro Yamada'
  end
end

# 良い: そのテスト内で完結。何を検証しているか一目で分かる
describe '#full_name' do
  it 'joins first and last name' do
    user = User.new(first_name: 'Taro', last_name: 'Yamada')
    expect(user.full_name).to eq 'Taro Yamada'
  end
end
```

同じ `user` を3つ以上の example が使うようになったら、そこで初めて `let(:user)` に抽出してよい。

**R4 によるスコープ押し下げ後の再判定**: R4 に従って `let` をより狭い `context` へ押し下げた結果、
その `context` 内での使用回数が3回未満になることがある。この場合、押し下げ後もなお2個以上の
example が共有しているなら `let` のままでよい（3回という閾値は新規に `let` を書き起こす時の
基準であり、既存の `let` を再度インライン化すべきかどうかの基準ではない）。押し下げた結果
使用箇所が1個だけになった場合は、その example 内にインライン化する。

---

## R4: そのコンテキストの全テストで使う `let` だけを置く

`let` は、それが定義されたコンテキスト（`describe` / `context`）内の**すべてのテストが実際に使う**
場合にだけ置く。一部のテストしか使わない `let` は、それを使うテストだけを囲む**より狭い `context`
へ押し下げる**。

コンテキストの全テストで使われない `let` は "mystery guest"（テスト本文からは見えない隠れた依存）を
生み、どの `let` がどのテストに効いているのかを追いにくくする。

ここでの「使う」とは、テスト本文からの直接参照だけでなく、以下も含む:
- 他の `let` の定義内から参照されている（間接参照）
- `let!` による DB 永続化などの副作用そのものに依存している（変数名を一切参照しなくても、
  その副作用が起きている前提でテストが書かれていれば「使っている」とみなす）

```ruby
# 避ける: admin は「when admin」のテストしか使わないのにトップレベルにある
describe User do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) } # 下の it では未使用

  it 'is a user' do
    expect(user).to be_present
  end

  context 'when admin' do
    it 'has admin role' do
      expect(admin.role).to eq 'admin'
    end
  end
end

# 良い: admin を使うテストだけを囲む context に押し下げる
describe User do
  let(:user) { create(:user) }

  it 'is a user' do
    expect(user).to be_present
  end

  context 'when admin' do
    let(:admin) { create(:admin) }

    it 'has admin role' do
      expect(admin.role).to eq 'admin'
    end
  end
end
```

---

## R5: `let` に副作用（アクション）を書かない

`let` は**値の定義専用**であり、遅延評価される純粋な値を返すものとして扱う。命令的な操作
（API 呼び出し・メール送信・支払い処理・外部サービスへの副作用など）は `let` に書かず、
`before` ブロックかテスト本文（インライン）に書く。

`let` は参照されて初めて評価される遅延評価のため、副作用を `let` に置くと「いつ実行されるか」が
参照有無に依存して不安定になる。副作用は実行タイミングが明確な `before` かインラインに置く。

```ruby
# 避ける: let の中で副作用（メール送信）を起こしている
describe 'notification' do
  let(:send_result) { NotificationMailer.welcome(user).deliver_now } # 副作用

  it 'delivers a mail' do
    send_result
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end
end

# 良い: 副作用は before / インラインへ。let は値の定義だけに使う
describe 'notification' do
  let(:user) { create(:user) }

  it 'delivers a mail' do
    NotificationMailer.welcome(user).deliver_now
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end
end
```

なお `let!` で `create(...)` する場合も副作用を伴うため、そのセットアップが**そのコンテキストの
全テストで本当に必要か**（R4）を併せて検討すること。一部のテストだけが必要とするなら狭い
コンテキストへ押し下げる。
