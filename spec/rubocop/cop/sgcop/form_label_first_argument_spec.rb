require 'spec_helper'

describe RuboCop::Cop::Sgcop::FormLabelFirstArgument do
  subject(:cop) { RuboCop::Cop::Sgcop::FormLabelFirstArgument.new }

  context '第一引数がテキストの場合は警告' do
    it '文字列リテラル' do
      expect_offense(<<~RUBY)
        f.label "キーワード"
                ^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end

    it 't() ヘルパー' do
      expect_offense(<<~RUBY)
        f.label t('activerecord.attributes.field.keywords')
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end

    it 'I18n.t() ヘルパー' do
      expect_offense(<<~RUBY)
        f.label I18n.t('activerecord.attributes.field.keywords')
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end

    it '式展開込みの文字列' do
      expect_offense(<<~'RUBY')
        f.label "#{prefix}名"
                ^^^^^^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end

    it 'form というレシーバ名でも警告' do
      expect_offense(<<~RUBY)
        form.label "キーワード"
                   ^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end

    it 'ff というレシーバ名でも警告' do
      expect_offense(<<~RUBY)
        ff.label t('foo.bar')
                 ^^^^^^^^^^^^ Sgcop/FormLabelFirstArgument: f.label の第一引数には属性名(Symbol)を渡してください。ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。
      RUBY
    end
  end

  context '第一引数が属性名(Symbol)など正当な場合は警告しない' do
    it 'Symbol + 第二引数にテキスト(正しい用法)' do
      expect_no_offenses(<<~RUBY)
        f.label :keywords_cont, t('activerecord.attributes.field.keywords')
      RUBY
    end

    it 'Symbol のみ' do
      expect_no_offenses(<<~RUBY)
        f.label :name
      RUBY
    end

    it '引数ゼロ' do
      expect_no_offenses(<<~RUBY)
        f.label
      RUBY
    end

    it 'ローカル変数(Symbol を保持している可能性)' do
      expect_no_offenses(<<~RUBY)
        @columns.each do |column|
          f.label column
        end
      RUBY
    end

    it 'メソッド戻り値(Symbol を返す可能性)' do
      expect_no_offenses(<<~RUBY)
        f.label attr_name
      RUBY
    end
  end

  context 'f系でないレシーバやヘルパーは対象外' do
    it 'label_tag (レシーバ無しヘルパー)' do
      expect_no_offenses(<<~RUBY)
        label_tag "Name"
      RUBY
    end

    it 'f系でないレシーバの .label' do
      expect_no_offenses(<<~RUBY)
        chart.label "売上"
      RUBY
    end
  end
end
