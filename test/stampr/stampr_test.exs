defmodule Stampr.StamprTest do
  use ExUnit.Case, async: false

  alias Stampr.Episode

  setup do
    Stampr.delete_all_episodes()
  end

  describe "list_episodes" do
    test "works" do
      assert [] == Stampr.list_episodes()
    end
  end

  describe "create_episode" do
    test "works" do
      %Episode{} = episode = Stampr.create_episode()

      assert [episode] == Stampr.list_episodes()
    end
  end

  describe "update_episode" do
    test "works" do
      episode =
        Stampr.create_episode()
        |> Stampr.update_episode(%{name: "floop"})

      assert [%{name: "floop"} = ^episode] = Stampr.list_episodes()
    end
  end

  describe "delete_episode" do
    test "works" do
      episode = Stampr.create_episode()

      assert [_] = Stampr.list_episodes()

      assert :ok = Stampr.delete_episode(episode)

      assert [] = Stampr.list_episodes()
    end
  end
end
