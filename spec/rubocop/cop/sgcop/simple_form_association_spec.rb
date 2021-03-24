require 'spec_helper'

describe RuboCop::Cop::Sgcop::SimpleFormAssociation do
  subject(:cop) { RuboCop::Cop::Sgcop::SimpleFormAssociation.new }

  context 'simple_form_for ブロック内での association メソッド呼び出し' do
    it 'collection オプションなしで呼び出している場合は警告' do
      expect_offense(<<~RUBY)
        simple_form_for user do |f|
          f.association :group
          ^^^^^^^^^^^^^^^^^^^^ Specify the `collection` option
        end
      RUBY
    end

    it 'collection オプションありで呼び出している場合は警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_form_for user do |f|
          f.association :group, collection: current_company.groups
        end
      RUBY
    end

    it 'SimpleForm::FormBuilder でない変数に対する association メソッド呼び出しには警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_form_for user do |f|
          other_object.association :group
        end
      RUBY
    end
  end

  context 'simple_nested_form_for ブロック内での association メソッド呼び出し' do
    it 'collection オプションなしで呼び出している場合は警告' do
      expect_offense(<<~RUBY)
        simple_nested_form_for user do |f|
          f.association :group
          ^^^^^^^^^^^^^^^^^^^^ Specify the `collection` option
        end
      RUBY
    end

    it 'collection オプションありで呼び出している場合は警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_nested_form_for user do |f|
          f.association :group, collection: current_company.groups
        end
      RUBY
    end

    it 'SimpleForm::FormBuilder でない変数に対する association メソッド呼び出しには警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_nested_form_for user do |f|
          other_object.association :group
        end
      RUBY
    end
  end

  context 'simple_fields_for ブロック内での association メソッド呼び出し' do
    it 'collection オプションなしで呼び出している場合は警告' do
      expect_offense(<<~RUBY)
        simple_form_for user do |f|
          f.simple_fields_for :posts do |ff|
            ff.association :category
            ^^^^^^^^^^^^^^^^^^^^^^^^ Specify the `collection` option
          end
        end
      RUBY
    end

    it 'collection オプションありで呼び出している場合は警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_form_for user do |f|
          f.simple_fields_for :posts do |ff|
            ff.association :category, collection: Category.all
          end
        end
      RUBY
    end

    it 'SimpleForm::FormBuilder でない変数に対する association メソッド呼び出しには警告しない' do
      expect_no_offenses(<<~RUBY)
        simple_form_for user do |f|
          f.simple_fields_for :posts do |ff|
            other_object.association :category
          end
        end
      RUBY
    end
  end
end
