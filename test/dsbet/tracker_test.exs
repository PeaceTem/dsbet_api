defmodule DSBet.TrackerTest do
  use DSBet.DataCase

  alias DSBet.Tracker

  describe "values" do
    alias DSBet.Tracker.Value

    import DSBet.TrackerFixtures

    @invalid_attrs %{value: nil}

    test "list_values/0 returns all values" do
      value = value_fixture()
      assert Tracker.list_values() == [value]
    end

    test "get_value!/1 returns the value with given id" do
      value = value_fixture()
      assert Tracker.get_value!(value.id) == value
    end

    test "create_value/1 with valid data creates a value" do
      valid_attrs = %{value: 120.5}

      assert {:ok, %Value{} = value} = Tracker.create_value(valid_attrs)
      assert value.value == 120.5
    end

    test "create_value/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_value(@invalid_attrs)
    end

    test "update_value/2 with valid data updates the value" do
      value = value_fixture()
      update_attrs = %{value: 456.7}

      assert {:ok, %Value{} = value} = Tracker.update_value(value, update_attrs)
      assert value.value == 456.7
    end

    test "update_value/2 with invalid data returns error changeset" do
      value = value_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_value(value, @invalid_attrs)
      assert value == Tracker.get_value!(value.id)
    end

    test "delete_value/1 deletes the value" do
      value = value_fixture()
      assert {:ok, %Value{}} = Tracker.delete_value(value)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_value!(value.id) end
    end

    test "change_value/1 returns a value changeset" do
      value = value_fixture()
      assert %Ecto.Changeset{} = Tracker.change_value(value)
    end
  end
end
