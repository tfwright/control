defmodule Control.Checks.NoRepoTransactionTest do
  use Credo.Test.Case

  alias Control.Checks.NoRepoTransaction

  describe "with a call to Repo.transaction" do
    setup do
      source = """
      defmodule T do
        def foo do
          Repo.transaction(fn -> :ok end)
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoRepoTransaction)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end
  end

  describe "with a call to a non-Repo transaction function" do
    setup do
      source = """
      defmodule T do
        def foo do
          Other.transaction(fn -> :ok end)
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoRepoTransaction)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end

  describe "with a call to Repo.transact" do
    setup do
      source = """
      defmodule T do
        def foo do
          Repo.transact(fn -> {:ok, :ok} end)
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoRepoTransaction)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
