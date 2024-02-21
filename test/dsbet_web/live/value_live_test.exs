defmodule DSBetWeb.ValueLiveTest do
  use DSBetWeb.ConnCase

  import Phoenix.LiveViewTest
  import DSBet.TrackerFixtures

  @create_attrs %{value: 120.5}
  @update_attrs %{value: 456.7}
  @invalid_attrs %{value: nil}

  defp create_value(_) do
    value = value_fixture()
    %{value: value}
  end

  describe "Index" do
    setup [:create_value]

    test "lists all values", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/values")

      assert html =~ "Listing Values"
    end

    test "saves new value", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/values")

      assert index_live |> element("a", "New Value") |> render_click() =~
               "New Value"

      assert_patch(index_live, ~p"/values/new")

      assert index_live
             |> form("#value-form", value: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#value-form", value: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/values")

      html = render(index_live)
      assert html =~ "Value created successfully"
    end

    test "updates value in listing", %{conn: conn, value: value} do
      {:ok, index_live, _html} = live(conn, ~p"/values")

      assert index_live |> element("#values-#{value.id} a", "Edit") |> render_click() =~
               "Edit Value"

      assert_patch(index_live, ~p"/values/#{value}/edit")

      assert index_live
             |> form("#value-form", value: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#value-form", value: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/values")

      html = render(index_live)
      assert html =~ "Value updated successfully"
    end

    test "deletes value in listing", %{conn: conn, value: value} do
      {:ok, index_live, _html} = live(conn, ~p"/values")

      assert index_live |> element("#values-#{value.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#values-#{value.id}")
    end
  end

  describe "Show" do
    setup [:create_value]

    test "displays value", %{conn: conn, value: value} do
      {:ok, _show_live, html} = live(conn, ~p"/values/#{value}")

      assert html =~ "Show Value"
    end

    test "updates value within modal", %{conn: conn, value: value} do
      {:ok, show_live, _html} = live(conn, ~p"/values/#{value}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Value"

      assert_patch(show_live, ~p"/values/#{value}/show/edit")

      assert show_live
             |> form("#value-form", value: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#value-form", value: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/values/#{value}")

      html = render(show_live)
      assert html =~ "Value updated successfully"
    end
  end
end
