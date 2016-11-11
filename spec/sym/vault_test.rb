require_relative 'test_helper'
require 'securerandom'

class VaultTest < PryTest::Test

  before do
    @vault = Coin::Vault.instance
    @key = "key-#{SecureRandom.uuid}"
  end

  test 'read using an unstored key' do
    assert @vault.read(@key).nil?
  end

  test 'basic write & read' do
    value = rand(999999999)
    @vault.write(@key, value)
    assert @vault.read(@key) == value
  end

  test 'read_and_delete' do
    value = rand(999999999)
    @vault.write(@key, value)
    val = @vault.read_and_delete(@key)
    assert @vault.read(@key).nil?
    assert val == value
  end

  test 'read_and_write' do
    orig_value = rand(999999999)
    value = nil
    @vault.write(@key, orig_value)
    values = @vault.read_and_write(@key) do |val|
      value = rand(888888888)
    end
    assert values.first == orig_value
    assert values.last == value
    assert @vault.read(@key) == value
  end

  test 'delete' do
    @vault.write(@key, true)
    assert @vault.read(@key)
    @vault.delete(@key)
    assert @vault.read(@key).nil?
  end

  test 'clear' do
    10.times { |i| @vault.write("key#{i}", true) }
    assert @vault.length >= 10
    @vault.clear
    assert @vault.length == 0
  end

end
