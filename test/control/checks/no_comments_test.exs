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

  describe "with a HEEx comment in a ~H template" do
    setup do
      source = ~S'''
      defmodule T do
        def render(assigns) do
          ~H"""
          <div>
            <%!-- explain the div --%>
          </div>
          """
        end
      end
      '''

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports it on the comment's line", %{issues: issues} do
      assert Enum.map(issues, & &1.line_no) == [5]
    end
  end

  describe "with an HTML comment in a ~H template" do
    setup do
      source = ~S'''
      defmodule T do
        def render(assigns) do
          ~H"""
          <div>
          </div>
          <!-- explain the div -->
          """
        end
      end
      '''

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports it on the comment's line", %{issues: issues} do
      assert Enum.map(issues, & &1.line_no) == [6]
    end
  end

  describe "with a one-line ~H template holding a comment" do
    setup do
      source = ~S'''
      defmodule T do
        def render(assigns), do: ~H"<div><%!-- a note --%></div>"
      end
      '''

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports it on the sigil's line", %{issues: issues} do
      assert Enum.map(issues, & &1.line_no) == [2]
    end
  end

  describe "with comment markup in a plain string" do
    setup do
      source = ~S'''
      defmodule T do
        def strip(html), do: String.replace(html, "<!--", "")
      end
      '''

      %{issues: source |> to_source_file() |> run_check(NoComments)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
