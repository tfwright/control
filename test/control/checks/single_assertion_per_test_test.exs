defmodule Control.Checks.SingleAssertionPerTestTest do
  use Credo.Test.Case

  alias Control.Checks.SingleAssertionPerTest

  describe "with a test containing two assertions" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "bad" do
          assert 1 == 1
          assert 2 == 2
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(SingleAssertionPerTest)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end

    test "reports the correct count", %{issues: issues} do
      assert hd(issues).message =~ "found 2"
    end
  end

  describe "with a test containing no assertions" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "empty" do
          :ok
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(SingleAssertionPerTest)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end

    test "reports the correct count", %{issues: issues} do
      assert hd(issues).message =~ "found 0"
    end
  end

  describe "with a test containing exactly one assertion" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "good", %{result: result} do
          assert result == nil
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(SingleAssertionPerTest)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end

  describe "with a test containing one refute" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "good", %{result: result} do
          refute result == nil
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(SingleAssertionPerTest)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
