window.whenReady ->
  domWithoutActions = "t<'row'<'col-md-6'i><'col-md-6'p>>"
  domWithActions = "<'row'<'col-md-6'l><'col-md-6'f>r>" + domWithoutActions

  $.extend($.fn.dataTable.defaults, {
    dom: domWithActions,
    pagingType: 'full_numbers',
    pageLength: 50
  })

  $('.datatable').DataTable()

  tableNeedsPagination = ($table) ->
    $table.find('tbody tr').length > 10

  discoverSortOrder = ($table) ->
    tableSortPreferences = $table.find('th').map (ix, element) ->
      defaultSortDirection = $(element).data('default-sort')
      if defaultSortDirection then [[ix, defaultSortDirection]] else null
    tableSortPreferences[0]

  $('.datatable-sorted').each (ix, element) ->
    $table = $(element)
    needsPagination = tableNeedsPagination($table)
    $table.DataTable
      paging: needsPagination,
      searching: needsPagination,
      dom: if needsPagination then domWithActions else domWithoutActions
      order: discoverSortOrder($table) || [[ 1, "desc" ]],
      columnDefs: [
        {targets: ['date'], type: "date"}
      ]

  $('.datatable-checkins').DataTable
    paging: false,
    order: [[ 0, "asc" ]],
    columnDefs: [
      {targets: ['checkins-action'], sortable: false}
    ]