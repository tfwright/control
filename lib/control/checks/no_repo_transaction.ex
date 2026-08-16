defmodule Control.Checks.NoRepoTransaction do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Use `Repo.transact/1,2` instead of `Repo.transaction/1,2`.

      `transact` expects the function to return `{:ok, result}` or
      `{:error, reason}` and commits or rolls back accordingly. Transactional
      code then reads as a plain `with` chain, with no manual `Repo.rollback/1`
      and no unwrapping of a doubly-nested `{:ok, {:ok, _}}`.
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse(
         {{:., _, [{:__aliases__, meta, mods}, :transaction]}, _, _args} = ast,
         issues,
         issue_meta
       ) do
    if List.last(mods) == :Repo do
      {ast, [issue_for(issue_meta, meta[:line]) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp issue_for(issue_meta, line) do
    format_issue(issue_meta,
      message: "Use `Repo.transact/1,2` instead of `Repo.transaction/1,2`.",
      trigger: "transaction",
      line_no: line
    )
  end
end
