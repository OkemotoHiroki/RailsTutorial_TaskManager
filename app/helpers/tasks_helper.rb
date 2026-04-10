module TasksHelper
  def limit_tasks(tasks, limit: 2)
    visible = tasks.first(limit)
    remaining = [ tasks.size - limit, 0 ].max

    [ visible, remaining ]
  end
end
