defmodule Control.Checks.EctoKeywordQuery do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Prefer Ecto macro query functions (where/3, select/3, order_by/3, etc.) over
      keyword syntax inside `from`. Macro functions compose naturally with |> pipes.

      # preferred
      User |> where([u], u.active == true) |> Repo.all()

      # not preferred
      from u in User, where: u.active == true
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:from, meta, [_binding, [_ | _] = keywords]} = ast, issues, issue_meta) do
    query_keywords = [:where, :select, :order_by, :group_by, :having, :join, :limit, :offset]

    new_issues =
      keywords
      |> Keyword.keys()
      |> Enum.filter(&(&1 in query_keywords))
      |> Enum.map(fn keyword ->
        format_issue(issue_meta,
          message: "Use the `#{keyword}/3` macro instead of the `#{keyword}:` keyword in `from`.",
          trigger: "from",
          line_no: meta[:line]
        )
      end)

    {ast, issues ++ new_issues}
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}
end
