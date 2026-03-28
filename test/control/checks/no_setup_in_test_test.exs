defmodule Control.Checks.NoSetupInTestTest do
  use Credo.Test.Case

  alias Control.Checks.NoSetupInTest

  describe "with a test containing a variable binding" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "bad" do
          result = some_function()
          assert result == nil
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoSetupInTest)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end
  end

  describe "with a test containing a bare function call" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "bad" do
          some_function()
          assert true
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoSetupInTest)}
    end

    test "reports an issue", %{issues: issues} do
      assert length(issues) == 1
    end
  end

  describe "with a test containing only an assertion" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "good", %{result: result} do
          assert result == nil
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoSetupInTest)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end

  describe "with a test containing an assert_* helper" do
    setup do
      source = """
      defmodule T do
        use ExUnit.Case
        test "good", %{conn: conn} do
          assert_email_sent(to: "user@example.com")
        end
      end
      """

      %{issues: source |> to_source_file() |> run_check(NoSetupInTest)}
    end

    test "reports no issues", %{issues: issues} do
      assert issues == []
    end
  end
end
