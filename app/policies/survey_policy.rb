class SurveyPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :good_things,
      :bad_things,
      :other_comments,
      :rsvp_id,
      :recommendation_likelihood
    ]
  end
end
