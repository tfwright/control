defmodule Control.Checks.NoCommentsTest do
  use Credo.Test.Case

  alias Control.Checks.NoComments

  describe "with a module containing a comment" do
    setup do
      source = """
      defmodule T do
        def foo do
          # do the thing
          :ok
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end
  end

  describe "with a module containing only doc attributes" do
    setup do
      source = """
      defmodule T do
        @moduledoc "the module"
        @doc "the function"
        def foo, do: :ok
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
