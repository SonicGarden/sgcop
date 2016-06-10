require 'spec_helper'

describe RuboCop::Cop::Sgcop::MissingDependent do
  subject(:cop) { RuboCop::Cop::Sgcop::MissingDependent.new }

  it 'has_manyでdependentがなかったら警告' do
    inspect_source(cop, 'has_many :users')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['has_many に dependent がありません'])
  end

  it 'has_manyでdepenedentがあったら警告なし' do
    inspect_source(cop, 'has_many :comments, dependent: :destroy')
    expect(cop.offenses.size).to eq(0)
  end

  it 'has_manyでdependentとそれ以外のオプションがあった場合も警告なし' do
    inspect_source(cop, 'has_many :comments, class_name: "Foo", dependent: :destroy')
    expect(cop.offenses.size).to eq(0)
  end

  it 'has_manyでthroughオプションが指定されてればdependentがなくても警告なし' do
    inspect_source(cop, 'has_many :comments, through: :foo')
    expect(cop.offenses.size).to eq(0)
  end

  it 'has_oneでdependentがなかったら警告' do
    inspect_source(cop, 'has_one :user')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['has_one に dependent がありません'])
  end

  it 'has_oneでdepenedentがあったら警告なし' do
    inspect_source(cop, 'has_one :comment, dependent: :destroy')
    expect(cop.offenses.size).to eq(0)
  end

  it 'has_oneでdependentとそれ以外のオプションがあった場合も警告なし' do
    inspect_source(cop, 'has_one :comment, class_name: "Hoge", dependent: :destroy')
    expect(cop.offenses.size).to eq(0)
  end
end
