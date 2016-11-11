require_relative 'test_helper'

class CoinTest < PryTest::Test
  before do
    @key = "key-#{SecureRandom.uuid}"
  end

  after do
    Coin.stop_server
  end

  test "stop_server" do
    Coin.start_server
    assert Coin.server_running?
    Coin.stop_server
    assert Coin.server_running? == false
  end

  test "server method starts the server" do
    Coin.stop_server
    assert !Coin.server_running?
    Coin.server
    assert Coin.server_running?
  end

  test "read access starts the server" do
    Coin.stop_server
    assert !Coin.server_running?
    Coin.read :foo
    assert Coin.server_running?
  end

  test "read with assignment block" do
    value = rand(99999999999)
    assert Coin.read(@key).nil?
    Coin.read(@key) { value }
    assert Coin.read(@key) == value
  end

  test "read and delete" do
    value = rand(99999999999)
    Coin.write @key, value
    val = Coin.read_and_delete(@key)
    assert val == value
    assert Coin.read(@key).nil?
  end

  test "write with expiration" do
    Coin.write(@key, true, 1)
    assert Coin.read(@key)
    sleep 1
    assert Coin.read(@key).nil?
  end

  test "delete" do
    Coin.write(@key, true)
    assert Coin.read(@key)
    Coin.delete(@key)
    assert Coin.read(@key).nil?
  end

  test "length" do
    10.times { |i| Coin.write("key#{i}", rand(9999)) }
    assert Coin.length >= 10
  end

  test "clear" do
    10.times { |i| Coin.write("key#{i}", rand(9999)) }
    assert Coin.length >= 10
    Coin.clear
    assert Coin.length == 0
  end

end
