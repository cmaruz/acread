require 'helper'

class Person < ActiveRecord::Base
  deprecate_attribute :long_name
  establish_connection :adapter => 'sqlite3', :database => 'foobar.db'
  connection.create_table table_name, :force => true do |t|
    t.string :name
    t.string :long_name
  end
end

class PersonFull < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3', :database => 'foobar.db'
  connection.create_table table_name, :force => true do |t|
    t.string :name
    t.string :long_name
  end
end


class TestAcread < Test::Unit::TestCase
  def setup
    @bob = Person.create!(:name => 'bob')
    @james = PersonFull.create(:long_name => 'James the magnific')
  end

  def test_cretor_with_deprecated_field_raise_exception
    assert_raise(Deprecatable::DeprecatedAttributeError) { Person.create(:long_name => 'should not see this')    }
  end

  def test_read_deprecated_raise_exception
    assert_raise(Deprecatable::DeprecatedAttributeError) { @bob.long_name }
  end

  def test_write_deprecated_raise_exception
    assert_raise(Deprecatable::DeprecatedAttributeError) { @bob.long_name = 'Bon' }
  end

  def test_write_dreprecated_with_continuation
    return true unless Acread::run_19?
    v = 'failure'
    begin
      @bob.long_name = 'bobob'
      v = @bob.long_name
    rescue Deprecatable::DeprecatedAttributeError => e
      e.continue
    end
    assert_equal 'bobob', v
  end

  def test_hash_exclude_deprecated_attributes
    h = @bob.serializable_hash
    assert !(h.keys.include? 'long_name')
  end

  def test_columns_exclude_deprecated_attributes
    h = @bob.send(:columns).map(&:name)
    assert !(h.include? 'long_name')
  end

  def test_non_deprecated_class_can_read_all_attributes
    assert @james.long_name.is_a? String
  end

  def test_non_deprecated_class_can_write_all_attributes
    s = 'james the short'
    @james.long_name = s
    assert @james.long_name == s
  end

  def test_non_deprecated_class_columns_output_all_attributes
    h = @james.send(:columns).map(&:name)
    assert h.include? 'long_name'
  end

  def test_non_deprecated_class_hash_output_all_attributes
    h = @james.serializable_hash
    assert h.keys.include? 'long_name'
  end
end
