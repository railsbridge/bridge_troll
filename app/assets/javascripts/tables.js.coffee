$(document).ready ->
  $.extend($.fn.dataTable.defaults, {
    dom: "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    pagingType: "bootstrap",
    pageLength: 50
  })

  $('.datatable').DataTable()

  tableNeedsPagination = $('.datatable-sorted tbody tr').length > 10

  discoverSortOrder = ->
    tableSortPreferences = $('.datatable-sorted th').map (ix, element) ->
      defaultSortDirection = $(element).data('default-sort')
      if defaultSortDirection then [[ix, defaultSortDirection]] else null
    tableSortPreferences[0]

  $('.datatable-sorted').DataTable
    paging: tableNeedsPagination,
    order: discoverSortOrder() || [[ 1, "desc" ]],
    columnDefs: [
      {targets: ['date'], type: "date"}
    ]

  $('.datatable-checkins').DataTable
    paging: false,
    order: [[ 0, "asc" ]],
    columnDefs: [
      {targets: ['checkins-action'], sortable: false}
    ]