defmodule Control.Checks.EctoKeywordQueryTest do
  use Credo.Test.Case

  alias Control.Checks.EctoKeywordQuery

  describe "with a from query using the where: keyword" do
    setup do
      source = """
      defmodule T do
        def q, do: from(u in User, where: u.active == true)
      end
      """

      %{issues: source |> to_source_file() |> run_check(EctoKeywordQuery)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end

    test "reports the correct message", %{issues: issues} do
      assert hd(issues).message =~ "where/3"
    end
  end

  describe "with a from query using the select: keyword" do
    setup do
      source = """
      defmodule T do
        def q, do: from(u in User, select: u.email)
      end
      """

      %{issues: source |> to_source_file() |> run_check(EctoKeywordQuery)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end

    test "reports the correct message", %{issues: issues} do
      assert hd(issues).message =~ "select/3"
    end
  end

  describe "with a from query using multiple keywords" do
    setup do
      source = """
      defmodule T do
        def q, do: from(u in User, where: u.active == true, select: u.email)
      end
      """

      %{issues: source |> to_source_file() |> run_check(EctoKeywordQuery)}
    end

    test "reports one issue per keyword", %{issues: issues} do
      assert length(issues) == 2
    end
  end

  describe "with a pipe-based macro query" do
    setup do
      source = """
      defmodule T do
        def q, do: User |> where([u], u.active == true) |> Repo.all()
      end
      """

      %{issues: source |> to_source_file() |> run_check(EctoKeywordQuery)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end

  describe "with a plain from with no query keywords" do
    setup do
      source = """
      defmodule T do
        def q, do: from(u in User)
      end
      """

      %{issues: source |> to_source_file() |> run_check(EctoKeywordQuery)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
