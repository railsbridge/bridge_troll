# frozen_string_literal: true

module FormHelper
  def fill_in_select2(option)
    page.find('.select2-selection').click
    page.find('.select2-search__field').set(option)
    expect(page.find('.select2-results__option')).to have_content(option)
    page.find('.select2-results__option').click
  end
end
